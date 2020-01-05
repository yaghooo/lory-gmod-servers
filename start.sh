NAME="lory-gmod-$1"

# CHECK IF CONTAINER ALREADY EXISTS
if [ "$(docker ps -a -q -f name="${NAME}" --format '{{.Names}}')" == "${NAME}" ]; then
    # CHECK IF THE CONTAINER IS RUNNING
    if [ "$(docker ps -q -f name="${NAME}" --format '{{.Names}}')" == "${NAME}" ]; then
        docker stop "${NAME}" -t 0
    fi

    docker rm "${NAME}"
fi

mkdir ./stateful/$1
cp -r ./shared/* ./stateful/$1/
cp -r ./$1/src/* ./stateful/$1/
touch ./stateful/$1/sv.db

# START CONTAINER
docker run \
    -p 27015:27015/udp \
    -p 27015:27015 \
    -v $PWD/stateful/$1/data:/server/garrysmod/data \
    -v $PWD/stateful/$1/sv.db:/server/garrysmod/sv.db \
    -v $PWD/stateful/cache:/server/garrysmod/cache \
    -it \
    --name "${NAME}" \
    ceifa/"${NAME}"

# WAIT FOR INPUT, USEFUL TO SEE UNEXPECTED ERRORS
read