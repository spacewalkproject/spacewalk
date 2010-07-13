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

import com.redhat.rhn.frontend.dto.MultiOrgEntitlementsDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * MultiOrgEntitlementsDtoSerializer
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
 *   #prop("int", "free_flex")
 *   #prop("int", "used_flex")
 *   #prop("int", "allocated_flex")
 *   #prop("int", "unallocated_flex") *
 * #struct_end()
 */
public class MultiOrgEntitlementsDtoSerializer implements
        XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        // TODO Auto-generated method stub
        return MultiOrgEntitlementsDto.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output,
            XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        MultiOrgEntitlementsDto dto = (MultiOrgEntitlementsDto) value;
        helper.add("name", dto.getName());
        helper.add("label", dto.getLabel());
        helper.add("allocated", dto.getAllocated());
        helper.add("unallocated", dto.getAvailable());
        helper.add("used", dto.getUsed());
        helper.add("free", dto.getAllocated() - dto.getUsed());
        helper.add("allocated_flex", dto.getAllocatedFlex());
        helper.add("unallocated_flex", dto.getAvailableFlex());
        helper.add("used_flex", dto.getUsedFlex());
        helper.add("free_flex", dto.getAllocatedFlex() - dto.getUsedFlex());

        helper.writeTo(output);
    }
}
