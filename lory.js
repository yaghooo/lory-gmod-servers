const { promises: fs } = require("fs");
const path = require("path");

function setProduction(v) {
	process.env["PRODUCTION"] = Number(v);
}

async function mkdirOrIgnore(dir) {
	try {
		await fs.mkdir(dir);
	} catch (e) {}
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

	env = env || "prod";
	console.log(`Building servers on ${env} mode`);

	const buildDir = path.resolve(serversDir, "_build");
	await mkdirOrIgnore(buildDir);

	const stateDir = path.resolve(serversDir, "_stateful");
	await mkdirOrIgnore(stateDir);

	for (const serverName of serversToBuild) {
		const serverBuildDir = path.resolve(buildDir, serverName);
		await mkdirOrIgnore(serverBuildDir);

		const serverStateDir = path.resolve(stateDir, serverName);
		await mkdirOrIgnore(serverStateDir);
		await fs.writeFile(path.resolve(serverStateDir, "sv.db"), "");
		await fs.writeFile(path.resolve(serverStateDir, "debug.log"), "");

		const sharedDir = path.resolve(serversDir, "_shared");
		await mergeDirs(sharedDir, serverBuildDir);

		if (env === "dev") {
			const debugDir = path.resolve(serversDir, "_debug");
			await mergeDirs(debugDir, serverBuildDir);
			setProduction(false);
		} else {
			setProduction(true);
		}

		await mergeDirs(path.resolve(serversDir, serverName), serverBuildDir);
		console.log(`Successfully built server ${serverName}`);
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
