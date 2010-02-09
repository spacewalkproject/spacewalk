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

import com.redhat.rhn.frontend.dto.OrgEntitlementDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * OrgEntitlementDtoSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 * #struct("entitlement usage") 
 *   #prop("string", "label")
 *   #prop("string", "name")
 *   #prop("int", "free")
 *   #prop("int", "used")
 *   #prop("int", "allocated")
 *   #prop("int", "unallocated")
 * #struct_end()
 */
public class OrgEntitlementDtoSerializer implements XmlRpcCustomSerializer {
    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        
        return OrgEntitlementDto.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output,
            XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        OrgEntitlementDto dto = (OrgEntitlementDto) value;
        helper.add("label", dto.getEntitlement().getLabel());
        helper.add("name", dto.getEntitlement().getHumanReadableLabel());
        helper.add("allocated", dto.getMaxEntitlements());
        helper.add("unallocated", dto.getUpperRange() - dto.getMaxEntitlements());
        helper.add("used", dto.getCurrentEntitlements());
        helper.add("free", dto.getMaxEntitlements() - dto.getCurrentEntitlements());
        
        helper.writeTo(output);
    }

}
