import json
import os
from pathlib import Path
import shlex
import signal
import subprocess
import sys
import threading
import time
from datetime import datetime

import serial


RED = "\033[1;31m"
RESET = "\033[0m"


def highlight_red(message: str) -> str:
    return f"{RED}{message}{RESET}"


def main() -> int:
    STATE_IDLE = "IDLE"
    STATE_COLLECTING = "COLLECTING"
    STATE_STOPPING = "STOPPING"

    device = os.environ.get("PEN_SERIAL_DEVICE", "/dev/ttyACM0")
    baudrate = int(os.environ.get("PEN_SERIAL_BAUDRATE", "115200"))
    b1_command = os.environ.get("PEN_B1_START_CMD", "camera-ocr-video")
    restart_cooldown = float(os.environ.get("PEN_B1_RESTART_COOLDOWN", "2.0"))
    collection_root = Path(
        os.environ.get("PEN_COLLECTION_ROOT", str(Path.home() / "camera-ocr-video-output"))
    )
    playback_target = os.environ.get(
        "PEN_B2_PLAYBACK_TARGET",
        "alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.analog-stereo",
    )
    remote_host = os.environ.get("PEN_REMOTE_HOST", "")
    remote_user = os.environ.get("PEN_REMOTE_USER", "vml")
    remote_input_dir = os.environ.get(
        "PEN_REMOTE_INPUT_DIR",
        "C:/Users/vml/Documents/GitHub/CT/CT_final/pentory_software_b/input/from_software_a",
    )
    remote_mode = os.environ.get("PEN_REMOTE_MODE", "random")
    segment_audio_input = os.environ.get(
        "PEN_SEGMENT_AUDIO_INPUT",
        "alsa_input.usb-Arducam_Technology_Co.__Ltd._Arducam_5MP_USB_Camera-00.analog-stereo",
    )
    segment_audio_gain = os.environ.get("PEN_SEGMENT_AUDIO_GAIN", "1")

    print(f"serial bridge device: {device}")
    print(f"baudrate: {baudrate}")
    print(f"B1 start command: {b1_command}")
    print(f"B2 playback target: {playback_target}")
    print(f"B1 restart cooldown: {restart_cooldown:.1f}s")
    print(f"collection root: {collection_root}")
    print(f"remote host: {remote_host or '(disabled)'}")
    print(f"segment audio input: {segment_audio_input}")
    print(f"segment audio gain: {segment_audio_gain}x")

    collection_proc = None
    playback_proc = None
    segment_proc = None
    last_b1_stop_time = 0.0
    current_session_dir: Path | None = None
    current_session_stem: str | None = None
    current_segment_stem: str | None = None
    current_segment_path: Path | None = None
    segment_used_in_session = False
    latest_generated_session_dir: Path | None = None
    latest_generated_audio_stem: str | None = None
    state = STATE_IDLE
    upload_threads: list[threading.Thread] = []
    playback_stop_event = threading.Event()
    playback_thread: threading.Thread | None = None

    def set_state(new_state: str, reason: str) -> None:
        nonlocal state
        old_state = state
        state = new_state
        print(f"state: {old_state} -> {new_state} ({reason})")

    def aggregate_ocr_text(session_dir: Path) -> str:
        text_parts: list[str] = []
        for text_file in sorted(session_dir.glob("ocr/**/recognized.txt")):
            content = text_file.read_text(encoding="utf-8").strip()
            if content:
                text_parts.append(content)
        return "\n".join(text_parts)

    def wait_for_file(path: Path, wait_timeout: float = 10.0) -> Path | None:
        deadline = time.monotonic() + wait_timeout
        stable_count = 0
        last_size = -1
        while time.monotonic() < deadline:
            if path.exists():
                size = path.stat().st_size
                if size > 0 and size == last_size:
                    stable_count += 1
                    if stable_count >= 2:
                        return path
                else:
                    stable_count = 0
                    last_size = size
            time.sleep(0.5)
        return None

    def upload_payload(audio_src: Path, audio_stem: str, ocr_text: str) -> bool:
        if not remote_host:
            print("remote host not configured; skipping upload")
            return False

        audio_name = f"{audio_stem}.wav"
        json_name = f"{audio_stem}.json"
        json_path = audio_src.with_suffix(".json")
        payload = {
            "mode": remote_mode,
            "ocr_text": ocr_text,
            "audio": f"input/from_software_a/{audio_name}",
        }
        json_path.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

        remote_audio_target = f"{remote_user}@{remote_host}:{remote_input_dir}/{audio_name}"
        remote_json_target = f"{remote_user}@{remote_host}:{remote_input_dir}/{json_name}"

        print(f"uploading audio first: {audio_src} -> {remote_audio_target}")
        subprocess.run(["scp", str(audio_src), remote_audio_target], check=True)
        print(f"uploading json last: {json_path} -> {remote_json_target}")
        subprocess.run(["scp", str(json_path), remote_json_target], check=True)
        return True

    def session_generated_wav(session_dir: Path | None, audio_stem: str | None) -> Path | None:
        if session_dir is None or audio_stem is None:
            return None
        generated_dir = session_dir / "generated"
        if not generated_dir.exists():
            return None
        expected = generated_dir / f"{audio_stem}.wav"
        if expected.exists():
            return expected
        candidates = sorted(
            generated_dir.glob(f"{audio_stem}*.wav"),
            key=lambda p: p.stat().st_mtime,
        )
        return candidates[-1] if candidates else None

    def finalize_segment_async(session_dir: Path, audio_path: Path, audio_stem: str, ocr_text: str) -> None:
        nonlocal latest_generated_session_dir, latest_generated_audio_stem
        print(f"background finalize started: {audio_path}")
        completed_audio = wait_for_file(audio_path)
        if completed_audio is None:
            print(f"segment did not finalize audio in time: {audio_path}")
            return
        try:
            uploaded = upload_payload(completed_audio, audio_stem, ocr_text)
        except subprocess.CalledProcessError as exc:
            print(f"upload failed: {exc}")
        else:
            if uploaded:
                latest_generated_session_dir = session_dir
                latest_generated_audio_stem = audio_stem
                print(f"upload completed: {completed_audio}")

    def normalize_line(line: str) -> str | None:
        cleaned = "".join(ch for ch in line.upper() if ch.isalnum())
        direct_map = {
            "B1ON": "B1 ON",
            "B1OFF": "B1 OFF",
            "B2ON": "B2 ON",
            "B2OFF": "B2 OFF",
        }
        if cleaned in direct_map:
            return direct_map[cleaned]
        if cleaned in {"BOF", "B10FF"}:
            return "B1 OFF"
        if cleaned in {"B2OF", "B20FF", "2OFF", "2OF", "B2F"}:
            return "B2 OFF"
        if cleaned in {"B20N", "2ON", "B2N"}:
            return "B2 ON"
        return None

    def stop_playback() -> None:
        nonlocal playback_proc, playback_thread
        if playback_proc is None and playback_thread is None:
            print("playback already stopped")
            return
        playback_stop_event.set()
        if playback_proc is not None and playback_proc.poll() is None:
            print("stopping playback")
            try:
                os.killpg(playback_proc.pid, signal.SIGINT)
                print(f"killpg sent: SIGINT to playback pgid={playback_proc.pid}")
            except ProcessLookupError:
                print("killpg skipped: playback process group already gone")
            try:
                playback_proc.wait(timeout=5)
                print("playback process exited after SIGINT")
            except subprocess.TimeoutExpired:
                try:
                    os.killpg(playback_proc.pid, signal.SIGKILL)
                    print(f"killpg sent: SIGKILL to playback pgid={playback_proc.pid}")
                except ProcessLookupError:
                    print("killpg skipped: playback process group already gone before SIGKILL")
                playback_proc.wait(timeout=3)
                print("playback process exited after SIGKILL")
        playback_proc = None
        if playback_thread is not None:
            playback_thread.join(timeout=2)
            playback_thread = None

    def playback_loop(wav_path: Path) -> None:
        nonlocal playback_proc
        print(f"playback loop started: {wav_path}")
        while not playback_stop_event.is_set():
            playback_proc = subprocess.Popen(
                ["pw-play", "--target", playback_target, str(wav_path)],
                start_new_session=True,
            )
            try:
                playback_proc.wait()
            finally:
                playback_proc = None
            if playback_stop_event.is_set():
                break
            print("playback loop: restarting track")
        print("playback loop stopped")

    def start_playback() -> None:
        nonlocal playback_thread
        wav_path = session_generated_wav(latest_generated_session_dir, latest_generated_audio_stem)
        if wav_path is None:
            if latest_generated_session_dir is None or latest_generated_audio_stem is None:
                print("no uploaded segment tracked yet; ignoring B2 ON")
            else:
                print(
                    "no generated wav found for tracked segment: "
                    f"{latest_generated_session_dir}/generated/{latest_generated_audio_stem}.wav"
                )
            return
        if playback_thread is not None and playback_thread.is_alive():
            print("playback already running; restarting tracked segment")
            stop_playback()
        playback_stop_event.clear()
        print(
            "starting looping playback for tracked segment "
            f"{latest_generated_audio_stem}: {wav_path}"
        )
        playback_thread = threading.Thread(target=playback_loop, args=(wav_path,), daemon=True)
        playback_thread.start()

    def stop_segment_recording(upload: bool) -> None:
        nonlocal segment_proc, current_segment_stem, current_segment_path
        if segment_proc is None or current_segment_stem is None or current_segment_path is None:
            print("segment recording already stopped")
            return
        audio_path = current_segment_path
        audio_stem = current_segment_stem
        ocr_text = aggregate_ocr_text(current_session_dir) if current_session_dir is not None else ""
        print("received valid B2 OFF")
        print(highlight_red(f"[B2 OFF] stopping segment recording: {audio_stem}"))
        if segment_proc.poll() is None:
            try:
                os.killpg(segment_proc.pid, signal.SIGINT)
                print(f"killpg sent: SIGINT to segment pgid={segment_proc.pid}")
            except ProcessLookupError:
                print("killpg skipped: segment process group already gone")
            try:
                segment_proc.wait(timeout=2)
                print("segment process exited after SIGINT")
            except subprocess.TimeoutExpired:
                print("segment process still alive after SIGINT; sending SIGTERM")
                try:
                    os.killpg(segment_proc.pid, signal.SIGTERM)
                    print(f"killpg sent: SIGTERM to segment pgid={segment_proc.pid}")
                except ProcessLookupError:
                    print("killpg skipped: segment process group already gone before SIGTERM")
                try:
                    segment_proc.wait(timeout=2)
                    print("segment process exited after SIGTERM")
                except subprocess.TimeoutExpired:
                    print("segment process still alive after SIGTERM; sending SIGKILL")
                    try:
                        os.killpg(segment_proc.pid, signal.SIGKILL)
                        print(f"killpg sent: SIGKILL to segment pgid={segment_proc.pid}")
                    except ProcessLookupError:
                        print("killpg skipped: segment process group already gone before SIGKILL")
                    segment_proc.wait(timeout=3)
                    print("segment process exited after SIGKILL")
        segment_proc = None
        current_segment_stem = None
        current_segment_path = None
        if not upload:
            print("segment recording stopped without upload")
            return
        if current_session_dir is None:
            print("no active session directory for segment upload")
            return
        print(f"queue background finalize for segment: {audio_path}")
        upload_thread = threading.Thread(
            target=finalize_segment_async,
            args=(current_session_dir, audio_path, audio_stem, ocr_text),
            daemon=True,
        )
        upload_threads.append(upload_thread)
        upload_thread.start()

    def start_segment_recording() -> None:
        nonlocal segment_proc, current_segment_stem, current_segment_path, segment_used_in_session
        if state != STATE_COLLECTING:
            print(f"segment recording unavailable while state={state}")
            return
        if current_session_dir is None or current_session_stem is None:
            print("no active collection session; ignoring B2 ON")
            return
        if segment_proc is not None and segment_proc.poll() is None:
            print("segment recording already running; ignoring B2 ON")
            return
        if segment_used_in_session:
            print("B2 segment already used for this session; ignoring B2 ON")
            return
        current_segment_stem = current_session_stem
        segments_dir = current_session_dir / "segments"
        segments_dir.mkdir(parents=True, exist_ok=True)
        current_segment_path = segments_dir / f"{current_segment_stem}.wav"
        segment_used_in_session = True
        print(highlight_red(f"[B2 ON] starting segment recording: {current_segment_path}"))
        segment_proc = subprocess.Popen(
            [
                "ffmpeg",
                "-hide_banner",
                "-loglevel",
                "warning",
                "-nostdin",
                "-f",
                "pulse",
                "-i",
                segment_audio_input,
                "-af",
                f"volume={segment_audio_gain}",
                str(current_segment_path),
            ],
            start_new_session=True,
        )

    def stop_collection() -> None:
        nonlocal collection_proc, last_b1_stop_time, current_session_dir, current_session_stem
        if collection_proc is None:
            set_state(STATE_IDLE, "stop requested without active collection")
            return
        print("received valid B1 OFF")
        set_state(STATE_STOPPING, "B1 OFF received")
        if segment_proc is not None:
            stop_segment_recording(upload=True)
        if collection_proc.poll() is None:
            print("stopping collection process")
            try:
                os.killpg(collection_proc.pid, signal.SIGINT)
                print(f"killpg sent: SIGINT to pgid={collection_proc.pid}")
            except ProcessLookupError:
                print("killpg skipped: process group already gone")
            try:
                collection_proc.wait(timeout=10)
                print("collection process exited after SIGINT")
            except subprocess.TimeoutExpired:
                print("collection process did not exit after SIGINT; sending SIGKILL")
                try:
                    os.killpg(collection_proc.pid, signal.SIGKILL)
                    print(f"killpg sent: SIGKILL to pgid={collection_proc.pid}")
                except ProcessLookupError:
                    print("killpg skipped: process group already gone before SIGKILL")
                collection_proc.wait(timeout=5)
                print("collection process exited after SIGKILL")
        collection_proc = None
        current_session_dir = None
        current_session_stem = None
        print("collection fully stopped")
        last_b1_stop_time = time.monotonic()
        set_state(STATE_IDLE, "collection fully stopped")

    def start_collection() -> None:
        nonlocal collection_proc, current_session_dir, current_session_stem, segment_used_in_session
        if state == STATE_STOPPING:
            print("collection is stopping; ignoring B1 ON")
            return
        if state == STATE_COLLECTING and collection_proc is not None and collection_proc.poll() is None:
            print("collection already running; ignoring B1 ON")
            return
        elapsed = time.monotonic() - last_b1_stop_time
        if elapsed < restart_cooldown:
            remaining = restart_cooldown - elapsed
            print(f"waiting {remaining:.1f}s before restarting collection")
            time.sleep(remaining)
        stop_playback()
        current_session_stem = "session-" + datetime.now().strftime("%Y%m%d-%H%M%S")
        current_session_dir = collection_root / current_session_stem
        segment_used_in_session = False
        print("starting collection process")
        print(f"current session: {current_session_dir}")
        env = os.environ.copy()
        env["CAMERA_OCR_SESSION_NAME"] = current_session_stem
        env["CAMERA_OCR_AUDIO_INPUT"] = "none"
        collection_proc = subprocess.Popen(
            shlex.split(b1_command),
            env=env,
            start_new_session=True,
        )
        set_state(STATE_COLLECTING, "collection process started")

    def cleanup(*_args) -> None:
        if segment_proc is not None:
            stop_segment_recording(upload=False)
        stop_collection()
        stop_playback()
        for thread in upload_threads:
            thread.join(timeout=0.5)
        sys.exit(0)

    signal.signal(signal.SIGINT, cleanup)
    signal.signal(signal.SIGTERM, cleanup)

    while True:
        try:
            with serial.Serial(device, baudrate, timeout=1) as ser:
                print("serial connected")
                while True:
                    line = ser.readline().decode("utf-8", errors="replace").strip()
                    if not line:
                        continue
                    print(f"serial: {line}")
                    event = normalize_line(line)
                    if event is None:
                        print("serial: ignored malformed input")
                        continue
                    print(f"serial: normalized event={event} state={state}")
                    if event == "B1 ON":
                        if state != STATE_IDLE:
                            print(f"serial: ignored B1 ON while state={state}")
                            continue
                        start_collection()
                    elif event == "B1 OFF":
                        if state != STATE_COLLECTING:
                            print(f"serial: ignored B1 OFF while state={state}")
                            continue
                        stop_collection()
                    elif event == "B2 ON":
                        if state == STATE_COLLECTING:
                            start_segment_recording()
                        elif state == STATE_IDLE:
                            start_playback()
                        else:
                            print(f"serial: ignored B2 ON while state={state}")
                    elif event == "B2 OFF":
                        if state == STATE_COLLECTING:
                            stop_segment_recording(upload=True)
                        elif state == STATE_IDLE:
                            stop_playback()
                        else:
                            print(f"serial: ignored B2 OFF while state={state}")
        except serial.SerialException as exc:
            print(f"serial error: {exc}")
            time.sleep(1)


if __name__ == "__main__":
    raise SystemExit(main())
