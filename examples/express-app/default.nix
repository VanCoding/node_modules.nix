{nodejs,node_modules,runCommand}:
runCommand "express-app" {buildInputs=[nodejs];} ''
    mkdir $out
    cp ${./index.js} $out/index.js
    ln -s "${node_modules}" $out/node_modules
    mkdir $out/bin
    echo '#!node
    require("../index.js")' > $out/bin/express-app
    chmod +x $out/bin/express-app
''
