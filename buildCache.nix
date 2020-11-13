{lib,runCommand,coreutils,fetchurl}:
{packageLockPath}:
let
	json = builtins.readFile packageLockPath;
	dependencies = (builtins.fromJSON json).dependencies;
	base64toHex = import ./base64toHex.nix;
	getTarball = (spec:
		let
			parts = lib.strings.splitString "-" spec.integrity;
			algorithm = builtins.elemAt parts 0;
			base64hash = builtins.elemAt parts 1;
			hexHash = base64toHex base64hash;
			tarball = fetchurl {
				url = spec.resolved;
				"${algorithm}" = hexHash;
			};
			dependencies = if spec ? dependencies then getTarballs spec.dependencies else [];
			folder1 = builtins.substring 0 2 hexHash;
			folder2 = builtins.substring 2 2 hexHash;
			fileName = builtins.substring 4 ((builtins.stringLength hexHash)-4) hexHash;
			folderPath = "$out/_cacache/content-v2/${algorithm}/${folder1}/${folder2}";
			command = "mkdir -p ${folderPath} && cd ${folderPath} && ln -sf ${tarball} ${fileName}";
		in
			[command]++dependencies
	);
	getTarballs = (dependencies:
		builtins.concatLists (lib.attrsets.mapAttrsToList (name: spec: getTarball spec) dependencies)
	);	
	tarballs = getTarballs dependencies;
	command = builtins.concatStringsSep "\n" tarballs;
in
	runCommand "cache" {buildInputs = [coreutils];} ''
		${command}
	''
