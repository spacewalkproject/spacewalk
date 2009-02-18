#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.

import os
import re
import os.path
import sys
import commands

DEFAULT_BUILD_DIR = "/tmp/spacewalk-build"

def error_out(error_msgs):
    """
    Print the given error message (or list of messages) and exit.
    """
    if isinstance(error_msgs, list):
        for line in error_msgs:
            print "ERROR: %s" % line
    else:
        print "ERROR: %s" % error_msgs
    sys.exit(1)

def find_spec_file(in_dir=None):
    """
    Find the first spec file in the current directory. (hopefully there's
    only one)

    Returns only the file name, rather than the full path.
    """
    if in_dir == None:
        in_dir = os.getcwd()
    for f in os.listdir(in_dir):
        if f.endswith(".spec"):
            return f
    error_out(["Unable to locate a spec file in %s" % in_dir])

def find_git_root():
    """
    Find the top-level directory for this git repository.

    Returned as a full path.
    """
    (status, cdup) = commands.getstatusoutput("git rev-parse --show-cdup")
    if status > 0:
        error_out(["%s does not appear to be within a git checkout." % \
                os.getcwd()])

    if cdup == "":
        cdup = "./"
    return os.path.abspath(cdup)

def run_command(command):
    (status, output) = commands.getstatusoutput(command)
    if status > 0:
        sys.stderr.write("\n########## ERROR ############\n")
        sys.stderr.write("Error running command: %s\n" % command)
        sys.stderr.write("Status code: %s\n" % status)
        sys.stderr.write("Command output: %s\n" % output)
        raise Exception("Error running command")
    return output

def check_tag_exists(tag, offline=False):
    """
    Check that the given git tag exists in a git repository.
    """
    (status, output) = commands.getstatusoutput("git tag | grep %s" % tag)
    if status > 0:
        error_out("Tag does not exist locally: [%s]" % tag)

    tag_sha1 = run_command(
            "git ls-remote ./. --tag %s | awk '{ print $1 ; exit }'"
            % tag)
    debug("Local tag SHA1: %s" % tag_sha1)

    if offline:
        return

    repo_url = get_git_repo_url()
    print("Checking for tag [%s] in git repo [%s]" % (tag, repo_url))
    upstream_tag_sha1 = run_command(
            "git ls-remote %s --tag %s | awk '{ print $1 ; exit }'" %
            (repo_url, tag))
    if upstream_tag_sha1 == "":
        error_out(["Tag does not exist in remote git repo: %s" % tag,
            "You must --tag-release, then git push and git push --tags"])

    debug("Remote tag SHA1: %s" % upstream_tag_sha1)
    if upstream_tag_sha1 != tag_sha1:
        error_out("Tag %s references %s locally but %s upstream." % (tag,
            tag_sha1, upstream_tag_sha1))

def debug(text):
    """
    Print the text if --debug was specified.
    """
    if os.environ.has_key('DEBUG'):
        print text

def get_spec_version_and_release(sourcedir, spec_file_name):
        command = """rpm -q --qf '%%{version}-%%{release}\n' --define "_sourcedir %s" --define 'dist %%undefined' --specfile %s 2> /dev/null | head -1""" % (sourcedir, spec_file_name)
        return run_command(command)

def get_project_name(tag=None):
    """
    Extract the project name from the specified tag or a spec file in the
    current working directory. Error out if neither is present.
    """
    if tag != None:
        p = re.compile('(.*?)-(\d.*)')
        m = p.match(tag)
        if not m:
            error_out("Unable to determine project name in tag: %s" % tag)
        return m.group(1)
    else:
        spec_file_path = os.path.join(os.getcwd(), find_spec_file())
        if not os.path.exists(spec_file_path):
            error_out("Unable to get project name from spec file: %s" %
                    spec_file_path)

        output = run_command(
            "cat %s | grep 'Name:' | awk '{ print $2 ; exit }'" %
            spec_file_path)
        return output

def get_relative_project_dir(project_name, commit):
    """
    Return the project's sub-directory relative to the git root.

    This could be a different directory than where the project currently
    resides, so we export a copy of the project's metadata from
    rel-eng/packages/ at the point in time of the tag we are building.
    """
    cmd = "git show %s:rel-eng/packages/%s" % (commit,
            project_name)
    pkg_metadata = run_command(cmd).strip()
    tokens = pkg_metadata.split(" ")
    debug("Got package metadata: %s" % tokens)
    return tokens[1]

def get_build_commit(tag, test=False):
    """ Return the git commit we should build. """
    if test:
        return get_git_head_commit()
    else:
        tag_sha1 = run_command(
                "git ls-remote ./. --tag %s | awk '{ print $1 ; exit }'"
                % tag)
        commit_id = run_command('git rev-list --max-count=1 %s' % 
                tag_sha1)
        return commit_id

def get_git_head_commit():
    """ Return the SHA1 of the HEAD commit on the current git branch. """
    return commands.getoutput('git rev-parse --verify HEAD')

def get_commit_timestamp(sha1_or_tag):
    """
    Get the timestamp of the git commit or tag we're building. Used to
    keep the hash the same on all .tar.gz's we generate for a particular
    version regardless of when they are generated.
    """
    output = run_command(
            "git rev-list --timestamp --max-count=1 %s | awk '{print $1}'"
            % sha1_or_tag)
    return output

def create_tgz(git_root, prefix, commit, relative_dir, rel_eng_dir, 
    dest_tgz):
    """
    Create a .tar.gz from a projects source in git.
    """
    os.chdir(os.path.abspath(git_root))
    timestamp = get_commit_timestamp(commit)

    archive_cmd = "git archive --format=tar --prefix=%s/ %s:%s | perl %s/tar-fixup-stamp-comment.pl %s %s | gzip -n -c - | tee %s" % \
        (
                prefix,
                commit,
                relative_dir,
                rel_eng_dir,
                timestamp,
                commit,
                dest_tgz
        )
    #debug(archive_cmd)
    run_command(archive_cmd)

def get_git_repo_url():
    """
    Return the url of this git repo.

    Uses ~/.git/config remote origin url.
    """
    return run_command("git config remote.origin.url")

def get_latest_tagged_version(package_name):
    """
    Return the latest git tag for this package in the current branch.
    Uses the info in rel-eng/packages/package-name.

    Returns None if file does not exist.
    """
    git_root = find_git_root()
    rel_eng_dir = os.path.join(git_root, "rel-eng")
    file_path = "%s/packages/%s" % (rel_eng_dir, package_name)
    debug("Getting latest package info from: %s" % file_path)
    if not os.path.exists(file_path):
        return None

    output = run_command("awk '{ print $1 ; exit }' %s" % file_path)
    if output == None or output.strip() == "":
        error_out("Error looking up latest tagged version in: %s" % file_path)

    return output



