{
  lib,
  stdenv,
  buildNpmPackage,
  fetchNpmDeps,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  jq,
  nodejs,
  bun,
  libsecret,
}:
# opencodex ships TypeScript that runs on Bun, plus a Node shim (bin/ocx.mjs)
# that execs the Bun runtime it normally pulls in as the `bun` npm dependency.
# That dependency is a stub whose postinstall downloads a ~60MB binary, which
# can never work in a sandboxed build, so we drop it and point the shim at
# nixpkgs' bun through its own documented OPENCODEX_BUN_PATH override.
#
# The published tarball carries no lockfile, so ./package-lock.json is vendored
# here, generated from upstream's package.json with devDependencies and `bun`
# removed. Regenerate it on every version bump:
#
#   jq 'del(.devDependencies) | del(.dependencies.bun)' package.json > /tmp/p/package.json
#   npm install --package-lock-only --prefix /tmp/p
buildNpmPackage (finalAttrs: {
  pname = "opencodex";
  version = "2.75.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@bitkyc08/opencodex/-/opencodex-${finalAttrs.version}.tgz";
    hash = "sha256-uVX2tPxW9umDHUJcajiiRgO1ZH9bx18lKhhf6jUz6DA=";
  };

  # The fetcher only needs the lockfile, and it runs in a stdenv without jq, so
  # it gets its own minimal postPatch rather than sharing the one below.
  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    name = "opencodex-${finalAttrs.version}-npm-deps";
    postPatch = ''
      cp ${./package-lock.json} package-lock.json
    '';
    hash = "sha256-uV2il2xiuCfAYka+Zn0SW8g29LkiJGgQKEo0ekzV/xk=";
  };

  nativeBuildInputs = [
    jq
    makeWrapper
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;

  # @napi-rs/keyring's prebuilt .node talks to the Secret Service.
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    libsecret
  ];

  postPatch = ''
    jq 'del(.devDependencies) | del(.dependencies.bun)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';

  # Nothing to compile: the tarball already carries the built GUI in gui/dist.
  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/opencodex"
    cp -r bin src gui native package.json node_modules "$out/lib/opencodex/"

    makeWrapper ${lib.getExe nodejs} "$out/bin/ocx" \
      --add-flags "$out/lib/opencodex/bin/ocx.mjs" \
      --set OPENCODEX_BUN_PATH ${lib.getExe bun}
    ln -s ocx "$out/bin/opencodex"

    runHook postInstall
  '';

  meta = {
    description = "Universal provider proxy for Codex, Claude Code, Claude Desktop and Grok Build";
    homepage = "https://github.com/lidge-jun/opencodex";
    license = lib.licenses.mit;
    mainProgram = "ocx";
    platforms = lib.platforms.unix;
  };
})
