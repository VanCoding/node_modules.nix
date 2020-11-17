{lib,runCommand,coreutils,fetchurl,unixtools,writeText}:
{packageLockPath,patches}:
let
	json = builtins.readFile packageLockPath;
	packageLock = builtins.fromJSON json;
	base64toHex = import ./base64toHex.nix;

	# take a tarball and create a patched tarball in the same format
	patchTarball = {tarball,patch}:
		let
			derivation = runCommand "patched-package" {buildInputs=[coreutils unixtools.xxd];} ''
				tar -xzf ${tarball.tarball} package
				${patch}
				mkdir $out
				tar -cf $out/tarball.tgz --xform 's:^\./::' package
				sha512sum $out/tarball.tgz | cut -d " " -f 1 > $out/sha512.hex
				xxd -r -p < $out/sha512.hex | base64  -w 0  > $out/sha512.base64
			'';
		in {
			algorithm = builtins.trace "${derivation}" "sha512";
			base64hash = builtins.readFile "${derivation}/sha512.base64";
			hexHash = builtins.readFile "${derivation}/sha512.hex";
			tarball = "${derivation}/tarball.tgz";
		}
	;
	
	# get a flat list of all depencency specs
	getFlatSpecs = dependencies:
		builtins.concatLists (lib.attrsets.mapAttrsToList (name: spec: [spec]++(if spec ? dependencies then getFlatSpecs spec.dependencies else [])) dependencies)
	;

	# convert a dependency spec into a tarball with additional information
	getTarballFromSpec = spec:
		let
			parts = lib.strings.splitString "-" spec.integrity;
		in rec {
			algorithm = builtins.elemAt parts 0;
			base64hash = builtins.elemAt parts 1;
			hexHash = base64toHex base64hash;
			tarball = fetchurl {
				url = spec.resolved;
				"${algorithm}" = hexHash;
			};
		}
	;

	# get the command to create the cache entry for this tarball
	getCommandFromTarball = {algorithm,hexHash,tarball,...}:
		let
			folder1 = builtins.substring 0 2 hexHash;
			folder2 = builtins.substring 2 2 hexHash;
			fileName = builtins.substring 4 ((builtins.stringLength hexHash)-4) hexHash;
			folderPath = "$out/_cacache/content-v2/${algorithm}/${folder1}/${folder2}";
		in
			"mkdir -p ${folderPath} && cd ${folderPath} && ln -sf ${tarball} ${fileName}"
	;

	# flat list of all dependency specs
	dependencies = getFlatSpecs packageLock.dependencies;

	# flat list of all tarballs
	tarballs = builtins.map getTarballFromSpec dependencies;

	# an index of all tarballs by their base64 hash
	tarballsByBase64Hash = builtins.listToAttrs (builtins.map (tarball: {name = tarball.base64hash; value = tarball;}) tarballs);

	# an index of all patched tarballs by their base64 hash
	patchedTarballs = lib.attrsets.mapAttrs (hash: patch: patchTarball {tarball = tarballsByBase64Hash."${hash}"; inherit patch;}) patches;

	# all commands to create the cache
	commands = builtins.concatStringsSep "\n" (builtins.map getCommandFromTarball (builtins.map (tarball: if builtins.hasAttr tarball.base64hash patchedTarballs then patchedTarballs."${tarball.base64hash}" else tarball) tarballs));
in {
	cache = runCommand "cache" {buildInputs = [coreutils];} ''
		${commands}
	'';

	# when we patch packages, we also need to return a new package-lock.json because the hashes changed
	packageLock = writeText "package-lock.json" ( builtins.foldl' (json: hash: builtins.replaceStrings [hash] [patchedTarballs."${hash}".base64hash] json) json (builtins.attrNames patches));
}
