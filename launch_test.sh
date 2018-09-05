#!/bin/bash
# Starts a JMeter test that is passed via command line arguments
# Usage:
# ./run_test.sh testscript.jmx result.jtl yourendpoint [VUCount] [LoopCount] [MyLoadTestName]

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
VUCount=$4
if [ -z "$4" ]; then
  VUCount=1
fi
LoopCount=$5
if [ -z "$5" ]; then
  LoopCount=1
fi
DT_LTN=$6
if [ -z "$6" ]; then
  DT_LTN=MyLoadTestName
fi

echo "Running with SERVER_URL=$3, VUCount=$VUCount, LoopCount=4LoopCount, DT_LTN=$DT_LTN"

rm -f -r $2
mkdir $2
docker run --name jmeter-test -v "${PWD}/scripts":/scripts -v "${PWD}/$2":/results --rm -d jmeter ./jmeter/bin/jmeter.sh -n -t /scripts/$1 -e -o /results -l result.tlf -JSERVER_URL="$3" -JDT_LTN="$DT_LTN" -JVUCount="$VUCount" -JLoopCount="$LoopCount"