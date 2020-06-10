const toml = require('toml')
const path = require('path')
const fs = require('fs')
const rimraf = require('rimraf')
const copy = require('recursive-copy')

const deleteIfExists = pathToCheck =>
    new Promise(resolve => rimraf(pathToCheck, resolve))

const addAddons = async (serverName, addonsPath, exclude) => {
    let addons = await fs.promises.readdir(addonsPath)

    if (exclude) {
        addons = addons.filter(addon => !exclude.includes(addon))
    }

    for (const addon of addons) {
        // TODO: Remove data folder from addon
        await copy(path.resolve(addonsPath, addon), path.resolve(__dirname, `../build/${serverName}/addons/${addon}`))

        const dataPath = path.resolve(addonsPath, addon, 'data')
        if (fs.existsSync(dataPath)) {
            await copy(dataPath, path.resolve(__dirname, `../build/${serverName}/data`))
        }
    }
}

(async () => {
    const scheme = toml.parse(fs.readFileSync('../servers/.server-scheme.toml'))
    const options = process.argv.slice(2)

    const servers = options.filter((s) => !s.startsWith('--'))

    await deleteIfExists(path.resolve(__dirname, '../build'))

    for (const server of servers) {
        const config = scheme.servers.find(cfg => cfg.name === server)
        if (!config) {
            throw new Error('Server configurations not found')
        }

        await addAddons(server, path.resolve(__dirname, '../servers', '_shared'), config.exclude)
        await addAddons(server, path.resolve(__dirname, '../servers', server), config.exclude)

        console.log(`Build for ${server} succeed`)
    }
})()
