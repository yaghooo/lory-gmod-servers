const { promises: fs } = require("fs");
const path = require("path");

function setProduction(v) {
    process.env['PRODUCTION'] = Number(v);
}

async function mkdirOrIgnore(dir) {
    try {
        await fs.mkdir(dir);
    } catch (e) {
        if (e.errno !== -4075) {
            throw e;
        }
    }
}

async function mergeDirs(src, dest) {
    const files = await fs.readdir(src);

    for (const file of files) {        
        const srcFile = path.resolve(src, file);
        const destFile = path.resolve(dest, file);
        
        const stats = await fs.lstat(srcFile);        
        if (stats.isDirectory()) {
            await mkdirOrIgnore(destFile);
            await mergeDirs(srcFile, destFile);
        } else {
            await fs.writeFile(destFile, await fs.readFile(srcFile));
        }
    }
}

async function build([servers, env]) {
    const serversDir = path.resolve(__dirname, "servers");

    let serversToBuild = [];
    if (!servers || servers === "*") {
        const serversDirs = await fs.readdir(serversDir);
        serversToBuild = serversDirs.filter(s => !s.startsWith("_"));
    } else {
        serversToBuild = servers.split(",");
    }

    const buildDir = path.resolve(serversDir, "_build");
    await mkdirOrIgnore(buildDir);

    for (const serverName of serversToBuild) {
        const serverBuildDir = path.resolve(buildDir, serverName);
        await mkdirOrIgnore(serverBuildDir);

        const sharedDir = path.resolve(serversDir, "_shared");
        await mergeDirs(sharedDir, serverBuildDir);

        const isDev = env === "dev";
        if (isDev) {
            const debugDir = path.resolve(serversDir, "_debug");
            await mergeDirs(debugDir, serverBuildDir);
        }
    
        setProduction(!isDev);

        await mergeDirs(path.resolve(serversDir, serverName), serverBuildDir);
    }
}

async function start([servers, env]) {
    await build([servers, env || "dev"]);
}

const actions = {
    start,
    build
};

const [chosenAction, ...actionArgs] = process.argv.slice(2);

(async () => {
    if (chosenAction in actions) {
        await actions[chosenAction](actionArgs);
    } else {
        console.error(`Action "${chosenAction}" not found`);
    }
})();