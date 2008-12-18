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

def check_tag_exists(tag):
    """ Check that the given git tag exists. """
    # TODO: This is letting you build tags that do not exist in the remote repo.
    # Replace with same method used in Makefile.srpm. Watch for usage of 
    # TAG_SHA1
    (status, output) = commands.getstatusoutput("git tag | grep %s" % tag)
    if status > 0:
        error_out("Unable to locate git tag: %s" % tag)

def debug(text):
    """
    Print the text if --debug was specified.
    """
    if os.environ.has_key('DEBUG'):
        print text

def get_spec_version_and_release(sourcedir, spec_file_name):
        command = """rpm -q --qf '%%{version}-%%{release}\n' --define "_sourcedir %s" --define 'dist %%undefined' --specfile %s | head -1""" % (sourcedir, spec_file_name)
        return run_command(command)

def get_spec_version(sourcedir, spec_file_name):
        command = """rpm -q --qf '%%{version}\n' --define "_sourcedir %s" --define 'dist %%undefined' --specfile %s | head -1""" % (sourcedir, spec_file_name)
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



class BuildCommon:
    """
    Builder and Tagger classes require a little bit of the same functionality.
    Placing that code here to be inherited by both.
    """
    def __init__(self, debug=False):
        self.debug = debug

        self.git_root = find_git_root() 
        self.rel_eng_dir = os.path.join(self.git_root, "rel-eng")

    def _get_latest_tagged_version(self):
        """
        Return the latest git tag for this package in the current branch.
        Uses the info in rel-eng/packages/package-name and error out if the
        file does not exist.

        Returns None if file does not exist.
        """
        file_path = "%s/packages/%s" % (self.rel_eng_dir, self.project_name)
        debug("Getting latest package info from: %s" % file_path)
        if not os.path.exists(file_path):
            return None

        output = run_command("awk '{ print $1 ; exit }' %s" % file_path)
        return output


