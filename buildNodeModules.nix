{lib,stdenv,runCommand,coreutils,fetchurl,nodejs,writeText,unixtools}:
{directory,buildInputs?[],preInstallScript?"",postInstallScript?"",patches?{}}:
let
    # import the function to build the cache
    buildCache = import ./buildCache.nix {inherit lib runCommand coreutils fetchurl writeText unixtools;};

    # build the cache
    cache = buildCache {packageLockPath = "${directory}/package-lock.json"; inherit patches;};

    # get the Node.js sources needed by native modules
    nodeSources = runCommand "node-sources" {} ''
        tar --no-same-owner --no-same-permissions -xf ${nodejs.src}
        mv node-* $out
    '';

    # build the node_modules directory
    derivation = builtins.trace "${cache.packageLock}" stdenv.mkDerivation {
        pname = "node_modules";
        version = "";
        buildInputs=[nodejs coreutils]++buildInputs;
        phases = ["buildPhase" "patchPhase" "fixupPhase" ];
        buildPhase =  ''
            cp ${cache.packageLock} package-lock.json
            cp ${directory}/package.json ./package.json
            ${preInstallScript}
            npm ci --cache ${cache.cache} --nodedir=${nodeSources}
            ${postInstallScript}
            mkdir $out
            mv node_modules $out/node_modules/
        '';
    };
in
    "${derivation}/node_modules"
