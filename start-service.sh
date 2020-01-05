# Very ugly but i dont know a better way to do that
# This file deserves to be deleted sometime

if [ -z "$1" ] || [ "$1" == "deathrun" ]; then
    mkdir ./stateful/deathrun
    touch ./stateful/deathrun/sv.db
fi

if [ -z "$1" ] || [ "$1" == "murder" ]; then
    mkdir ./stateful/murder
    touch ./stateful/murder/sv.db
fi

if [ -z "$1" ]; then
    docker-compose build
    docker-compose up
else
    docker-compose build "$1"
    docker-compose up "$1"
fi

read