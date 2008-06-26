#!/usr/bin/python

import re
import os

register_tag_re = re.compile(".*?register_tag\('(.*?)'.*?\\&(.*?)[,\)]")

def find_pxt_tags(module):
    tags = []
    for line in module:
        result = register_tag_re.match(line)
        if result:
            tags.append(result.groups())
    return tags

def find_pxt_tags_in_dir(file_tags, dirname, files):
    for afile in files:
        if not os.path.isdir(os.path.join(dirname, afile)):
            tags = find_pxt_tags(open(os.path.join(dirname, afile)))
            file_tags[afile] = tags

def tag_used_in_file(afile, tag):
    for line in afile:
        if tag in line:
            return True
    else:
        return False

def tag_used_in_dir(arg, dirname, files):
    found = arg[0]
    tag = arg[1]
    for afile in files:
        if not os.path.isdir(os.path.join(dirname, afile)):
            used = tag_used_in_file(open(os.path.join(dirname, afile)), tag)
            found.append(used)

def tag_is_used(tag):
    found = []
    os.path.walk('html', tag_used_in_dir, (found, tag))
    return True in found

def main():
    file_tags = {}
    os.path.walk('modules/sniglets', find_pxt_tags_in_dir, file_tags)

    print "Module\tTag\tSubroutine"
    for key, value in file_tags.iteritems():
        for tag in value:
            if not tag_is_used(tag[0]):
                print "%s\t%s\t%s" % (key, tag[0], tag[1])

if __name__ == "__main__":
    main()
