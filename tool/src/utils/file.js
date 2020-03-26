const fs = require('fs');
const util = require('util');

module.exports.fileExists = util.promisify(fs.exists);