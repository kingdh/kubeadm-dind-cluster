#!/bin/bash



mirror="gcr.azk8s.cn"
namespace="google_containers"
prefix="gcr.io"
specialPrefix="k8s.gcr.io"
quayPrefix="quay.io"
quayMirror="quay.azk8s.cn"

function run_sys_docker {
    orig_docker "$@"
#    echo "docker $@"
}

docker_cmd=${1:-}


case ${docker_cmd} in
    pull)
        image=${2}
        newImage=${newImage:-}
        echo ${image}
        IFS="/" read -ra imageArray <<< "${image}"
        if [[ ${imageArray[0]} == ${prefix} || ${imageArray[0]} == ${specialPrefix} ]]; then
            if [[ ${#imageArray[@]} == 2 ]]; then
#                seq = (mirror, namespace, imageArray[1])
                newImage=${mirror}"/"${namespace}"/"${imageArray[1]};
            else
#                seq = (mirror, imageArray[1], imageArray[2])
                newImage=${mirror}"/"${imageArray[1]}"/"${imageArray[2]}
            fi;
            run_sys_docker ${docker_cmd} ${newImage}
            tag_cmd=${tag_cmd:-tag}
            run_sys_docker ${tag_cmd} ${newImage} ${image}
            rmi_cmd=${rmi_cmd:-rmi}
            run_sys_docker ${rmi_cmd} ${newImage}
        elif [[ ${imageArray[0]} == ${quayPrefix} ]]; then
        	newImage=${quayMirror}"/"${imageArray[*]:1}
        	run_sys_docker ${docker_cmd} ${newImage}
        	tag_cmd=${tag_cmd:-tag}
            run_sys_docker ${tag_cmd} ${newImage} ${image}
            rmi_cmd=${rmi_cmd:-rmi}
            run_sys_docker ${rmi_cmd} ${newImage}
        else
            run_sys_docker "$@";
        fi
        exit 0
        ;;
    *)
        run_sys_docker "$@"
        ;;
esac