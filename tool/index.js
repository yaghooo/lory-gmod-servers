const toml = require('toml')
const path = require('path')
const fs = require('fs')
const rimraf = require('rimraf')
const copy = require('recursive-copy')
const glob = require('glob');

const deleteIfExists = pathToCheck =>
    new Promise(resolve => rimraf(pathToCheck, resolve))

const addAddons = async (serverName, addonsPath, exclude) => {
    let addons = await fs.promises.readdir(addonsPath)

    if (exclude) {
        addons = addons.filter(addon => !exclude.includes(addon))
    }
    
    const buildDataPath = path.resolve(__dirname, `../build/${serverName}/data`)

    for (const addon of addons) {
        await copy(path.resolve(addonsPath, addon), path.resolve(__dirname, `../build/${serverName}/addons/${addon}`), {
            filter: /^(?!data).*$/
        })

        const dataPath = path.resolve(addonsPath, addon, 'data')

        if (fs.existsSync(dataPath)) {
            await copy(dataPath, buildDataPath)
        }
    }
}

const replaceVariables = async (serverName) => {
    const getAllTextFiles = dir => new Promise(resolve => {
        glob(dir + '/**/*.txt', {}, (err, files) => {
            resolve(files);
        })
    });

    const buildDataPath = path.resolve(__dirname, `../build/${serverName}/data`)
    const textFiles = await getAllTextFiles(buildDataPath);

    for (const file of textFiles) {
        const content = await fs.promises.readFile(file, 'utf-8');
        const newContent = content.replace(/\{\{(.*)\}\}/g, (_, variable) => {
            const environmentVariable = process.env[variable];
            if (environmentVariable === undefined) {
                console.warn(`Environment variable not found for key '${variable}'`);
            }
            return environmentVariable;
        })
        await fs.promises.writeFile(file, newContent, 'utf-8');
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

        await replaceVariables(server);

        console.log(`Build for ${server} succeed`)
    }
})()
