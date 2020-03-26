const util = require('util');
const child_process = require('child_process');
const exec = util.promisify(child_process.exec);
const logger = require('../utils/logger');

const updatePackageSources = async () => {
    const { stdout } = await exec('apt-get update');
    logger.trace(stdout);
}

const installPackage = async name => {
    const { stdout } = await exec(`apt-get install -y --no-install-recommends --no-install-suggests ${name}`)
    logger.trace(stdout)
}

module.exports.installLinuxPackages = async (next, state) => {
    await updatePackageSources();

    const packages = [
        'lib32ncurses5',
        'lib32gcc1',
        'lib32stdc++6',
        'lib32tinfo5',
        'ca-certificates',
        'screen',
        'tar',
        'bzip2',
        'gzip',
        'unzip',
        'git'
    ];

    if (state.dev) {
        packages.push('gdb');
    }

    for (const package of packages) {
        await installPackage(package);
    }

    next(state);
};