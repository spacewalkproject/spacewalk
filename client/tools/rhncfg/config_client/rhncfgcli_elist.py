from config_common.rhn_log import log_debug, die
import handler_base, base64, stat

class Handler(handler_base.HandlerBase):
    def ostr_to_sym(self, octstr, ftype):
        mode = int(str(octstr), 8)

        if ftype == 'directory':
            symstr = 'd'
        else:
            symstr = '-'

        if mode & stat.S_IRUSR:
            symstr += 'r'
        else:
            symstr += '-'

        if mode & stat.S_IWUSR:
            symstr += 'w'
        else:
            symstr += '-'

        if mode & stat.S_IXUSR:
            if mode & stat.S_ISUID:
                symstr += 's'
            else:
                symstr += 'x'
        else:
            if mode & stat.S_ISUID:
                symstr += 'S'
            else:
                symstr += '-'

        if mode & stat.S_IRGRP:
            symstr += 'r'
        else:
            symstr += '-'

        if mode & stat.S_IWGRP:
            symstr += 'w'
        else:
            symstr += '-'

        if mode & stat.S_IXGRP:
            if mode & stat.S_ISGID:
                symstr += 's'
            else:
                symstr += 'x'
        else:
            if mode & stat.S_ISGID:
                symstr += 'S'
            else:
                symstr += '-'

        if mode & stat.S_IROTH:
            symstr += 'r'
        else:
            symstr += '-'

        if mode & stat.S_IWOTH:
            symstr += 'w'
        else:
            symstr += '-'

        if mode & stat.S_IXOTH:
            if mode & stat.S_ISVTX:
                symstr += 't'
            else:
                symstr += 'x'
        else:
            if mode & stat.S_ISVTX:
                symstr += 'T'
            else:
                symstr += '-'

        return symstr


    def run(self):
        log_debug(2)
        r = self.repository
        files = r.list_files()

        if not files:
            die(1, "No managed files.")

        label = "Config Channel"
        maxlen = max(map(lambda s: len(s[0]), files))
        maxlen = max(maxlen, len(label)) + 2
        print "%-10s %8s %-8s %10s %+3s    %*s    %s" % ('Mode', 'Owner', 'Group', 'Size', 'Rev', maxlen, label, "File")

        for file in files:

            # Get the file info
            finfo = r.get_file_info(file[1])[1]
            # Get the file length
            if finfo['encoding'] == 'base64':
                fsize = len(base64.decodestring(finfo['file_contents']))
            else:
                # * indicates raw 'unencoded' size
                fsize = '*' + str(len(finfo['file_contents']))

            permstr = finfo['filetype'] != 'symlink' and self.ostr_to_sym(finfo['filemode'], finfo['filetype']) or ''
            dest = finfo['filetype'] != 'symlink' and file[1] or "%s -> %s" % (file[1], finfo['symlink']) 
            print "%10s %8s %-8s %10s %+3s    %*s    %s" % (permstr, finfo['username'], finfo['groupname'], fsize, finfo['revision'], maxlen, file[0], dest)

