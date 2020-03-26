const logger = require('../utils/logger');
const child_process = require('child_process');
const path = require('path');

const gitUrl = 'https://github.com/ceifa/lory-gmod-servers.git';

module.exports.downloadCode = (next, state) => {
    const installDir = path.resolve(state.dir, 'code');
    const child = child_process.exec(`git clone ${gitUrl} --depth=1 ${installDir}`,
        async (err, stdout, stdin) => {
            if (err) {
                logger.error(`Failed when downloading server code`);
            }

            next(state);
        });

    child.stdout.on('data', logger.trace);
    child.stderr.on('data', logger.error);
};