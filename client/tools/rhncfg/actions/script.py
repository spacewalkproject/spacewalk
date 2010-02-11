#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
import sys
import pwd
import grp
import time
import select
import signal
import tempfile
import base64
from subprocess import MAXFD


# this is ugly, hopefully it will be natively supported in up2date
from configfiles import _local_permission_check, _perm_error


# this is a list of the methods that get exported by a module
__rhnexport__ = [
    'run',
    ]

# action version we understand
ACTION_VERSION = 2


def _create_script_file(script, uid=None, gid=None):

    storageDir = tempfile.gettempdir()
    script_path = os.path.join(storageDir, 'rhn-remote-script')

    # Loop a couple of times to try to get rid of race conditions
    for i in range(2):
        try:
            fd = os.open(script_path, os.O_RDWR | os.O_CREAT | os.O_EXCL, 0700)
            # If this succeeds, break out the loop
            break
        except OSError, e:
            if e.errno != 17: # File exists
                raise
            # File does exist, try to remove it
            try:
                os.unlink(script_path)
            except OSError, e:
                if e.errno != 2: # No such file or directory
                    raise
    else:
        # Tried a couple of times, failed; bail out raising the latest error
        raise
    sf = os.fdopen(fd, 'w')
    sf.write(script)
    sf.close()

    if uid and gid:
        os.chown(script_path, uid, gid)

    return script_path


def run(action_id, params):

    action_type = 'script.run'
    if not _local_permission_check(action_type):
        return _perm_error(action_type)
        

    extras = {'output':''}
    script = params.get('script')
    if not script:
        return (1, "No script to execute", {})

    username = params.get('username')
    groupname = params.get('groupname')

    if not username:
        return (1, "No username given to execute script as", {})

    if not groupname:
        return (1, "No groupname given to execute script as", {})

    timeout = params.get('timeout')

    if timeout:
        try:
            timeout = int(timeout)
        except ValueError:
            return (1, "Invalid timeout value", {})
    else:
        timeout = None

    db_now = params.get('now')
    if not db_now:
        return (1, "'now' argument missing", {})
    db_now = time.mktime(time.strptime(db_now, "%Y-%m-%d %H:%M:%S")) 

    now = time.time()
    process_start = None
    process_end = None

    child_pid = None

    # determine uid/ugid for script ownership, uid also used for setuid...
    try:
        user_record = pwd.getpwnam(username)
    except KeyError:
        return 1, "No such user %s" % username, extras

    uid = user_record[2]
    ugid = user_record[3]


    # create the script on disk
    try:
        script_path = _create_script_file(script, uid=uid, gid=ugid)
    except OSError, e:
        return 1, "Problem creating script file:  %s" % e, extras

    # determine gid to run script as
    try:
        group_record = grp.getgrnam(groupname)
    except KeyError:
        return 1, "No such group %s" % groupname, extras

    run_as_gid = group_record[2]


    # create some pipes to communicate w/ the child process
    (pipe_read, pipe_write) = os.pipe()

    process_start = time.time()
    child_pid = os.fork()

    if not child_pid:
        # Parent doesn't write to child, so close that part
        os.close(pipe_read)
        
        # Redirect both stdout and stderr to the pipe
        os.dup2(pipe_write, sys.stdout.fileno())
        os.dup2(pipe_write, sys.stderr.fileno())

        # Close unnecessary file descriptors (including pipe since it's duped)
        for i in range(3, MAXFD):
            try:
                os.close(i)
            except:
                pass

        # all scripts initial working directory will be /
        # puts burden on script writer to ensure cwd is correct within the 
        # script
        os.chdir('/')
        
        # the child process gets the desired uid/gid
        os.setgid(run_as_gid)
        os.setuid(uid)

        # give this its own process group (which happens to be equal to its 
        # pid)
        os.setpgrp()

        # Finally, exec the script
        try:
	    oumask = os.umask(022)
            os.execv(script_path, [script_path, ])
	    os.umask(oumask)
        finally:
            # Shouldn't reach this part - execv never returns
            os._exit(1)

    # Parent doesn't write to child, so close that part
    os.close(pipe_write)

    output = None
    timed_out = None

    out_stream = tempfile.TemporaryFile()

    while 1:
        select_wait = None
        
        if timeout:
            elapsed = time.time() - process_start

            if elapsed >= timeout:
                timed_out = 1
                # Send TERM to all processes in the child's process group
                # Send KILL after that, just to make sure the child died
                os.kill(-child_pid, signal.SIGTERM)
                time.sleep(2)
                os.kill(-child_pid, signal.SIGKILL)
                break

            select_wait = timeout - elapsed

        # XXX try-except here for interrupted system calls
        input_fds, output_fds, error_fds = select.select([pipe_read], [], [], select_wait)
        
        if error_fds:
            # when would this happen?
            os.close(pipe_read)
            return 1, "Fatal exceptional case", extras
        
        if not (pipe_read in input_fds):
            # Read timed out, should be caught in the next loop
            continue

        output = os.read(pipe_read, 4096)
        if not output:
            # End of file from the child
            break

        out_stream.write(output)

    os.close(pipe_read)

    # wait for the child to complete
    (somepid, exit_status) = os.waitpid(child_pid, 0)    
    process_end = time.time()

    # Copy the output from the temporary file
    out_stream.seek(0, 0)
    extras['output'] = out_stream.read()
    out_stream.close()

    # since output can contain chars that won't make xmlrpc very happy,
    # base64 encode it...
    extras['base64enc'] = 1
    extras['output'] = base64.encodestring(extras['output'])

    extras['return_code'] = exit_status
    
    # calculate start and end times in db's timespace
    extras['process_start'] = db_now + (process_start - now)
    extras['process_end'] = db_now + (process_end - now)

    for key in ('process_start', 'process_end'):
        extras[key] = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(extras[key]))
        
    # clean up the script
    os.unlink(script_path)

    if timed_out:
        return 1, "Script killed, timeout of %s seconds exceeded" % timeout, extras

    if exit_status == 0:
        return 0, "Script executed", extras

    return 1, "Script failed", extras
