#
# Copyright (c) 2008--2013 Red Hat, Inc.
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
from virtualization.domain_config import DomainConfig

fieldname = sys.argv[1]
filename = sys.argv[2]
dc = DomainConfig('/usr/share/rhn/virt/auto', filename)

fields = {
            'name'          :   DomainConfig.NAME,
            'uuid'          :   DomainConfig.UUID,
            'memory'        :   DomainConfig.MEMORY,
            'vcpu'          :   DomainConfig.VCPU,
            'root_device'   :   DomainConfig.ROOT_DEVICE,
            'cmdline'       :   DomainConfig.COMMAND_LINE,
            'os_kernel'     :   DomainConfig.KERNEL_PATH,
            'os_initrd'     :   DomainConfig.RAMDISK_PATH,
            'disk_source'   :   DomainConfig.DISK_IMAGE_PATH
         }

if fieldname not in fields:
    sys.stdout.write("Unknown configuration element %s \n" % fieldname)
    sys.exit(1)

result = dc.getConfigItem(fields[fieldname])
if fieldname == "uuid":
    result = result.replace("-", "")

print(result)

