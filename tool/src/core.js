const path = require('path');
const Pipen = require('./utils/pipen');
const logger = require('./utils/logger');
const packages = require('./pipeline/packages');
const steam = require('./pipeline/steam');
const code = require('./pipeline/code');
const file = require('./utils/file');

module.exports = {
    start: async args => {
        args.dir = path.resolve(args.dir, process.cwd());

        await new Pipen()
            .pipe(packages.installLinuxPackages)
            .pipe(steam.installSteamCmd)
            .pipe(async (next, state) => {
                state.serversDir = path.resolve(state.dir, 'server');
                if (!await file.fileExists(state.serversDir)) {
                    await fs.promises.mkdir(serverDir);
                }

                const servers = typeof state.servers === 'string' ? [state.servers] : state.servers;
                for (const server of servers) {
                    next({ ...state, serverName: server });
                }
            })
            .pipe(steam.installServer)
            .pipe({
                action: async (next, state) => {
                    state.mountsDir = path.resolve(state.dir, 'mounts');
                    if (!await file.fileExists(state.mountsDir)) {
                        await fs.promises.mkdir(state.mountsDir);
                    }

                    state.mounts = [
                        {
                            appId: 232330,
                            name: 'cstrike'
                        }
                    ]

                    next(state);
                },
                max: 1
            })
            .pipe(steam.installMounts)
            .pipe(code.downloadCode)
            .middleware((state, i) => {
                logger.trace(`Finished pipe #${i}, current state => ${JSON.stringify(state)}`)
            })
            .start(args);
    }
}