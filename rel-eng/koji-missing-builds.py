#!/usr/bin/python

import os
import sys
from optparse import OptionParser
import ConfigParser

config = ConfigParser.RawConfigParser()
config.read(["tito.props", "rel-eng/tito.props"])

usage = "usage: %prog [options] <tag to check>"
parser = OptionParser(usage, version='%prog 0.0.1')
parser.add_option("-g","--git", action="store_true", default=False,
  help="print list of builds not managed in git")
parser.add_option("-b","--brew", action="store_true", default=False,
  help="check builds in brew instead of koji")
parser.add_option("-c","--copr", action="store_true", default=False,
  help="check builds in copr instead of koji")
parser.add_option("--no-extra", action="store_false", default=True,
  dest="no_extra", help="suppress the extra builds listing")
(opts, args) = parser.parse_args()

if len(args) < 1:
    print "ERROR: need to specify tag to check\n"
    parser.print_help()
    sys.exit(1)
if len(args) > 1:
    print "ERROR: Only one tag at a time.\n"
    parser.print_help()
    sys.exit(1)

distsuffix = ''
tag = args[0]
pkgstoignore = []

if config.has_section(tag) and config.has_option(tag, 'blacklist'):
    pkgstoignore = config.get(tag, 'blacklist').split(' ')

disttag = config.get(tag, 'disttag').split()
if tag.startswith('satellite'):
    tag = tag + '-candidate'

if opts.copr:
    from copr import CoprClient
    buildsystem='copr'
    owner, project = tag.split('/',2)
    myclient = CoprClient.create_from_file_config()
    result = myclient.get_packages_list(ownername=owner, projectname=project,
                                         with_latest_build=True,
                                         with_latest_succeeded_build=True)
    rpmlist = []
    for pkg in result.packages_list:
                pkg_name = pkg.data['name']
                pkg_succeeded = pkg.data['latest_succeeded_build']
                if pkg_succeeded:
                    pkg_version = pkg_succeeded['pkg_version']
                else:
                    # packages inherited from forked repo has no latest_succeeded_build
                    pkg_latest = pkg.data['latest_build']
                    if pkg_latest and pkg_latest['state'] == "forked":
                       pkg_version = pkg_latest['pkg_version']
                    else:
                       # no latest build
                       continue

                pkg_nvr = "%s-%s" % (pkg.data['name'],
                                     # version without epoch
                                     pkg_version.split(':')[-1])
                rpmlist.append({'name': pkg_name, 'nvr': pkg_nvr})

else:
    if opts.brew:
        import brew as koji
        buildsystem = 'brew'
        mysession = koji.ClientSession("http://brewhub.devel.redhat.com/brewhub")
        distsuffix = 'sat'
    else:
        import koji
        buildsystem = 'koji'
        mysession = koji.ClientSession("http://koji.spacewalkproject.org/kojihub")

    rpmlist = mysession.getLatestRPMS(tag)[1]

nvrs = []
kojinames = []
pkglist = []
gitnames = []
notingit = []
for rpm in rpmlist:
    rpmname = rpm['nvr'].rstrip(distsuffix)
    if isinstance(disttag, str):
        rpmname = rpmname.replace(disttag, '')
    else:
        for d in disttag:
            rpmname = rpmname.replace(d, '')
    if rpm['name'] not in pkgstoignore:
        nvrs.append(rpmname)
        kojinames.append([rpm['name'], rpmname])

pkgfileList = os.listdir( '%s/packages/' % str(os.path.abspath(__file__)).strip('koji-missing-builds.py'))
pkgfileList.remove('.README')
pkgfileList.remove('.readme')
for item in pkgstoignore:
    try:
        pkgfileList.remove(item)
    except ValueError:
        pass

for pkg in pkgfileList:
    fd = open('%s/packages/%s' % (str(os.path.abspath(__file__)).strip('koji-missing-builds.py'), pkg))
    pkginfo = fd.read()
    fd.close()
    pkginfo = pkginfo.split()
    pkglist.append("%s-%s" % (pkg, pkginfo[0].rstrip('-' + distsuffix)))
    gitnames.append(pkg)

pkglist.sort()
nvrs.sort()
if opts.git:
    print "Builds not in git:"
for pkg in kojinames:
    if not pkg[0] in gitnames:
        if opts.git:
            print "     %s" % pkg[1]
        notingit.append(pkg[1])

if opts.no_extra:
    print "Extra builds in %s:" % buildsystem
    for pkg in nvrs:
        if not pkg in pkglist and not pkg in notingit:
            print "     %s" % pkg

print "Builds missing in %s:" % buildsystem
for pkg in pkglist:
    if not pkg in nvrs:
        print "     %s" % pkg

