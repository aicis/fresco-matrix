#!/usr/bin/env bash
# Note: Matrix runs the run.sh script from BASEDIR/MATRIX where BASEDIR is the root dir of the git project.
# if this changes, the script will break.
BASEDIR=..
# Point to directory 
JAR_DIR=$BASEDIR/target/
# MATRIX gives the party id of this party as the first argument, but indexes from 0
PARTY_ID=`expr $1 + 1`
# MATRIX seems to put the party configurarion here
PARTIES_FILE="parties.conf"
# Unwrap the MATRIX parties configuration file
PARTIES_STR="-i $PARTY_ID "
NUM_LINES=$(wc -l < $PARTIES_FILE)
NUM_PARTIES=`expr $NUM_LINES / 2`
for i in $(seq $NUM_PARTIES)
do
    IDX=`expr $i - 1`
    IP_PREFIX="party_"$IDX"_ip="
    PORT_PREFIX="party_"$IDX"_port="
    IP=$(grep $IP_PREFIX $PARTIES_FILE | sed "s/$IP_PREFIX//")
    PORT=$(grep $PORT_PREFIX $PARTIES_FILE | sed "s/$PORT_PREFIX//")
    PARTIES_STR=$PARTIES_STR"-p $i:$IP:$PORT "
done
shift
# Handle the fact that MATRIX breaks when configuration arguments include equals sign
PARAMS=$(echo "$@" | sed 's/%/=/')
# Run experiment 
# Note: this assumes the parameters (i.e., the config) to start with the name of the jar to run 
# and to take arguments comliant with the FRESCO cmdlineutil
java -jar $JAR_DIR/$PARAMS $PARTIES_STR > $BASEDIR/experiment_log.txt 2>&1
