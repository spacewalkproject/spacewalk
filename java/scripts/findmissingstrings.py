#!/usr/bin/python

try:
    import elementtree.ElementTree as et
except:
    import xml.etree.ElementTree as et

import os

skip = ["emptyspace.jsp"]

def parsefile(file):
    items = []
    tree = et.parse(file)
    root = tree.getroot()
    for i in root.getiterator():
        if i.tag.endswith('trans-unit'):
            for item in i.items():
                items.append(item[1])
    return items

def diff(en, other):
    #find all items that are in en but NOT in other.
    notfound = []
    for e in en:
        if e not in skip and e not in other:
            notfound.append(e)
    return notfound

items = parsefile('StringResource_en_US.xml')
#print items

files = os.listdir('.')
#print files

for file in files:

    if file.startswith('StringResource_') and file.endswith('.xml') and file != 'StringResource_en_US.xml':
        #print 'processing ' + str(file)
        otherkeys = parsefile(file)
        notfound = diff(items, otherkeys)
        if notfound:
            k = ''
            for nf in notfound:
                k = k + '\t' + nf + '\n'
            print "%s is missing the following keys:\n%s\n---" % (str(file), k)
