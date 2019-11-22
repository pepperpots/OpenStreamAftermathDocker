#!/bin/bash

container_name=OpenStreamInteractive
image_name=openstream-aftermath

docker build -t "$image_name" .

if container_running_state=$(docker inspect -f '{{.State.Running}}' "$container_name" 2>/dev/null)
then
    # The container exists but may be detached
    echo "A container with the name $container_name exists"
    echo "Would you like to remove this container to start using the newly built image (This will erase all local container data)? [y/N]:"
    read value
    case "$value" in
        y|Y)
            erase=y
        ;;
        *)
            erase=n
        ;;
    esac
    if [[ $erase = y ]]
    then
        case "$container_running_state" in
            "false")
            ;;
            *)
                docker container stop "$container_name" > /dev/null
            ;;
        esac
        docker container rm "$container_name" > /dev/null
    fi
fi