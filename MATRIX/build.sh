#!/bin/sh
BASEDIR=..
cd $BASEDIR
if [ -n "$(command -v apt-get)" ] 
then
   sudo apt-get update && sudo apt-get install -y openjdk-11-jdk maven
fi
mvn clean package -DskipTests
