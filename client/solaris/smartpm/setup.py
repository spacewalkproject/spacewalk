#!/usr/bin/python
from distutils.command.install_scripts import install_scripts
from distutils.core import setup, Extension
from distutils.sysconfig import get_python_lib
import distutils.file_util
import distutils.dir_util
import sys, os
import glob
import re

if os.path.isfile("MANIFEST"):
    os.unlink("MANIFEST")

verpat = re.compile("VERSION *= *\"(.*)\"")
data = open("smart/const.py").read()
m = verpat.search(data)
if not m:
    sys.exit("error: can't find VERSION")
VERSION = m.group(1)

# Make distutils copy smart.py to smart.
copy_file_orig = distutils.file_util.copy_file
copy_tree_orig = distutils.dir_util.copy_tree
def copy_file(src, dst, *args, **kwargs):
    if dst.endswith("bin/smart.py"):
        dst = dst[:-3]
    return copy_file_orig(src, dst, *args, **kwargs)
def copy_tree(*args, **kwargs):
    outputs = copy_tree_orig(*args, **kwargs)
    for i in range(len(outputs)):
        if outputs[i].endswith("bin/smart.py"):
            outputs[i] = outputs[i][:-3]
    return outputs
distutils.file_util.copy_file = copy_file
distutils.dir_util.copy_tree = copy_tree

PYTHONLIB = get_python_lib(1)

I18NFILES = []
for filepath in glob.glob("locale/*/LC_MESSAGES/*.mo"):
    targetpath = os.path.dirname(os.path.join(sys.prefix, "share", filepath))
    I18NFILES.append((targetpath, [filepath]))

setup(name="smart",
      version = VERSION,
      description = "Smart Package Manager is a next generation package "
                    "handling tool",
      author = "Gustavo Niemeyer",
      author_email = "niemeyer@conectiva.com",
      license = "GPL",
      url = "http://smartpm.org",
      long_description =
"""\
Smart Package Manager is a next generation package handling tool.
""",
      packages = [
                  "smart",
                  "smart.backends",
                  "smart.backends.rpm",
                  "smart.backends.deb",
                  "smart.backends.slack",
                  "smart.backends.solaris",
                  "smart.channels",
                  "smart.commands",
                  "smart.interfaces",
                  "smart.interfaces.gtk",
                  "smart.interfaces.text",
                  "smart.interfaces.images",
                  "smart.interfaces.up2date",
                  "smart.plugins",
                  "smart.util",
                  "smart.util.elementtree",
                 ],
      scripts = ["smart.py", "up2date"],
      ext_modules = [
                     Extension("smart.ccache", ["smart/ccache.c"]),
                     Extension("smart.backends.rpm.crpmver",
                               ["smart/backends/rpm/crpmver.c"]),
                     Extension("smart.backends.deb.cdebver",
                               ["smart/backends/deb/cdebver.c"]),
                     Extension("smart.util.ctagfile",
                               ["smart/util/ctagfile.c"]),
                     Extension("smart.util.cdistance",
                               ["smart/util/cdistance.c"]),
                    ],
      data_files = I18NFILES +
                   [(PYTHONLIB+"/smart/interfaces/images", 
                     glob.glob("smart/interfaces/images/*.png"))],
      )

