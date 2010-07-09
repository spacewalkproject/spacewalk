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

import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * ManagedServerGroupSerializer is a custom serializer for the XMLRPC library.
 * It converts an ServerGroup to an XMLRPC &lt;struct&gt;.
 * @version $Rev$
 * @xmlrpc.doc
 *      #struct("Server Group")
 *          #prop("int", "id")
 *          #prop("string", "name")
 *          #prop("string", "description")
 *          #prop("int", "org_id")
 *          #prop("int", "system_count")
 *      #struct_end()
 *
 */
public class ManagedServerGroupSerializer implements XmlRpcCustomSerializer {

    public static final String MAX_MEMBERS = "max_system_count";
    public static final String CURRENT_MEMBERS = "system_count";

    /** {@inheritDoc} */
    public Class getSupportedClass() {
        return ManagedServerGroup.class;
    }

    /**
     * Converts a ServerGroup to a XMLRPC &lt;struct&gt; containing the top-
     * level fields of the ServerGroup. It serializes the Org as just an ID
     * instead of traversing the entire object graph.
     * @param value ServerGroup object.
     * @param output Buffer to serialize the object to.
     * @param builtInSerializer basic XMLRPC serializer
     * @throws XmlRpcException thrown if a problem occurs with serializing
     * the value.
     * @throws IOException thrown if a problem occurs with serializing
     * the value.
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {

        ServerGroup sg = (ServerGroup) value;

        SerializerHelper serializer = new SerializerHelper(builtInSerializer);
        serializer.add("id", sg.getId());
        serializer.add("name", sg.getName());
        serializer.add("description", sg.getDescription());
        serializer.add(CURRENT_MEMBERS, sg.getCurrentMembers());
        serializer.add("org_id", sg.getOrg().getId());
        serializer.writeTo(output);
    }
}
