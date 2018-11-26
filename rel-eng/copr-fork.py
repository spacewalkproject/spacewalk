#!/usr/bin/python

from copr import CoprClient
import argparse
import json

parser = argparse.ArgumentParser(
                description='Fork copr nightly repo after Spacewalk release branching')
parser.add_argument('--force', action='store_true', default=False,
                    help='force fork into an existing project')
parser.add_argument('--only-update-packages', action='store_true', default=False,
                    help='update package information on already forked repo')
parser.add_argument('source_repo', nargs=1, help='name of copr repo to be forked' 
                                      ' (e.g. @spacewalkproject/nightly-client)')
parser.add_argument('destination_repo', nargs=1, help='name of newly created copr repo' 
                                      ' (e.g. @spacewalkproject/spacewalk-2.7-client)')
parser.add_argument('git_branch', nargs=1, help='git branch associated with new forked repo' 
                                      ' (e.g. SPACEWALK-2.7)')
opts = parser.parse_args()

dest_owner, dest_project = opts.destination_repo[0].split('/',2)
myclient = CoprClient.create_from_file_config()

if not opts.only_update_packages:
    print("Forking project: %s -> %s" % (opts.source_repo[0], opts.destination_repo[0]))
    myclient.fork_project(source=opts.source_repo[0],
                          username=dest_owner, projectname=dest_project, confirm=opts.force)
    myclient.modify_project(username=dest_owner, projectname=dest_project,
                            description='%s packages' % opts.git_branch[0])

result = myclient.get_packages_list(ownername=dest_owner, projectname=dest_project)

for pkg in result.packages_list:
    print(" Updating package: %s" % pkg.data['name'])
    pkg_source = json.loads(pkg.data['source_json'])
    if pkg_source and pkg_source.get('clone_url', None):
        myclient.edit_package_scm(package_name=pkg.data['name'],
                                   ownername=dest_owner,
                                   projectname=dest_project,
                                   scm_type='git',
                                   srpm_build_method='tito',
                                   clone_url=pkg_source['clone_url'],
                                   subdirectory=pkg_source['subdirectory'],
                                   committish=opts.git_branch[0]
                                   )
    else:
        print("  ERROR: package git url is missing")
