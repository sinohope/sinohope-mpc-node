#!/bin/bash

ROOT_PATH=$(dirname "$0")
ROOT_PATH=$( (cd "$ROOT_PATH" && pwd))
[ -f "$ROOT_PATH/.env" ] && source "$ROOT_PATH/.env"
SGX=1

IMAGE="sinohope/mpc-node:latest"
UNSEAL_SERVER="127.0.0.1:10080"

if [ "$SGX" == "1" ]; then
    IMAGE="sinohope/sgx-mpc-node:latest"
fi

if [ -t 1 ]; then
    ncolors=$(tput colors)
    if [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
    fi
fi

check_sys() {
    check_docker >/dev/null

    ret=$?
    [ "$ret" == 1 ] && { install_docker || exit 1; }
    [ "$ret" == 2 ] && { restart_docker || exit 1; }

    if [ "$SGX" == 1 ]; then
        check_sgx_driver || install_sgx_driver || exit 1
    fi
    check_image >/dev/null

    pull_image || exit 1
}


check_sgx_driver() {
    [ "$reduced" != 1 ] && echo -n "Checking SGX driver ... "
    err=0
    [ -c /dev/sgx_enclave ] || err=1
    [ -c /dev/sgx_provision ] || err=1
    if [ "$err" != 0 ]; then
        echo "${red}SGX driver not available${normal}"
        return 1
    fi
    [ "$reduced" != 1 ] && echo "${bold}OK${normal}"
    return 0
}

install_sgx_driver() {
    lsb_dist="$(. /etc/os-release && echo "$ID")"
    [ "$lsb_dist" == "ubuntu" ] && dist_codename="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")" &&
        dist_version="$(. /etc/lsb-release && echo "$DISTRIB_RELEASE")"

    echo
    echo "Please refer to the official guide from Intel to install SGX driver: "
    echo "    ${underline}https://download.01.org/intel-sgx/latest/dcap-latest/linux/docs/Intel_SGX_SW_Installation_Guide_for_Linux.pdf${normal}"
    echo
    echo "Basically, the choices are:"
    echo " 1. (recommended) Upgrade to kernel version 5.11 or higher."
    [ "$dist_codename" == "focal" ] && echo "    Since you are running Ubuntu 20.04, you can upgrade to HWE kernel:" &&
        echo "         sudo apt install --install-recommends linux-generic-hwe-20.04"
    echo " 2. Install DCAP driver from Intel, without upgrading kernel."
    echo " 3. If you are using Cloud VM, such as Aliyun or Azure with SGX support. You can contact your cloud provider about how to install SGX driver."
    echo
    if [ "$reduced" == 1 ]; then
        echo "Run a full check with command 'sudo $0 status'."
        exit 1
    fi
    if [ "$lsb_dist" != ubuntu ]; then
        echo "For now, I'm going to stop here. Please try again after you have SGX driver installed."
        exit 1
    fi
    if ! is_sudo; then
        echo "If you run me with 'sudo', I can help you with the installation."
        echo "For now, I'm going to stop here. Please try again after you have SGX driver installed."
        exit 1
    fi
    read -p "Would you like to install DCAP SGX driver? (y/n) " ans
    if [ "$ans" != y ]; then
        echo "Well, I'm going to stop here. Please try again after you have SGX driver installed."
        exit 1
    fi
    apt-get install -y build-essential ocaml automake autoconf libtool wget python libssl-dev dkms cpuid || exit 1

    echo -n "Checking SGX1 Support ... "
    support_sgx1=$(cpuid -1 | grep SGX1\ supported | cut -d "=" -f 2 | xargs)
    if [ "$support_sgx1" != "true" ]; then
        echo "${red}not supported${normal}"
        echo
        echo "It seems your hardware does not support SGX, or SGX is not enabled in BIOS."
        exit 1
    fi
    echo "${bold}OK${normal}"
    echo -n "Checking SGX FlexLC Support ... "
    support_flc=$(cpuid -1 | grep SGX_LC\: | cut -d "=" -f 2 | xargs)
    if [ "$support_flc" != "true" ]; then
        echo "${red}not supported${normal}"
        echo
        echo "It seems your hardware does not support FlexLC, or FlexLC is not enabled in BIOS."
        echo "FlexLC is required."
        exit 1
    fi
    echo "${bold}OK${normal}"

    distro_name=${lsb_dist}${dist_version}-server
    version=1.41
    curl -fsSL https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/${distro_name}/sgx_linux_x64_driver_${version}.bin \
        -o "$BASE_PATH/sgx_linux_x64_driver_${version}.bin" || exit 1
    bash "$BASE_PATH/sgx_linux_x64_driver_${version}.bin" || exit 1
    rm -f "$BASE_PATH/sgx_linux_x64_driver_${version}.bin"
    check_sgx_driver
}

