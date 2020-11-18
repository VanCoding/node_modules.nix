{pkgs?import<nixpkgs> {}}:with pkgs;
let
    buildNodeModules = callPackage ../../buildNodeModules.nix {};
in rec {
    node_modules = buildNodeModules {directory = ./.;buildInputs=[python];};
    app = runCommand "compile-sass" {buildInputs=[nodejs];} ''
        mkdir -p $out/bin
        ln -s ${node_modules}/.bin/node-sass $out/bin/compile-sass
    '';
    shell = mkShell {
        buildInputs = [app];
        shellHook = ''
            export PATH=$PATH:$PWD/node_modules/.bin
            ln -sfn ${node_modules} node_modules
        '';
    };
}
