#!/usr/bin/python
#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
#
# this is a dummy module that makes pychecker happy and provides
# the _apache module, whcih is normally provided by mod_python
# when a script runs under it

SERVER_RETURN = 0

def log_error(*_args):
    pass

def make_table(*_args):
    pass

def parse_qs(*_args):
    pass
    
def parse_qsl(*_args):
    pass

status = None
table = None
config_tree = None
server_root = None
mpm_query = None

# Variables for apache 2+
exists_config_define = None
stat = None

AP_CONN_UNKNOWN = None
AP_CONN_CLOSE = None
AP_CONN_KEEPALIVE = None

APR_NOFILE = None
APR_REG = None
APR_DIR = None
APR_CHR = None
APR_BLK = None
APR_PIPE = None
APR_LNK = None
APR_SOCK = None
APR_UNKFILE = None
