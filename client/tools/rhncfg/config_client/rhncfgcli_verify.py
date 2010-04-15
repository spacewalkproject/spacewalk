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
#

from config_common import utils
from config_common.rhn_log import log_debug

import handler_base
import os
import stat
import pwd, grp
try:
    from selinux import lgetfilecon
except:
    # on rhel4 we do not support selinux
    def lgetfilecon(path):
        return [0, '']

class Handler(handler_base.HandlerBase):
    _usage_options = handler_base.HandlerBase._usage_options + " [ files ... ]"
    _options_table = [
        handler_base.HandlerBase._option_class(
            '--verbose',
            "-v", 
            action="count",
            help="Increase the amount of output detail.",
        ),
    ]

    # Main function to be run
    def run(self):
        log_debug(2)
        ret = []

        #Labels for column headers
        status_label = "STATUS"
        owner_status = "OWNER"
        group_status = "GROUP"
        mode_status = "MODE"
        selinux_status = "SELINUX"
        file_status = "FILE"

        status_help = "(channel:local)"
        
        maxlenarr = {
            'status' : len(status_label),
            'owner' : max(len(owner_status), len(status_help)),
            'group' : max(len(group_status), len(status_help)),
            'mode' : max(len(mode_status), len(status_help)),
            'selinux' : max(len(selinux_status), len(status_help)),
        }

        #Iterate throught the files and process them. The src file is the file as it is in the config channel,
        #the dst file is the file as it is in the filesystem.
        for file in self.get_valid_files():
            (src, file_info, dirs_created) = self.repository.get_file_info(file)

            ftype = file_info.get('filetype')

            if not src:
                continue

            dst = self.get_dest_file(file)

            #Added file_info parameter, which contains information needed to look for differences in the owner, group, and mode.            
            ret_dict = self._process_file(src, dst, file, ftype, file_info)

            if self.options.verbose:
                #Get the max of the return values for this file, which is used to determine the length of each field in the output.
                #Don't include the 'file' value, because it gets displayed last in each row and will throw off the size of the other fields.
                maxlenarr['status'] = max(maxlenarr['status'], len(ret_dict['status']))
                maxlenarr['owner'] = max(maxlenarr['owner'], len(ret_dict['owner']))
                maxlenarr['group'] = max(maxlenarr['group'], len(ret_dict['group']))
                maxlenarr['mode'] = max(maxlenarr['mode'], len(ret_dict['mode']))
                if len(ret_dict['selinux']) > 0:
                    (src, dst) = ret_dict['selinux'].split('|')
                    maxlenarr['selinux'] = max(maxlenarr['selinux'], len(src), len(dst))

            #Place the return values into a list so we can iterate through them later when we want to print them out.
            ret.append(ret_dict)

        if self.options.verbose:       
            formatstr = "%-*s"      #format string for the fields where the length matters.
            formatstr_nolimit = "%-s"   #format string for the fields where the length of the field doesn't matter. Namely, the file field.

            #The overall format of the output.
            outstring = "%(status)s  %(owner)s  %(group)s  %(mode)s  %(selinux)s  %(file)s"

            #Print out the column labels.
            print outstring % {     
                                    "status"       :       formatstr % (maxlenarr['status'], status_label),
                                    "owner"        :       formatstr % (maxlenarr['owner'], owner_status),
                                    "group"        :       formatstr % (maxlenarr['group'], group_status),
                                    "mode"         :       formatstr % (maxlenarr['mode'], mode_status),
                                    "selinux"      :       formatstr % (maxlenarr['selinux'], selinux_status),
                                    "file"         :       formatstr_nolimit % (file_status),
                              }

            print outstring % {
                                    "status"       :       formatstr % (maxlenarr['status'], ""),
                                    "owner"        :       formatstr % (maxlenarr['owner'], status_help),
                                    "group"        :       formatstr % (maxlenarr['group'], status_help),
                                    "mode"         :       formatstr % (maxlenarr['mode'], status_help),
                                    "selinux"      :       formatstr % (maxlenarr['selinux'], status_help),
                                    "file"         :       ""
                              }

            #Go through each of the dictionaries returned by self._process_file(), format their values, and print out the result.
            for fdict in ret:
                src_selinux = dst_selinux = ""
                if len(fdict['selinux']) > 0:
                    (src_selinux, dst_selinux) = fdict['selinux'].split('|')

                print outstring % {
                                    "status"       :       formatstr % (maxlenarr['status'], fdict['status']),
                                    "owner"        :       formatstr % (maxlenarr['owner'], fdict['owner']),
                                    "group"        :       formatstr % (maxlenarr['group'], fdict['group']),
                                    "mode"         :       formatstr % (maxlenarr['mode'], fdict['mode']),
                                    "selinux"      :       formatstr % (maxlenarr['selinux'], src_selinux),
                                    "file"         :       formatstr_nolimit % (fdict['file']),
                                  }
                if len(dst_selinux) > 0:
                    print outstring % {
                                    "status"       :       formatstr % (maxlenarr['status'], ""),
                                    "owner"        :       formatstr % (maxlenarr['owner'], ""),
                                    "group"        :       formatstr % (maxlenarr['group'], ""),
                                    "mode"         :       formatstr % (maxlenarr['mode'], ""),
                                    "selinux"      :       formatstr % (maxlenarr['selinux'], dst_selinux),
                                    "file"         :       "",
                                      }
        #Not verbose, so give the simple output for each file...
        else:
            outstring = "%*s %s"
            maxlen = max(map(lambda x: len(x['status']), ret)) + 1
            for fdict in ret:
                print outstring % (maxlen, fdict['status'], fdict['file'])

    def _process_file(self, *args):
        owner_report = "%s:%s"
        group_report = "%s:%s"
        perm_report = "%s:%s"
        selinux_report = "%s|%s"

        src, dst, file, type, info = args[:5]
        
        status = []
        stat_err = 0

        #Stat the destination file
        try:
            dst_stat = os.lstat(dst)
        except:
            stat_err = 1

        src_user = info['username']
        if not stat_err:
            #check for owner differences
            dst_uid = dst_stat[stat.ST_UID]
            try:
                dst_user = pwd.getpwuid(dst_uid)[0]
            except KeyError:
                # Orphan UID with no name,return unknown
                dst_user = "unknown(UID %d)" % (dst_uid,)
        else:
            dst_user = "missing"
        
        #owner_status gets displayed with the verbose option.
        if src_user == dst_user:
            owner_status = ""
        else:
            owner_status = owner_report % (src_user, dst_user)
            status.append('user')

        src_group = info['groupname']
        if not stat_err:
            #check for group differences
            dst_gid = dst_stat[stat.ST_GID]
            try:
                dst_group = grp.getgrgid(dst_gid)[0]
            except KeyError:
                # Orphan GID with no name,return unknown
                dst_group = "unknown(GID %d)" % (dst_gid,)
        else:
            dst_group = "missing"

        #group_status gets displayed with the verbose option.
        if src_group == dst_group:
            group_status = ""
        else:
            group_status = group_report % (src_group, dst_group)
            status.append('group')
        
        #check for permissions differences
        src_perm = str(info['filemode'])
        if not stat_err:
            #The mode returned by stat is decimal, but won't match the value in file_info unless it's octal.
            #Unfortunately, the mode in file_info looks like the octal value of the mode, except it's in decimal.
            #The solution I came up with is to convert them both into strings, rip off the leading '0' from the
            #mode returned by stat, use the resulting strings. It sucks, but it seems to work (for now).
            dst_perm = str(oct(stat.S_IMODE(dst_stat[stat.ST_MODE])))
        else:
            dst_perm = "missing"

        #rip off the leading '0' from the mode returned by stat()
        if dst_perm[0] == '0':
            dst_perm = dst_perm[1:]
        
        #perm_status gets displayed with the verbose option.
        if src_perm == dst_perm:
            perm_status = ""
        else:
            perm_status = perm_report % (src_perm, dst_perm)
            status.append('mode')

        # compare selinux contexts
        src_selinux = info['selinux_ctx']
        if not stat_err:
            dst_selinux = lgetfilecon(dst)[1]
            if dst_selinux == None:
                dst_selinux = ""
        else:
            dst_selinux = "missing"

        if src_selinux == dst_selinux:
            selinux_status = ""
        else:
            selinux_status = selinux_report % (src_selinux, dst_selinux)
            status.append('selinux')

        #figure out the ultimate value of status.
        if stat_err:
            status = ["missing"]

        elif type == 'directory':
            if not os.path.isdir(file):
                status = ["missing"]

        elif not os.access(dst, os.R_OK):
            status = ["missing"]

        else:
            src_sha1 = utils.sha1_file(src)
            dst_sha1 = utils.sha1_file(dst)
            if src_sha1 != dst_sha1:
                status.append('modified')

        return {
                    "status"            :   ','.join(status),
                    "owner"             :   owner_status,
                    "group"             :   group_status,
                    "mode"              :   perm_status,
                    "selinux"           :   selinux_status,
                    "file"              :   file,
               }

