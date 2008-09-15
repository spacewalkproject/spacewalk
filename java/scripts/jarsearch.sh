#!/bin/bash

for jar in $1/*.jar
   do
      text=`/usr/bin/fastjar -tf $jar | grep $2.class`
      if [ ${#text} -gt "2" ]
      then
         echo "$jar -> $text"
      fi
   done
