{nodejs,node_modules,runCommand}:
runCommand "typescript-app" {buildInputs=[nodejs];} ''
    mkdir $out
    cp -r ${./.}/* ./
    ln -s ${node_modules} node_modules
    npm run build
    cp ./app.js $out/app.js
    mkdir $out/bin
    echo '#!node
    require("../app")' > $out/bin/typescript-app
    chmod +x $out/bin/typescript-app
''
