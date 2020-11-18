{pkgs?import <nixpkgs> {}}: with pkgs;
let
    buildNodeModules = callPackage ../../buildNodeModules.nix {};
in rec {
    node_modules = buildNodeModules {directory = ./.;};
    app = runCommand "typescript-app" {buildInputs=[nodejs];} ''
        mkdir $out
        cp -r ${./src} src
        cp ${./tsconfig.json} tsconfig.json
        cp ${./package.json} package.json
        ln -s ${node_modules} node_modules
        npm run build
        cp ./app.js $out/app.js
        mkdir $out/bin
        echo '#!node
        require("../app")' > $out/bin/typescript-app
        chmod +x $out/bin/typescript-app
    '';
    shell = mkShell {
        buildInputs = [app];
        shellHook = ''
            export PATH=$PATH:$PWD/node_modules/.bin
            ln -sfn ${node_modules} node_modules
        '';
    };
}
