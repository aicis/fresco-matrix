#!/bin/sh
BASEDIR=..
cd $BASEDIR
if [ -n "$(command -v apt-get)" ] 
then
   sudo apt-get update && apt-get install -y openjdk-11-jdk maven
fi
mvn clean package -DskipTests
