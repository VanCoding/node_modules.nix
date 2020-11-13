{lib,stdenv,runCommand,coreutils,fetchurl,npm}:
{directory,buildInputs?[]}:
let
    buildCache = import ./buildCache.nix {inherit lib runCommand coreutils fetchurl;};
    cache = buildCache {packageLockPath = "${directory}/package-lock.json";};
    derivation = stdenv.mkDerivation {
        pname = "node_modules";
        version = "";
        buildInputs=[npm coreutils]++buildInputs;
        phases = ["buildPhase" "patchPhase" "fixupPhase" ];
        buildPhase = ''
            cp ${directory}/package-lock.json ./package-lock.json
            cp ${directory}/package.json ./package.json
            npm ci --cache ${cache}
            mkdir $out
            mv node_modules $out/node_modules/
        '';
    };
in
    "${derivation}/node_modules"
