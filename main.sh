#!/bin/bash

flags='b:hi:r:s:'

_help () {
cat <<EOF
Usage: ${0##*/} [-$flags]
-b  build (ex : -b tool/version)
-h  display this help
-i  install (docker)
-r  remove (all/containers/images)
-s  start (ex: -s tool/version)
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
  OS=$(lsb_release -si)
  VERSION=$(lsb_release -r | cut -f2)
  CODENAME=$(lsb_release --codename | cut -f2)
  CHECK=$(docker | head -1 | awk '{print $1}')
  if [[ $1 == "docker" && $CHECK != "Usage:" ]]; then
    sudo apt-get update
    sudo apt-get install apt-transport-https ca-certificates
    if [ $OS == "Ubuntu" ]; then
      sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
      if [ $VERSION == "14.04" ]; then
        REPO="deb https://apt.dockerproject.org/repo ubuntu-trusty main"
      elif [ $VERSION == "15.10" ]; then
        REPO="deb https://apt.dockerproject.org/repo ubuntu-wily main"
      elif [ $VERSION == "16.04" ]; then
        REPO="deb https://apt.dockerproject.org/repo ubuntu-xenial main"
      else
        echo "Unknown REPO ... Trying to install docker through an other way ..."
        sudo apt-get install docker.io
      fi
      echo $REPO | sudo tee /etc/apt/sources.list.d/docker.list
      sudo apt-get update
      sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
      sudo apt-get install docker-engine
    elif [ $OS == "Debian" ]; then
      sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
      if [ $CODENAME == "wheezy" ]; then
        REPO="deb https://apt.dockerproject.org/repo debian-wheezy main"
      elif [ $CODENAME == "jessie" ]; then
        REPO="deb https://apt.dockerproject.org/repo debian-jessie main"
      elif [ $CODENAME == "stretch" ]; then
          REPO="deb https://apt.dockerproject.org/repo debian-stretch main"
      else
        echo "Unknown REPO ... Trying to install docker through an other way ..."
        sudo apt-get install docker.io
      fi
      apt-get update
      sudo apt-get install docker-engine
    else
      sudo apt-get install docker.io
    fi
    TESTDNS=$(grep "#dns=dnsmasq" /etc/NetworkManager/NetworkManager.conf)
    if [ -z $TESTDNS ]; then
      sudo sed -i -e 's/dns=dnsmasq/#dns=dnsmasq/g' /etc/NetworkManager/NetworkManager.conf
    fi
    sudo restart network-manager
    sudo usermod -aG docker $USER
    sudo service docker restart
    echo "Need to open a new shell in order to use docker..."
  elif [[ $1 == "docker" && $CHECK == "Usage:" ]]; then
    echo "Docker has already been installed..."
  else
    echo "Working on it..."
  fi
}

_remove () {
  IMAGES=$(docker images -q)
  CONTAINERS=$(docker ps -aq)
  if [[ $1 == "all" || $1 == "containers" ]]; then
    if [ -z $CONTAINERS ]; then
      echo "No containers"
    else
      docker rm $(docker ps -a -q)
    fi
  elif [[ $1 == "all" || $1 == "images" ]]; then
    if [ -z $IMAGES ]; then
      echo "No images"
    else
      docker rmi $(docker images -q)
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
