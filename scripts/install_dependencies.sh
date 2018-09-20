#!/bin/bash
# check if mvn is installed
if type -p mvn;
then
    echo "found maven executable in PATH"
else
    echo "can't find maven in PATH"
    bash ./install_maven.sh
fi

# check if jdk is installed
if type -p javac
then
    echo "found jdk"
else
    echo "can't find jdk, installing jdk..."
    sudo bash ./install_jdk.sh
fi

echo "end of install_dependencies..."