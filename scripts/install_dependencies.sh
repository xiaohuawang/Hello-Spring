#!/bin/bash

# check if mvn is installed
if type -p mvn;
then
    echo "found maven executable in PATH"
else
    echo "can't find maven in PATH"
    bash scripts/install_dependencies.sh
fi

# check if jdk is installed
if type -p javac
then
    echo "found jdk"
else
    echo "can't find jdk, installing jdk..."
    sudo bash scripts/install_jdk.sh
fi

echo "install_dependencies end" > /var/log/install_dependencies.out 2>&1

echo "end of install_dependencies..."