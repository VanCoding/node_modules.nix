# node_modules.nix

This is a nix library that can turn your package-lock.json into a fully populated node_modules directory. You can then symlink this directory into your Node.js application and it will behave like you installed it using `npm ci`.

## how it works

Under the hood, node_modules.nix calls `npm ci`. But because npm cannot fetch packages from the internet inside the nix sandbox, an npm package cache gets constructed first and then handed over to npm for usage. npm will find every single package inside this cache and thus won't have to download anything. It's basically the same as when calling `npm ci` twice in a row. On the first time, npm caches everything it downloads, on the second time it gets everything from the cache.

## advantages over node2nix

- In node2nix, you'll have to run a script to generate a nix-expression everytime modify your package.json file. With node_modules.nix, this is not necessary. You can directly use the package-lock.json file.

## limitations

- packages that download additional stuff at installation time won't work
- probably a lot more stuff, let me know in an issue

## project status

This is just a proof of concept for now to show to people and to get some feedback. Don't use it in anything serious.

## contributing

I'm looking for feedback to this idea. I'll happily discuss the future of node_modules.nix with you.
There's also some good discussion going on on https://discourse.nixos.org/t/node-modules-nix/10004

## similar projects

It turned out that there are 2 projects that do basically the same as node_modules.nix:

- [npmlock2nix](https://github.com/tweag/npmlock2nix)
- [nix-npm-buildpackage](https://github.com/serokell/nix-npm-buildpackage)

## license

MIT
