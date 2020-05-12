![Deploy deathrun](https://github.com/ceifa/lory-gmod-servers/workflows/Deploy%20deathrun/badge.svg?branch=master)
![Deploy murder](https://github.com/ceifa/lory-gmod-servers/workflows/Deploy%20murder/badge.svg?branch=master)
![Deploy ttt](https://github.com/ceifa/lory-gmod-servers/workflows/Deploy%20ttt/badge.svg?branch=master)

# Lory Servers for Garry's Mod

## How to configure new addons/servers

Our file structure consists in that way:

```cs
📦 /servers
|__📁_debug // Addons used only on development environment, useful to monitor CPU/Mem
|__📁_shared // Shared addons, all servers can use these addons
|__📁{{server}} // Some server and specific addons for him
|__📃.server-scheme.toml // Server configurations, define which addons a server should have
```

## How to run

Download or clone this repository.

We have a tool to help building the server addons, to use it enter on the repo root path and run the following command in command line:
```
# windows:
cd bin && lory.exe build {server}

# linux:
cd bin && lory build {server}
```

Where `{server}` means to what server you want to build.

After built, your server addons will be in path `build/{server}`, just install it in your addons folder on [your server](https://wiki.facepunch.com/gmod/Downloading_a_Dedicated_Server) or your gmod.

