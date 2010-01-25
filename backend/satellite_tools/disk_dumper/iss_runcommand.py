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

import os
import subprocess
import fcntl
import select
import sys
import StringIO


#   Adapted from the Python Cookbook recipe called
#   "Capturing the Output and Error Streams from a
#    Unix Shell Command."

def make_fd_nonblocking(file_desc):
    flags = fcntl.fcntl(file_desc, fcntl.F_GETFL)

    try:
        fcntl.fcntl(file_desc, fcntl.F_SETFL, flags | os.O_NDELAY)
    except AttributeError:
        fcntl.fcntl(file_desc, fcntl.F_SETFL, flags | fcntl.FNDELAY)

def run_command(command):
    command_process = subprocess.Popen(command, stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                            close_fds=True, shell=(not (type(cmd) in (types.ListType, types.TupleType))) )
    outstring = StringIO.StringIO()
    errstring = StringIO.StringIO()
    
    command_process.stdin.close() # Don't need input to command_process.
    outfile = command_process.stdout
    outfile_fd = outfile.fileno()
    errfile = command_process.stderr
    errfile_fd = errfile.fileno()
    
    make_fd_nonblocking(outfile_fd)
    make_fd_nonblocking(errfile_fd)

    outdata, errdata = [], []
    out_eof = err_eof = False
    
    while True:
        to_check = [outfile_fd] * (not out_eof) + [errfile_fd] * (not err_eof)
        ready = select.select(to_check, [], [])

        if outfile_fd in ready[0]:
            outchunk = outfile.read()
            if outchunk == '':
                out_eof = True
            else:
                sys.stdout.write(outchunk)
                outstring.write(outchunk)

        if errfile_fd in ready[0]:
            errchunk = errfile.read()
            if errchunk == '':
                err_eof = True
            else:
                sys.stderr.write(errchunk)
                errstring.write(errchunk)

        if out_eof and err_eof:
            break

        select.select([], [], [], .1)

    status = command_process.wait()
    outval = outstring.getvalue()
    errval = errstring.getvalue()
    outstring.close()
    errstring.close()
    return status, outval, errval

if __name__ == "__main__":
    status = run_command("ls -l")
    print status

    
