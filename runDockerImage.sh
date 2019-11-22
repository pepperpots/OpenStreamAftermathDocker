#!/bin/bash

container_name=OpenStreamInteractive
image_name=syllo/openstream-aftermath

if container_running_state=$(docker inspect -f '{{.State.Running}}' "$container_name" 2>/dev/null)
then
    # The container exists but may be detached
    case "$container_running_state" in
        "false")
            docker container start "$container_name" > /dev/null
        ;;
        *)
        ;;
    esac
    docker container attach "$container_name"
else
    # The container does not exist, lets create a new one
    docker run -ti --mount "type=bind,src=$HOME,target=/home/pepperpots/yourUserHomeDir" --name="$container_name" "$image_name"
fi