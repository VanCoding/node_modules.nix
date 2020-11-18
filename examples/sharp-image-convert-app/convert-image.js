const sharp = require("sharp");

if (process.argv.length <= 2) {
  console.log("convert-image [input-file] [output-file]");
  return;
}
sharp(process.argv[2]).toFile(process.argv[3]);
