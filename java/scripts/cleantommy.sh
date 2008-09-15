#!/bin/bash

# clean the older tomcat log files but keep catalina logs 
cd /var/log/tomcat5
for i in `ls localhost*` 
do 
  [[ "$i" =~ "`date +.%F.txt`" ]] || rm $i 
done
