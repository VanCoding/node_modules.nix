{pkgs?import<nixpkgs> {}}: with pkgs;
let
    buildNodeModules = callPackage ../../buildNodeModules.nix {};
in rec {
    node_modules = buildNodeModules {directory = ./.;};
    app = runCommand "express-app" {buildInputs=[nodejs];} ''
        mkdir $out
        cp ${./index.js} $out/index.js
        ln -s "${node_modules}" $out/node_modules
        mkdir $out/bin
        echo '#!node
        require("../index.js")' > $out/bin/express-app
        chmod +x $out/bin/express-app
    '';
    shell = mkShell {
        buildInputs = [app];
        shellHook = ''
            ln -sfn ${node_modules} node_modules
        '';
    };
}
