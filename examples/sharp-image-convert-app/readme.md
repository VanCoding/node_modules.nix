#sharp-image-convert-app example

## using

1. run `nix-shell`
1. the `sharp` package is now installed in the `node_modules` directory. You can import and use it in any file.
1. run `convert-image image.png image.jpg` to start the example app

## notes

In this example, it was necessary to patch the tarball of the sharp package. The binding.gyp file does not work with nix and will not find glib. So we need to patch it.