check_docker() {
    echo "check docker status ... "
    if ! which docker >/dev/null; then
        echo "${red}docker is not install${normal}"
        return 1
    fi
    docker_version="$(docker version --format '{{.Server.Version}}' 2>/dev/null)"
    if [ "$?" != 0 ]; then
        echo "${red}docker is not started${normal}"
        return 2
    fi
    echo "${bold}docker status is OK${normal}, version: ${docker_version}"
    return 0
}

install_docker() {
    if [ "$(uname -s)" == "Darwin" ]; then
        echo "click to the following page to install docker:"
        echo "    ${underline}https://www.docker.com/products/docker-desktop/${normal}"
    else
        echo "click to the following page to install docker: "
        echo "    ${underline}https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository${normal}"
    fi
    exit 1
}

restart_docker() {
    echo "going restart docker..."
    service docker restart || exit 1
}

check_image() {
    echo -n "check image status... "
    image_id=$(docker inspect --format='{{.Id}}' "$IMAGE" 2>/dev/null)
    if [ -z "$image_id" ]; then
        echo "${red}Image not found:${normal} $IMAGE"
        return 1
    fi
    echo "${bold}image status is OK${normal}, id: $image_id"
    return 0
}

pull_image() {
    echo "checking update..."
    docker pull "${IMAGE}" > /dev/null 2>&1
}

stop_container() {
    docker stop mpc-node >/dev/null && docker rm mpc-node >/dev/null
}

show_help() {
    b=$(basename "$0")
    echo """
Usage:   $b COMMAND [OPTIONS] [OPTIONS: custom mpc-node name]

Commands:
  init      initialize mpc node service base data.
  info      show mpc node info, include node id and callback-server public key.
  reset     change mpc-node password.
  start     start mpc node service in the background.
  stop      stop mpc node.
  help      show command help.

Examples:
  $b init     initialize mpc node service base data.
  $b start    start mpc node service in the background.
    """
    exit 0
}

CURRENT_PASSWORD=""
current_password()
{
  while [ 1 = 1 ]; do
    echo -n '? Enter current password: '
    stty -echo
    read -s CURRENT_PASSWORD
    stty echo
    echo

    if [[ -z "${CURRENT_PASSWORD}" ]]; then
        echo 'empty password, please retry.' >&2
        continue
    else
        break
    fi
  done
}

NEW_PASSWORD=""
change_password() {
  local password1 password2

  while [ 1 = 1 ]; do
    echo -n "New password:"
    stty -echo
    read -r password1
    stty echo
    echo

    echo -n "Retype new password:"
    stty -echo
    read -r password2
    stty echo
    echo

    # 检查两次输入的密码是否相同且非空
    if [[ -z "$password1" || -z "$password2" ]]; then
        echo "Password can not be empty, please try again..."
        continue
    elif [ "$password1" != "$password2" ]; then
        echo "Passwords not match, please try again..."
        continue
    else
        NEW_PASSWORD="${password1}"
        return 0
    fi
  done
}

stop_container() {
    local container_name="$1"
    if [[ -z "${container_name}" ]]; then
        echo "container name is empty"
        return
    fi

    echo "stopping ${container_name} ..."

    if docker ps -a | grep -q "${container_name}"; then
        docker stop "${container_name}" >/dev/null && docker rm "${container_name}" >/dev/null
    fi
}

[ -z "$1" ] && show_help

    DOCKER_INSTANCE_NAME="mpc-node"
    PORT="10080"
    if [ $# -ge 2 ]; then
      DOCKER_INSTANCE_NAME=$2
      PORT=$(( RANDOM % 10001 + 20000 ))
    fi
    UNSEAL_SERVER="127.0.0.1:${PORT}"

case "$1" in
check)
    check_sys
    ;;
help) show_help ;;

