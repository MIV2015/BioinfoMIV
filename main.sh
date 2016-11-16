#!/bin/bash

flags='b:hi:r:s:'

_help () {
cat <<EOF
Usage: ${0##*/} [-$flags]
-b  build (containers/images)
-h  display this help
-i  install (docker)
-r  remove (all/containers/images)
-u  update
EOF
}

_build () {
  PKG=$(echo ${1} | tr "/" "\n" | head -1)
  TAG=$(echo ${1} | tr "/" "\n" | tail -1)
  cd etc/docker-images/${1}
  docker build -t miv/$PKG:$TAG .
}


_install () {
  if [ $1 == "docker" ]
  then
    sudo apt-get install docker-engine
    sudo sed -i -e 's/dns=dnsmasq/#dns=dnsmasq/g' /etc/NetworkManager/NetworkManager.conf
    sudo restart network-manager
  else
    echo "Working on it..."
  fi
}

_remove () {
  if [ $1 == "all" ]; then
    if [ -z $(docker ps -a -q) ]; then
      echo "No containers"
    else
      docker rm $(docker ps -a -q)
    fi
    if [ -z $(docker images -q) ]; then
      echo "No images"
    else
      docker rmi $(docker images -q)
    fi
  elif [ $1 == "images" ]; then
    if [ -z $(docker images -q) ]; then
      echo "No images"
    else
      docker rmi $(docker images -q)
    fi
  elif [ $1 == "containers" ]; then
    if [ -z $(docker ps -a -q) ]; then
      echo "No containers"
    else
      docker rm $(docker ps -a -q)
    fi
  else
    echo "Working on it..."
  fi
}

_start () {
  PKG=$(echo ${1} | tr "/" "\n" | head -1)
  TAG=$(echo ${1} | tr "/" "\n" | tail -1)
  docker run -it miv/$PKG:$TAG
}


DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

while getopts ":$flags" o; do
  case "${o}" in
    b) _build "${OPTARG}"
    exit;;
    h)  _help
    exit;;
    i)  _install "${OPTARG}"
    exit;;
    r)  _remove "${OPTARG}"
    exit;;
    s)  _start "${OPTARG}"
    exit;;
    *)	echo "Usage: $0 [-$flags]" 1>&2; exit 1;;
  esac
done
