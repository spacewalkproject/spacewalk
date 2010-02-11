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


import com.redhat.rhn.frontend.dto.VirtualSystemOverview;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * 
 * VirtualSystemOverviewSerializer
 * @version $Rev$
 * 
 * @xmlrpc.doc
 *  #struct("virtual system")
 *      #prop("int", "id")
 *      #prop("string", "name")
 *      #prop_desc("string", "guest_name", "The virtual guest name as provided 
 *                  by the virtual host")
 *      #prop_desc("dateTime.iso8601", "last_checkin", "Last time server successfully 
 *                   checked in.")
 *      #prop("string", "uuid")
 *   #struct_end()
 * 
 */
public class VirtualSystemOverviewSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {        
        return VirtualSystemOverview.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        
        VirtualSystemOverview system = (VirtualSystemOverview) value;        
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("uuid", system.getUuid());
        helper.add("id", system.getSystemId());
        helper.add("guest_name", system.getName());
        helper.add("name", system.getServerName());
        helper.add("last_checkin", system.getLastCheckinDate());
        helper.writeTo(output);
    }
}
