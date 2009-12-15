#!/usr/bin/python
import os.path, os
from sys import argv, exit
base_template="""<?xml version="1.0" encoding="UTF-8"?>
<classpath>
	<classpathentry excluding="**/.svn|**/.svn/**" kind="src" path="code/internal/src"/>
	<classpathentry excluding="**/.svn|**/.svn/**" kind="src" path="code/src"/>
	<classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER"/>
	<classpathentry kind="output" path="build/classes"/>
        <classpathentry kind="lib" path="code/webapp"/>
%s	
</classpath>"""

classpath_entry = """	<classpathentry kind="lib" path="%s"/>"""
classpath_sourcepath_entry = """	<classpathentry kind="lib" path="%s" sourcepath="%s"/>"""


def main():
    if len(argv) != 2 and len(argv) != 3:
        print "Usage: python %s <jar dirs separated by :> [<src jars separated by :>]" % argv[0]
        print """Example: python %s "/usr/share/java:/usr/share/java-ext" "/usr/share/src-jars" """ % argv[0]
        exit(1)

    src_entries = {}
    if len(argv) == 3:
        for dr in argv[2].split(":"):
            if dr.strip():
                for f in os.listdir(dr):
                    if f != "rhn.jar" and f.endswith(".jar") and not f in src_entries:
                        src_entries[f] = os.path.join(dr,f)
    entries = {}
    entries['tools.jar'] = classpath_entry % "/usr/lib/jvm/java/lib/tools.jar"
    entries['ant-junit.jar'] = classpath_entry % "/usr/share/java/ant/ant-junit.jar"
    entries['ant.jar'] = classpath_entry % "/usr/share/java/ant.jar"

    for dr in argv[1].split(":"):
        if dr.strip():
            if os.path.isdir(dr):
                for f in os.listdir(dr):
                    if f != "rhn.jar" and f.endswith(".jar") and not f in entries:
                        if f in  src_entries:
                            entries[f] = classpath_sourcepath_entry % (os.path.join(dr,f) , src_entries[f])
                        elif f[:-4] + "-" +"src.jar" in src_entries:
                            entries[f] = classpath_sourcepath_entry % (os.path.join(dr,f) ,
                                                                src_entries[f[:-4] + "-" +"src.jar"])
                        else:
                            entries[f] = classpath_entry % os.path.join(dr,f)
            if os.path.isfile(dr):
                f = os.path.basename(dr)
                if f != "rhn.jar" and f.endswith(".jar") and not f in entries:
                    entries[f] = classpath_entry % dr

    print base_template % "\n".join (entries.values())

if __name__=="__main__":
    main()
