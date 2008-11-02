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

from iss_runcommand import run_command

class IsoError(Exception):
    pass


def create_isos(mountpoint, outdir, prefix, lower_limit=None, upper_limit=None, copy_iso_dir=None, iso_type=None):
    opts = []
    command = "PYTHONPATH=/usr/share/rhn python /usr/share/rhn/satellite_tools/geniso.py %s"
    
    opts.append("--mountpoint=%s" % mountpoint)
    opts.append("--file-prefix=%s" % prefix)
    opts.append("--output=%s" % outdir)
    opts.append("--type=%s" % iso_type)
    
    
    if not lower_limit is None:
        opts.append("-v%s-%s" % (lower_limit, upper_limit))

    if not copy_iso_dir is None:
        opts.append("--copy-iso-dir=%s" % copy_iso_dir)

    #if not upper_limit is None:
    #    opts.append("-r%s" % upper_limit)

    optstr = " ".join(opts)

    status, outval, errval = run_command(command % optstr)
    if status != 0:
        raise IsoError(outval, errval)
    
         

    
        
