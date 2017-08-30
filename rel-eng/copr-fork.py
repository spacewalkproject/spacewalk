#!/usr/bin/python

from copr import CoprClient
import argparse
import json

parser = argparse.ArgumentParser(
                description='Fork copr nightly repo after Spacewalk release branching')
parser.add_argument('--force', action='store_true', default=False,
                    help='force fork into an existing project')
parser.add_argument('source_repo', nargs=1, help='name of copr repo to be forked' 
                                      ' (e.g. @spacewalkproject/nightly-client)')
parser.add_argument('destination_repo', nargs=1, help='name of newly created copr repo' 
                                      ' (e.g. @spacewalkproject/spacewalk-2.7-client)')
parser.add_argument('git_branch', nargs=1, help='git branch associated with new forked repo' 
                                      ' (e.g. SPACEWALK-2.7)')
opts = parser.parse_args()

dest_owner, dest_project = opts.destination_repo[0].split('/',2)
myclient = CoprClient.create_from_file_config()

print("Forking project: %s -> %s" % (opts.source_repo[0], opts.destination_repo[0]))
myclient.fork_project(source=opts.source_repo[0],
                      username=dest_owner, projectname=dest_project, confirm=opts.force)

result = myclient.get_packages_list(ownername=dest_owner, projectname=dest_project)

for pkg in result.packages_list:
    print(" Updating package: %s" % pkg.data['name'])
    pkg_source = json.loads(pkg.data['source_json'])
    if pkg_source and pkg_source.get('git_url', None):
        myclient.edit_package_tito(package_name=pkg.data['name'],
                                   ownername=dest_owner,
                                   projectname=dest_project,
                                   git_url=pkg_source['git_url'],
                                   git_dir=pkg_source['git_dir'],
                                   git_branch=opts.git_branch[0],
                                   webhook_rebuild=pkg.data['webhook_rebuild'])
    else:
        print("  ERROR: package git url is missing")
