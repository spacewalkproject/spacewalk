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
        owner_status = "OWNER (channel:deployed)"
        group_status = "GROUP (channel:deployed)"
        mode_status = "MODE (channel:deployed)"
        file_status = "FILE"
        
        maxlen = -1

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
                ret_max = max(len(ret_dict['status']), len(ret_dict['owner']), len(ret_dict['group']), len(ret_dict['mode']))
            
                #Which is bigger, the current ret_max or the older value of maxlen?
                maxlen = max(maxlen, ret_max)
            
            #Place the return values into a list so we can iterate through them later when we want to print them out.
            ret.append(ret_dict)

        if self.options.verbose:       
            #Take the column header labels into account when determining the length of each field.
            maxlen = max(maxlen, len(status_label), len(owner_status), len(group_status), len(mode_status), len(file_status))
        
            formatstr = "%-*s"      #format string for the fields where the length matters.
            formatstr_nolimit = "%-s"   #format string for the fields where the length of the field doesn't matter. Namely, the file field.
        
            #The overall format of the output.
            outstring = "%(status)s  %(owner)s  %(group)s  %(mode)s  %(file)s"
        
            #Print out the column labels.
            print outstring % {     
                                    "status"       :       formatstr % (maxlen, status_label),
                                    "owner"        :       formatstr % (maxlen, owner_status),
                                    "group"        :       formatstr % (maxlen, group_status),
                                    "mode"         :       formatstr % (maxlen, mode_status),
                                    "file"         :       formatstr_nolimit % (file_status),
                              }
        
            #Go through each of the dictionaries returned by self._process_file(), format their values, and print out the result.
            for fdict in ret:
                print outstring % {     
                                    "status"       :       formatstr % (maxlen, fdict['status']),
                                    "owner"        :       formatstr % (maxlen, fdict['owner']),
                                    "group"        :       formatstr % (maxlen, fdict['group']),
                                    "mode"         :       formatstr % (maxlen, fdict['mode']),
                                    "file"         :       formatstr_nolimit % (fdict['file'],),
                                  }
        #Not verbose, so give the simple output for each file...
        else:
            outstring = "%9s %s"
            for fdict in ret:
                if fdict['status'] == 'unmodified':
                    mystatus = ""
                else:
                    mystatus = fdict['status']

                print outstring % (mystatus, fdict['file'])
            
            

    def _process_file(self, *args):
        #5/16/05 wregglej - 154433 made the report string so I don't have to modify
        #the output format in mulitple places.
        report = "%9s\t%s\t%s\t%s\t%s" # modified state, owner changes, group changes, permissions changes, file. Was originally "%9s %s"
        owner_report = "%s:%s"
        group_report = "%s:%s"
        perm_report = "%s:%s"

        src, dst, file, type, info = args[:5]
        
        status = 'unmodified'
        stat_err = 0

        #Stat the destination file
        try:
            dst_stat = os.stat(dst)
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
        owner_status = owner_report % (src_user, dst_user)

        src_group = info['groupname']
        if not stat_err:
            #check for group differences
            dst_gid = dst_stat[stat.ST_GID]
            dst_group = grp.getgrgid(dst_gid)[0]
        else:
            dst_group = "missing"
        
        #group_status gets displayed with the verbose option.
        group_status = group_report % (src_group, dst_group)
        
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
        perm_status = perm_report % (src_perm, dst_perm)

        #figure out the ultimate value of status.
        if stat_err:
            status = "missing"

        elif type == 'directory':
            if not os.path.isdir(file):
                status = 'missing'

        elif not os.access(dst, os.R_OK):
            status = "missing"

        else:
            src_sha1 = utils.sha1_file(src)
            dst_sha1 = utils.sha1_file(dst)
            if src_sha1 != dst_sha1:
                status = 'modified'

        return {
                    "status"            :   status,
                    "owner"             :   owner_status,
                    "group"             :   group_status,
                    "mode"              :   perm_status,
                    "file"              :   file,
               }