init|info|reset|start)
    check_sys

    FIND_DOCKER_INSTANCE_NAME=$(docker ps -a --format '{{.Names}}' | grep -w "^${DOCKER_INSTANCE_NAME}$")
    if [ "${FIND_DOCKER_INSTANCE_NAME}" != "${DOCKER_INSTANCE_NAME}" ]; then
        echo "mpc-node instance name: ${DOCKER_INSTANCE_NAME}, unseal server address: ${UNSEAL_SERVER}"
        [ "$SGX" == 1 ] && device_map="--device=/dev/sgx_enclave:/dev/sgx/enclave --device=/dev/sgx_provision:/dev/sgx/provision"
        docker run $device_map  "-d" \
            --name ${DOCKER_INSTANCE_NAME} \
            --restart always \
            -v "$(pwd)":/tmp/mpc-node \
            -p ${UNSEAL_SERVER}:8080 \
            ${IMAGE} 
        while true; do
            curl --location --request GET "http://${UNSEAL_SERVER}/sys/seal-status" \
              --header 'Content-Type: text/plain' \
              --data '{}' >/dev/null 2>&1

            if [ $? -eq 0 ]; then
                echo "${DOCKER_INSTANCE_NAME} started"
                break
            else
                echo "waiting ${DOCKER_INSTANCE_NAME} to start..."
                sleep 3
            fi
        done
    fi

    docker inspect "${DOCKER_INSTANCE_NAME}" > /dev/null 2>&1
    docker_status=$?
    if [[ $docker_status -ne 0 ]]; then
        echo "mpc-node with name: ${DOCKER_INSTANCE_NAME} not found."
        exit 1
    fi

    DOCKER_MAPPED_ADDRESS=$(docker inspect "${DOCKER_INSTANCE_NAME}" | grep HostPort | awk -F '"' '{print "127.0.0.1:"$4}' | head -n 1)
    if [[ $? -ne 0 ]]; then
      echo "mpc-node with name: ${DOCKER_INSTANCE_NAME} not existed"
      exit 1
    fi
    UNSEAL_SERVER=${DOCKER_MAPPED_ADDRESS}
    echo "unseal server address: ${UNSEAL_SERVER}"

  RESPONSE=""
  HTTP_CODE=""
  HTTP_BODY=""
    if [ "$1" == "init" ]; then
      change_password
      RESPONSE=$(curl -s -w "\n%{http_code}" --location "http://${UNSEAL_SERVER}/sys/init" \
        --header 'Content-Type: text/plain' \
        --data "{
            \"shard_bkey\": \"${NEW_PASSWORD}\"
        }")
    fi

    if [ "$1" == "info" ]; then
      RESPONSE=$(curl -s -w "\n%{http_code}" --location --request GET "http://${UNSEAL_SERVER}/sys/seal-status" \
              --header 'Content-Type: text/plain' \
              --data "")

    fi

    if [ "$1" == "reset" ]; then
      current_password
      RESPONSE=$(curl -s -w "\n%{http_code}" --location "http://${UNSEAL_SERVER}/sys/re-bkey-init" \
              --header 'Content-Type: text/plain' \
              --data "{
                  \"shard_bkey\": \"${CURRENT_PASSWORD}\"
              }")
      HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
      if [ "$HTTP_CODE" == "200" ]; then
        change_password
        RESPONSE=$(curl -s -w "\n%{http_code}" --location "http://${UNSEAL_SERVER}/sys/re-bkey" \
            --header 'Content-Type: text/plain' \
            --data "{
                \"shard_bkey\": \"${NEW_PASSWORD}\"
            }")
      fi
    fi

    if [ "$1" == "start" ]; then
      current_password
      RESPONSE=$(curl -s -w "\n%{http_code}" --location "http://${UNSEAL_SERVER}/sys/in-bkey" \
        --header 'Content-Type: text/plain' \
        --data "{
            \"shard_bkey\": \"${CURRENT_PASSWORD}\"
        }")
    fi

    HTTP_BODY=$(echo "$RESPONSE" | sed '$d')
    echo "${HTTP_BODY}"

    ;;
stop)
    stop_container "${DOCKER_INSTANCE_NAME}"
    ;;
status)
    FIND_DOCKER_INSTANCE_NAME=$(docker ps -a --format '{{.Names}}' | grep -w "^${DOCKER_INSTANCE_NAME}$")
    if [ "${FIND_DOCKER_INSTANCE_NAME}" != "" ]; then
      echo "${DOCKER_INSTANCE_NAME} is running"
    else
      echo "${DOCKER_INSTANCE_NAME} is not running"
    fi
    ;;
*)
    show_help
    ;;
esac
