FROM ceifa/gmod-server:latest

ADD ./src/addons /server/garrysmod/addons
ADD ./src/gamemodes /server/garrysmod/gamemodes
ADD ./src/cfg/server.cfg /server/cfg/server.cfg

ENV HOSTNAME="[BR] Lory | Deathrun"
ENV ARGS="+host_workshop_collection 382793424"
ENV MAP="deathrun_atomic_warfare"
ENV GAMEMODE="deathrun"
ENV MAXPLAYERS="24"