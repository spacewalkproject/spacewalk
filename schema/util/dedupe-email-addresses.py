#!/usr/bin/python

import string, sys

input = open(sys.argv[1], "r")
output = open(sys.argv[2], "w")

users = {}
while 1:
    line = input.readline()
    if line == '':
        break
    line = line.strip("\n")
    linevals = line.split(',')
    users[linevals[3]] = line

for key in users.keys() or []:
    output.write(users[key])
    output.write("\n")

