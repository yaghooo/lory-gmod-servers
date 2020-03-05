if [ -z "$1" ]; then
    echo "Please specify the image name."
else
    echo "Building image for '$1'..."
    # BUILD IMAGE
    docker build . -t ceifa/lory-gmod-"$1" -f ./servers/$1/Dockerfile
fi

echo "Done."
# WAIT FOR INPUT, USEFUL TO SEE UNEXPECTED ERRORS
read