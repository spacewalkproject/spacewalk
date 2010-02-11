/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.frontend.xmlrpc.serializer;

import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.dto.OrgSoftwareEntitlementDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * OrgSoftwareEntitlementDto
 * @version $Rev$
 *
 * @xmlrpc.doc
 * #struct("entitlement usage") 
 *   #prop("int", "org_id")
 *   #prop("string", "org_name")
 *   #prop("int", "allocated")
 *   #prop("int", "unallocated")
 *   #prop("int", "used")
 *   #prop("int", "free")
 * #struct_end()
 */
public class OrgSoftwareEntitlementDtoSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return OrgSoftwareEntitlementDto.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output,
            XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        OrgSoftwareEntitlementDto dto = (OrgSoftwareEntitlementDto) value;
        helper.add("org_id", dto.getOrg().getId());
        helper.add("org_name", dto.getOrg().getName());
        Long total = Long.valueOf(-1);
        if (dto.getMaxMembers() != null) {
            total = dto.getMaxMembers();
        }
        
        helper.add("allocated", total);
        if (OrgFactory.getSatelliteOrg().getId().equals(dto.getOrg().getId())) {
            helper.add("unallocated", total - dto.getCurrentMembers());    
        }
        else {
            helper.add("unallocated", dto.getMaxPossibleAllocation() - total);
        }
        
        helper.add("used", dto.getCurrentMembers());
        helper.add("free", total - dto.getCurrentMembers());
        
        helper.writeTo(output);

    }

}
