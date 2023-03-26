#!/bin/bash

################################################################################
################## end-user desired docker image configuration ################
image_tag="stages"
image_name="ubuntu_qt6:${image_tag}"
user=$(id -un)  # user name to append to container tag
container_name="ubuntu_qt6_${user}"
shell_cmd="/bin/bash"
project_dir=$1 #location of project files
data_dir=$2  #location of data dir
################################################################################

get_container_id() {
    docker ps --all | grep ${container_name} | awk '{print $1}'
}

start_container() {
    echo "Starting a new container, ${container_name}, from image: ${image_name}"
    docker run -ti \
        -e DISPLAY=${DISPLAY} \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v ${data_dir}:/data \
        -v ${project_dir}:/projects \
        --name ${container_name} \
        --entrypoint /dev-entrypoint.sh \
        --workdir /projects  \
        ${image_name} \
        ${shell_cmd}
}

attach_to_container() {
    echo "Attaching a new shell to container: ${1} (${image_name})"
    docker exec -it --user=devusr ${1} ${shell_cmd}
}

container_id=$(get_container_id)
n_active=$(echo $container_id | wc -w)

if [ "${n_active}" -eq 0 ]; then
    start_container
elif [ "${n_active}" -eq 1 ]; then
    not_running=$(docker ps -aq -f status=exited -f name=$container_name | grep -w $container_id)
    if [ "${not_running}" ]; then
        # container is in the "Exited" state, restart it
        echo "Starting container ${container_id}"
        docker start ${container_id}
    fi
    attach_to_container ${container_id}
else
    echo "ERROR: $n_active containers are active for image ${image_name}. IDs of the active containers:"
    echo "${container_id}"
    exit 1
fi

