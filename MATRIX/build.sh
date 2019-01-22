#!/bin/sh
#!/usr/bin/env bash
# Note: Matrix runs the build script from BASEDIR/MATRIX where BASEDIR is the root dir of the git project.
# if this changes, the script will break.
BASEDIR=..
cd $BASEDIR
mvn clean package -DskipTests
