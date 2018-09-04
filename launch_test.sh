#!/bin/bash
# Starts a JMeter test that is passed via command line arguments
# Usage:
# ./run_test.sh testscript.jmx result.jtl yourserverip [yourpath] [VUCount] [LoopCount] [MyLoadTestName]

if [ -z "$1" ]; then
  echo "Usage: Arg 1 needs to be valid <yourtestscript>.jmx"
  exit 1
fi
if [ -z "$2" ]; then
  echo "Usage: Arg 2 needs to be a valid path for a <result>.jtl"
  exit 1
fi
if [ -z "$3" ]; then
  echo "Usage: Arg 3 needs to be the URL or IP of your service that should be tested"
  exit 1
fi
CHECK_PATH=$4
if [ -z "$4" ]; then
  CHECK_PATH=/
fi
DT_LTN=$5
if [ -z "$5" ]; then
  DT_LTN=MyLoadTestName
fi

sudo rm -f -r $2
sudo mkdir $2
sudo docker run --name jmeter-test -v "${PWD}/scripts":/scripts -v "${PWD}/$2":/results --rm -d jmeter ./jmeter/bin/jmeter.sh -n -t /scripts/$1 -e -o /results -l result.tlf -JSERVER_URL="$3" -JDT_LTN="$DT_LTN" -JCHECK_PATH="$CHECK_PATH"