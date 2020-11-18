{pkgs?import<nixpkgs> {}}:with pkgs;
let
    buildNodeModules = callPackage ../../buildNodeModules.nix {};
in rec {
    node_modules = buildNodeModules {
        directory = ./.;
        buildInputs=[python vips glib.dev pkg-config];
        patches = {
            "NdEJ9S6AMr8Px0zgtFo1TJjMK/ROMU92MkDtYn2BBrDjIx3YfH9TUyGdzPC+I/L619GeYQc690Vbaxc5FPCCWg==" = ''
                cp ${./binding.gyp} package/binding.gyp
            '';
        };
    };
    app = runCommand "convert-image" {buildInputs=[nodejs];} ''
        mkdir -p $out/bin
        ln -s ${node_modules} $out/node_modules
        cp ${./convert-image.js} $out/convert-image.js
        echo '#!node
        require("../convert-image");' > $out/bin/convert-image
        chmod +x $out/bin/convert-image
    '';
    shell = mkShell {
        buildInputs = [app];
        shellHook = ''
            ln -sfn ${node_modules} node_modules
        '';
    };
}
