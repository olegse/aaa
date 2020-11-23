#!/bin/bash
#
echo "${1:0:2}" 
echo ${1##${1:0:2}}
