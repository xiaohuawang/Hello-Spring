#!/bin/bash
# Script for installing Maven on Amazon Linux

MVN_VERSION=3.5.4
# MVN_MD5=2fcfdb327eb94b8595d97ee4181ef0a6

# http://mirrors.sonic.net/apache/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz
wget http://mirrors.sonic.net/apache/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz

if [ -d "/usr/local/apache-maven" ]; then
        sudo rm -r /usr/local/apache-maven
        echo "/usr/local/apache-maven existed, and has been removed."
fi

sudo mkdir /usr/local/apache-maven
tar -xzf apache-maven-$MVN_VERSION-bin.tar.gz
sudo mv apache-maven-$MVN_VERSION /usr/local/apache-maven

# write the file path to .bash_profile
echo "export M2_HOME=/usr/local/apache-maven/apache-maven-$MVN_VERSION" >> ~/.bash_profile
echo 'export M2=$M2_HOME/bin' >> ~/.bash_profile
echo 'export PATH=$M2:$PATH' >> ~/.bash_profile

# remove the bin.tar.gz file
sudo rm apache-maven-3.5.4-bin.tar.gz

echo "Finished installing maven.  Re-source ~/.bash_profile for changes to take effect"
#source ~/.bash_profile
. .bash_profile

echo "Done!"