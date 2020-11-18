#sass-compile-app example

## using

1. run `nix-shell`
1. the `node-sass` package is now installed in the `node_modules` directory. You can import and use it in any file.
1. the `node-sass` command that comes with the package is also availabe in the shell
1. run `compile-sass style.scss > style.css` to start the example app

## notes

In this example, the `node-sass` package has native dependencies. Fortunately, it builds from source without any patching.
