{
  lib,
  stdenv,
  makeWrapper,
  mpv,
  ffmpeg,
  protobuf ? python312Packages.protobuf,
  python312Packages,
  src,
}:
let
  python = python312Packages.python;
  sitePackages = python.sitePackages;
  deps = [
    python312Packages.emoji
    python312Packages.filetype
    python312Packages.numpy
    python312Packages.orjson
    protobuf
    python312Packages.pycryptodome
    python312Packages.pynacl
    python312Packages.pysocks
    python312Packages."python-socks"
    python312Packages.qrcode
    python312Packages.soundcard
    python312Packages.soundfile
    python312Packages.urllib3
    python312Packages."websocket-client"
  ];
  pythonPath = lib.makeSearchPath sitePackages deps;
in
stdenv.mkDerivation rec {
  pname = "endcord";
  version = "unstable";

  inherit src;

  nativeBuildInputs = [
    makeWrapper
    python
    python312Packages.cython
    python312Packages.setuptools
  ];

  propagatedBuildInputs = deps;

  buildPhase = ''
    runHook preBuild

    ${python.interpreter} setup.py build_ext --inplace

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/share/endcord"
    cp -r endcord endcord_cython main.py "$out/share/endcord/"

    makeWrapper ${python.interpreter} "$out/bin/endcord" \
      --add-flags "$out/share/endcord/main.py" \
      --prefix PATH : ${
        lib.makeBinPath [
          ffmpeg
          mpv
        ]
      } \
      --prefix PYTHONPATH : "${pythonPath}:$out/share/endcord"

    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "Feature rich Discord TUI client";
    homepage = "https://github.com/sparklost/endcord";
    license = licenses.gpl3Only;
    mainProgram = "endcord";
    platforms = platforms.linux;
  };
}
