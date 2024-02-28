#!/bin/sh

var="simdata_janidu.job"

cat $var | cut -d "," -f 10
cat $var | cut -d "," -f 9
cat $var | cut -d "," -f 8
cat $var | cut -d "," -f 7
cat $var | cut -d "," -f 6
cat $var | cut -d "," -f 5
cat $var | cut -d "," -f 4
cat $var | cut -d "," -f 3
cat $var | cut -d "," -f 2
cat $var | cut -d "," -f 1

sleep 2