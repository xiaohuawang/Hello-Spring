#!/bin/bash

# go to the working directory
WORKING_DIRECTORY=/var/www/html
cd $WORKING_DIRECTORY

# use su to clean the project
sudo env "PATH=$PATH" mvn clean

# use su to build the project
sudo env "PATH=$PATH" mvn install