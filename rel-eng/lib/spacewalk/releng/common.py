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
import os.path
import sys
import commands

from string import strip

def read_config():
    """
    Read config settings in from ~/.spacewalk-build-rc.
    """
    file_loc = os.path.expanduser("~/.spacewalk-build-rc")
    try:
        f = open(file_loc)
    except:
        # File doesn't exist but that's ok because it's optional.
        return {}
    config = {}
    #print "Reading config file: %s" % file_loc
    for line in f.readlines():
        tokens = line.split(" = ")
        if len(tokens) != 2:
            raise Exception("Error parsing ~/.spacewalk-build-rc: %s" % line)
        config[tokens[0]] = strip(tokens[1])
        #print "   %s = %s" % (tokens[0], strip(tokens[1]))
    return config

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

def find_spec_file():
    """
    Find the first spec file in the current directory. (hopefully there's
    only one)

    Returns only the file name, rather than the full path.
    """
    for f in os.listdir(os.getcwd()):
        if f.endswith(".spec"):
            return f
    error_out(["Unable to locate a spec file in %s" % os.getcwd()])

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
    print os.getcwd()
    (status, output) = commands.getstatusoutput("git tag | grep %s" % tag)
    if status > 0:
        raise Exception("Unable to locate git tag: %s" % tag)

def debug(text):
    """
    Print the text if --debug was specified.
    """
    if os.environ.has_key('DEBUG'):
        print text



class BuildCommon:
    """
    Builder and Tagger classes require a little bit of the same functionality.
    Placing that code here to be inherited by both.
    """
    def __init__(self, debug=False):
        self.debug = debug

        self.git_root = find_git_root() 
        self.rel_eng_dir = os.path.join(self.git_root, "rel-eng")
        self.relative_project_dir = self._get_relative_project_dir(
                self.git_root) # i.e. java/
        self.full_project_dir = os.getcwd()
        self.spec_file_name = find_spec_file()
        self.project_name = self._get_project_name()

    def _get_project_name(self):
        """
        Get the project name from the spec file.

        Uses the spec file in the current git branch as opposed to the copy
        we make using git archive. This is done because we use this
        information to know what git tag to use to generate that archive.
        """
        spec_file_path = os.path.join(self.full_project_dir,
                self.spec_file_name)
        if not os.path.exists(spec_file_path):
            raise Exception("Unable to get project name from spec file: %s" %
                    spec_file_path)

        output = run_command(
            "cat %s | grep 'Name:' | awk '{ print $2 ; exit }'" %
            spec_file_path)
        return output

    def _get_relative_project_dir(self, git_root):
        """
        Returns the patch to the project we're working with relative to the
        git root.

        *MUST* be called before doing any os.cwd().

        i.e. java/, satellite/install/Spacewalk-setup/, etc.
        """
        # TODO: I think this can be done with rel-eng/packages/ data instead.
        current_dir = os.getcwd()
        relative = current_dir[len(git_root) + 1:] + "/"
        return relative

    def _get_latest_tagged_version(self):
        """
        Return the latest git tag for this package in the current branch.

        Uses the info in rel-eng/packages/package-name.
        """
        file_path = "%s/packages/%s" % (self.rel_eng_dir, self.project_name)
        try:
            output = run_command("awk '{ print $1 ; exit }' %s" % file_path)
        except:
            error_out(["Unable to lookup latest package info from %s" %
                    file_path, "Perhaps you need to --tag-release first?"])

        return output


