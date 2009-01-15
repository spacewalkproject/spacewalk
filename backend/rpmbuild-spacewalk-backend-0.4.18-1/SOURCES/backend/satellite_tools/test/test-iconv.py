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
import sys
import iconv
import string

def main():
    run = 0
    total_runs = 100000
    modulo = 1000
    while 1:
        if run % modulo == 0:
            print_mem_usage(run)

        if run == total_runs:
            break
        
        run = run + 1

        cd = iconv.CD("UTF-8", "iso-8859-1")
        cd.close()
    print_mem_usage(total_runs)

def print_mem_usage(run):
    d = mem_usage()
    sys.stderr.write("%-3d name: %s; vsz: %s; rss: %s; vmdata: %s\n" % 
        (run, d[0], d[1], d[2], d[3]))

def mem_usage():
    f = open("/proc/self/status")
    dict = {}
    while 1:
        line = f.readline()
        if not line:
            break
        arr = map(string.strip, string.split(line, ':', 1))
        if len(arr) == 1:
            continue
        dict[arr[0]] = arr[1]
    return dict['Name'], dict['VmSize'], dict['VmRSS'], dict['VmData']

if __name__ == '__main__':
    sys.exit(main() or 0)
