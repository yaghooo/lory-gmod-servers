const fs = require('fs');
const util = require('util');

const fileExists = module.exports.fileExists = util.promisify(fs.exists);

module.exports.createDirOrIgnore = async dir => {
    if (!await fileExists(dir)) {
        await fs.promises.mkdir(dir);
    }
}