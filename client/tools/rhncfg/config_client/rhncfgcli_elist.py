from config_common.rhn_log import log_debug, die
from config_common.file_utils import ostr_to_sym
import handler_base, base64
import sys
from rhn.i18n import bstr


class Handler(handler_base.HandlerBase):
    def run(self):
        log_debug(2)
        r = self.repository
        files = r.list_files()

        if not files:
            die(1, "No managed files.")

        label = "Config Channel"
        maxlen = max([len(s[0]) for s in files])
        maxlen = max(maxlen, len(label)) + 2
        print("%-10s %8s %-8s %10s %+3s    %*s    %s" % ('Mode', 'Owner', 'Group', 'Size', 'Rev', maxlen, label, "File"))

        arg_files = []
        if len(sys.argv) > 2:
            arg_files = sys.argv[2:len(sys.argv)]

        for file in files:

            if len(arg_files) and not file[1] in arg_files:
                continue

            # Get the file info
            finfo = r.get_file_info(file[1])[1]
            # Get the file length
            if finfo['encoding'] == 'base64':
                fsize = len(base64.decodestring(bstr(finfo['file_contents'])))
            else:
                # * indicates raw 'unencoded' size
                fsize = '*' + str(len(finfo['file_contents']))

            if finfo['filetype'] == 'symlink':
                permstr = ostr_to_sym('777', finfo['filetype'])
                dest = "%s -> %s" % (file[1], finfo['symlink'])
                fsize = str(len(finfo['symlink']))
                finfo['username'] = 'root'
                finfo['groupname'] = 'root'
            else:
                permstr = ostr_to_sym(finfo['filemode'], finfo['filetype']) or ''
                dest = file[1]
            print("%10s %8s %-8s %10s %+3s    %*s    %s" % (permstr, finfo['username'], finfo['groupname'], fsize, finfo['revision'], maxlen, file[0], dest))

