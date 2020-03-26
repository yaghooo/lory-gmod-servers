const path = require('path');
const http = require('http');
const fs = require('fs');
const url = require('url');
const tar = require('tar');
const child_process = require('child_process');
const logger = require('../utils/logger');
const file = require('../utils/file');

const steamCmdLinuxInstallerUri = 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz';

const updateFileTemplate = serverDir => `
@ShutdownOnFailedCommand 0
@NoPromptForPassword 1

login anonymous
force_install_dir ${serverDir}
app_update 4020 validate
quit
`.trim();

const mountsFileTemplate = mounts => `
"mountcfg"
{
${mounts.map(m => `\t"${m.name}"\t"${m.dir}"`).join('\n')}
}`.trim();

module.exports.installSteamCmd = async (next, state) => {
    state.steamCmdInstallDir = path.resolve(state.dir, 'steamcmd');

    if (await file.fileExists(state.steamCmdInstallDir)) {
        if (state.force) {
            logger.trace(`Deleting current steamcmd directory: ${state.steamCmdInstallDir}`)
            await fs.promises.rmdir(state.steamCmdInstallDir, { recursive: true });
        } else {
            logger.trace('Skipping download of steamcmd installer')
            return;
        }
    }

    await fs.promises.mkdir(state.steamCmdInstallDir)
    const fileUrl = url.parse(steamCmdLinuxInstallerUri)

    http.get({
        host: fileUrl.host,
        port: 80,
        path: fileUrl.pathname
    }, res => {
        res.pipe(tar.x({
            cwd: state.steamCmdInstallDir
        }));

        res.on('end', () => {
            state.steamCmdDir = path.resolve(state.steamCmdInstallDir, 'steamcmd.sh');
            next(state);
        });
    });
};

module.exports.installServer = async (next, state) => {
    state.serverDir = path.resolve(state.serversDir, state.serverName);
    if (await file.fileExists(state.serverDir)) {
        if (state.force) {
            logger.trace(`Deleting current server '${state.serverName}' directory: ${state.serverDir}`)
            await fs.promises.rmdir(state.serverDir, { recursive: true });
        } else {
            logger.trace(`Skipping download of server '${state.serverName}'`)
            return;
        }
    }

    await fs.promises.mkdir(state.serverDir);

    state.updateDir = path.resolve(state.serverDir, 'update.txt');
    await fs.promises.writeFile(state.updateDir, updateFileTemplate(state.serverDir));

    const child = child_process.exec(`${state.steamCmdDir} +runscript ${state.updateDir} +quit`, (err, stdout, stdin) => {
        if (err) {
            logger.error('Failed when installing gmod server');
        }

        next(state);
    });

    child.stdout.on('data', chunk => {
        logger.trace(`${state.serverName}: ${chunk}`);
    });

    child.stderr.on('data', chunk => {
        logger.error(`${state.serverName}: ${chunk}`);
    });
}

module.exports.installMounts = async (next, state) => {
    const promises = [];

    for (const mount of state.mounts) {
        mount.dir = path.resolve(state.mountsDir, mount.name);
        if (await file.fileExists(mount.dir)) {
            if (state.force) {
                logger.trace(`Deleting current mount '${mount.name}' directory: ${mount.dir}`)
                await fs.promises.rmdir(mount.dir, { recursive: true });
            } else {
                logger.trace(`Skipping download of mount '${mount.name}'`)
                return;
            }
        }

        promises.push(new Promise(resolve => {
            const child = child_process.exec(`${state.steamCmdDir} +login anonymous +force_install_dir ${mount.dir} +app_update ${mount.appId} validate +quit`,
                async (err, stdout, stdin) => {
                    if (err) {
                        logger.error(`Failed when installing mount ${mount.name}`);
                    }

                    logger.trace(`Finished to download mount ${mount.name}`);
                    resolve();
                });

            child.stdout.on('data', chunk => {
                logger.trace(`${mount.name}: ${chunk}`);
            });

            child.stderr.on('data', chunk => {
                logger.error(`${mount.name}: ${chunk}`);
            });
        }));
    }

    await Promise.all(promises);

    const mountsFileContent = mountsFileTemplate(state.mounts);
    const servers = await fs.promises.readdir(state.serversDir);
    for (const server of servers) {
        const mountCfg = path.resolve(state.serversDir, server, 'garrysmod/cfg', 'mount.cfg')
        await fs.promises.writeFile(mountCfg, mountsFileContent)
    }

    next(state);
};