with import <nixpkgs> {};

let
    buildNodeModules = callPackage ../../buildNodeModules.nix {npm = nodePackages.npm;};
    node_modules = import ./node_modules.nix {inherit buildNodeModules nodejs;};
    typescript-app = callPackage ./default.nix {inherit nodejs node_modules;};
in
    mkShell {
        buildInputs = [
            typescript-app
        ];
        shellHook = ''
            ln -s ${node_modules} node_modules
        '';
    }
