{pkgs?import<nixpkgs> {}}:with pkgs;
let
    buildNodeModules = callPackage ../../buildNodeModules.nix {};
in rec {
    node_modules = buildNodeModules {directory = ./.;buildInputs=[python];};
    lib = runCommand "sass-lib" {} ''
        export PATH=$PATH:${node_modules}/.bin
        node-sass ${./src} -o $out
    '';
    shell = mkShell {
        shellHook = ''
            ln -sf ${node_modules} node_modules
        '';
    };
}
