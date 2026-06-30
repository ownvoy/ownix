{ lib, pkgs, ... }:
let
  serialBridgePython = pkgs.python312.withPackages (ps: [ ps.pyserial ]);

  runtimeLibs = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.glib
    pkgs.libGL
    pkgs.xorg.libX11
    pkgs.xorg.libXext
    pkgs.xorg.libXrender
    pkgs.xorg.libSM
    pkgs.xorg.libICE
  ];

  cameraOcrPython = "/home/ownvoy/ownix/local-scripts/camera-ocr-preview.py";
  penSerialBridgePython = "/home/ownvoy/ownix/local-scripts/pen-serial-bridge.py";

  ocrEnv = ''
    export LD_LIBRARY_PATH="${runtimeLibs}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export UV_PYTHON_DOWNLOADS=never

    cache_root="''${XDG_CACHE_HOME:-$HOME/.cache}/ocr-korean-note"
    venv_dir="$cache_root/venv"
    python_bin="${pkgs.python312}/bin/python3.12"

    mkdir -p "$cache_root"

    if [ ! -x "$venv_dir/bin/python" ]; then
      uv venv --python "$python_bin" "$venv_dir"
    fi

    if ! "$venv_dir/bin/python" -c "import paddleocr, paddle" >/dev/null 2>&1; then
      uv pip install --python "$venv_dir/bin/python" paddleocr paddlepaddle
    fi
  '';

  ocrKoreanNote = pkgs.writeShellApplication {
    name = "ocr-korean-note";
    runtimeInputs = with pkgs; [
      fswebcam
      python312
      uv
    ];
    text = ''
      set -euo pipefail

      if [ $# -lt 1 ]; then
        echo "usage: ocr-korean-note <image-path> [save-path]" >&2
        exit 1
      fi

      ${ocrEnv}

      image_path="$1"
      save_path="''${2:-./output}"

      exec "$venv_dir/bin/paddleocr" ocr -i "$image_path" \
        --lang korean \
        --ocr_version PP-OCRv5 \
        --text_detection_model_name PP-OCRv5_mobile_det \
        --text_recognition_model_name korean_PP-OCRv5_mobile_rec \
        --enable_mkldnn False \
        --use_doc_orientation_classify False \
        --use_doc_unwarping False \
        --use_textline_orientation False \
        --save_path "$save_path"
    '';
  };

  cameraOcrPreview = pkgs.writeShellApplication {
    name = "camera-ocr-preview";
    runtimeInputs = with pkgs; [
      coreutils
      fswebcam
      python312
      uv
      v4l-utils
    ];
    text = ''
      set -euo pipefail

      device="''${1:-/dev/video1}"
      output_root="''${2:-$PWD/camera-ocr-output}"
      resolution="''${CAMERA_OCR_RESOLUTION:-1280x720}"

      ${ocrEnv}

      mkdir -p "$output_root"
      preview_log="$(mktemp -t camera-ocr-preview.XXXXXX.log)"

      cleanup() {
        if [ -n "''${preview_pid:-}" ] && kill -0 "$preview_pid" 2>/dev/null; then
          kill "$preview_pid" 2>/dev/null || true
        fi
        rm -f "$preview_log"
      }
      trap cleanup EXIT INT TERM

      qv4l2 -d "$device" >"$preview_log" 2>&1 &
      preview_pid=$!
      sleep 1

      if ! kill -0 "$preview_pid" 2>/dev/null; then
        echo "failed to open preview window; check $preview_log" >&2
        exit 1
      fi

      printf 'preview ready on %s\n' "$device"
      printf 'controls: [space] capture+ocr  [q] quit\n'

      while true; do
        if ! kill -0 "$preview_pid" 2>/dev/null; then
          echo "preview window closed" >&2
          exit 1
        fi

        IFS= read -rsn1 key
        case "$key" in
          ' ')
            timestamp="$(date +%Y%m%d-%H%M%S)"
            image_path="$output_root/$timestamp.jpg"
            result_dir="$output_root/$timestamp"
            mkdir -p "$result_dir"

            kill "$preview_pid" 2>/dev/null || true
            wait "$preview_pid" 2>/dev/null || true
            unset preview_pid
            sleep 1

            fswebcam -d "$device" -r "$resolution" --no-banner "$image_path" >/dev/null
            printf 'captured: %s\n' "$image_path"

            "$venv_dir/bin/python" "${cameraOcrPython}" "$image_path" "$result_dir"
            exit 0
            ;;
          q|Q)
            echo "quit"
            exit 0
            ;;
        esac
      done
    '';
  };

  cameraOcrSnapshot = pkgs.writeShellApplication {
    name = "camera-ocr-snapshot";
    runtimeInputs = with pkgs; [
      coreutils
      fswebcam
      python312
      uv
    ];
    text = ''
      set -euo pipefail

      device="''${1:-/dev/video1}"
      output_root="''${2:-$PWD/camera-ocr-snapshot-output}"
      resolution="''${CAMERA_OCR_RESOLUTION:-1280x720}"

      ${ocrEnv}

      timestamp="$(date +%Y%m%d-%H%M%S)"
      image_path="$output_root/$timestamp.jpg"
      result_dir="$output_root/$timestamp"

      mkdir -p "$result_dir"

      fswebcam -d "$device" -r "$resolution" --no-banner "$image_path" >/dev/null
      printf 'captured: %s\n' "$image_path"
      exec "$venv_dir/bin/python" "${cameraOcrPython}" "$image_path" "$result_dir"
    '';
  };

  cameraOcrVideo = pkgs.writeShellApplication {
    name = "camera-ocr-video";
    runtimeInputs = with pkgs; [
      coreutils
      ffmpeg
      findutils
      psmisc
      python312
      uv
    ];
    text = ''
            set -euo pipefail

            device="''${1:-/dev/video1}"
            output_root="''${2:-$PWD/camera-ocr-video-output}"
            resolution="''${CAMERA_OCR_RESOLUTION:-1280x720}"
            interval="''${CAMERA_OCR_INTERVAL:-1}"
            framerate="''${CAMERA_OCR_FRAMERATE:-30}"
            preview_enabled="''${CAMERA_OCR_PREVIEW:-1}"
            preview_fps="''${CAMERA_OCR_PREVIEW_FPS:-15}"
            audio_backend="''${CAMERA_OCR_AUDIO_BACKEND:-pulse}"
            audio_input="''${CAMERA_OCR_AUDIO_INPUT:-alsa_input.usb-Arducam_Technology_Co.__Ltd._Arducam_5MP_USB_Camera-00.analog-stereo}"
            audio_gain="''${CAMERA_OCR_AUDIO_GAIN:-1}"

            ${ocrEnv}

            timestamp="$(date +%Y%m%d-%H%M%S)"
            session_name="''${CAMERA_OCR_SESSION_NAME:-$timestamp}"
            session_dir="$output_root/$session_name"
            frames_dir="$session_dir/frames"
            ocr_dir="$session_dir/ocr"
            video_path="$session_dir/capture.mkv"
            audio_path="$session_dir/audio.wav"
            session_log="$session_dir/session.log"

            mkdir -p "$frames_dir" "$ocr_dir"

            wait_for_device_release() {
              local target="$1"
              local timeout_s="''${2:-8}"
              local waited=0
              while fuser "$target" >/dev/null 2>&1; do
                if [ "$waited" -ge "$timeout_s" ]; then
                  echo "device still busy after ''${timeout_s}s: $target" >&2
                  return 1
                fi
                sleep 1
                waited=$((waited + 1))
              done
            }

            if ! wait_for_device_release "$device" 8; then
              exit 1
            fi

            video_pid=""
            audio_pid=""
            preview_pid=""
            preview_pipe=""
            cleanup() {
              if [ -n "$video_pid" ] && kill -0 "$video_pid" 2>/dev/null; then
                kill -INT "$video_pid" 2>/dev/null || true
                wait "$video_pid" 2>/dev/null || true
              fi
              if [ -n "$audio_pid" ] && kill -0 "$audio_pid" 2>/dev/null; then
                kill -INT "$audio_pid" 2>/dev/null || true
                wait "$audio_pid" 2>/dev/null || true
              fi
              if [ -n "$preview_pid" ] && kill -0 "$preview_pid" 2>/dev/null; then
                kill -INT "$preview_pid" 2>/dev/null || true
                wait "$preview_pid" 2>/dev/null || true
              fi
              if [ -n "$preview_pipe" ] && [ -p "$preview_pipe" ]; then
                rm -f "$preview_pipe"
              fi
            }
            trap cleanup EXIT INT TERM

            printf 'recording video from %s
      ' "$device"
            printf 'session: %s
      ' "$session_dir"
            printf 'audio: %s
      ' "$audio_input"
            printf 'audio gain: %sx
      ' "$audio_gain"
            printf 'preview: %s
      ' "$preview_enabled"
            printf 'controls: [q] stop
      '

            {
              printf 'recording video from %s\n' "$device"
              printf 'session: %s\n' "$session_dir"
              printf 'audio: %s\n' "$audio_input"
              printf 'audio gain: %sx\n' "$audio_gain"
              printf 'preview: %s\n' "$preview_enabled"
              printf 'started_at: %s\n' "$(date --iso-8601=seconds)"
            } >> "$session_log"

            if [ "$preview_enabled" != "0" ]; then
              preview_pipe="$(mktemp -t camera-ocr-preview.XXXXXX.pipe)"
              rm -f "$preview_pipe"
              mkfifo "$preview_pipe"
              ffplay -hide_banner -loglevel warning -fflags nobuffer -flags low_delay -f mjpeg "$preview_pipe" >>"$session_log" 2>&1 &
              preview_pid=$!
            fi

            ffmpeg -hide_banner -loglevel warning -nostdin -y         -f v4l2         -framerate "$framerate"         -video_size "$resolution"         -input_format mjpeg         -i "$device"         -map 0:v -c:v copy "$video_path"         -map 0:v -vf "fps=1/$interval" -q:v 2 "$frames_dir/frame-%06d.jpg" ''${preview_pipe:+-map 0:v -vf "fps=$preview_fps,scale=960:-1" -f mjpeg "$preview_pipe"} >>"$session_log" 2>&1 &
            video_pid=$!

            if [ "$audio_input" != "none" ]; then
              if [ "$audio_backend" = "pulse" ]; then
                ffmpeg -hide_banner -loglevel warning -nostdin \
                  -thread_queue_size 512 \
                  -f pulse \
                  -i "$audio_input" \
                  -af "volume=$audio_gain" \
                  "$audio_path" >>"$session_log" 2>&1 &
              else
                ffmpeg -hide_banner -loglevel warning -nostdin \
                  -thread_queue_size 512 \
                  -f alsa \
                  -i "$audio_input" \
                  -af "volume=$audio_gain" \
                  "$audio_path" >>"$session_log" 2>&1 &
              fi
              audio_pid=$!
            fi

            last_frame=""
            while kill -0 "$video_pid" 2>/dev/null; do
              latest_frame="$(find "$frames_dir" -maxdepth 1 -name 'frame-*.jpg' -print | sort | tail -n 1)"
              if [ -n "$latest_frame" ] && [ "$latest_frame" != "$last_frame" ]; then
                frame_name="$(basename "$latest_frame" .jpg)"
                frame_ocr_dir="$ocr_dir/$frame_name"
                mkdir -p "$frame_ocr_dir"
                printf '
      [%s] OCR %s
      ' "$(date +%H:%M:%S)" "$frame_name"
                "$venv_dir/bin/python" "${cameraOcrPython}" "$latest_frame" "$frame_ocr_dir"
                last_frame="$latest_frame"
              fi

              if IFS= read -rsn1 -t 1 key; then
                if [ "$key" = "q" ] || [ "$key" = "Q" ]; then
                  break
                fi
              fi
            done

            if [ -n "$video_pid" ] && kill -0 "$video_pid" 2>/dev/null; then
              kill -INT "$video_pid" 2>/dev/null || true
              wait "$video_pid" 2>/dev/null || true
            fi
            video_pid=""

            if [ -n "$audio_pid" ] && kill -0 "$audio_pid" 2>/dev/null; then
              kill -INT "$audio_pid" 2>/dev/null || true
              wait "$audio_pid" 2>/dev/null || true
            fi
            audio_pid=""
            sleep 1

            printf '
      video: %s
      ' "$video_path"
            if [ "$audio_input" != "none" ]; then
              printf 'audio: %s
      ' "$audio_path"
            fi
            printf 'frames: %s
      ' "$frames_dir"
            printf 'ocr: %s
      ' "$ocr_dir"
            printf 'log: %s
      ' "$session_log"
    '';
  };

  penSerialBridge = pkgs.writeShellApplication {
    name = "pen-serial-bridge";
    runtimeInputs = [
      serialBridgePython
      cameraOcrSnapshot
      cameraOcrVideo
    ];
    text = ''
      set -euo pipefail
      exec ${serialBridgePython}/bin/python ${penSerialBridgePython}
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    arduino-cli
    fswebcam
    libcamera
    python312
    texlive.combined.scheme-full
    wev
    cameraOcrPreview
    cameraOcrSnapshot
    cameraOcrVideo
    ocrKoreanNote
    penSerialBridge
  ];
}
