/**
 * Copyright (c) 2014 Red Hat, Inc.
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

import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.domain.org.usergroup.OrgUserExtGroup;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

/**
 *
 * UserExtGroupSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *  #struct("externalGroup")
 *      #prop("string", "name")
 *      #prop_array("roles", "string", "role")
 *  #struct_end()
 *
 */
public class OrgUserExtGroupSerializer extends RhnXmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return OrgUserExtGroup.class;
    }

    /**
     * {@inheritDoc}
     */
    protected void doSerialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(serializer);
        OrgUserExtGroup g = (OrgUserExtGroup) value;

        helper.add("name", g.getLabel());

        List<String> groupList = new ArrayList<String>();
        Set<ServerGroup> groups = g.getServerGroups();
        for (ServerGroup group : groups) {
            groupList.add(group.getName());
        }
        helper.add("groups", groupList);

        helper.writeTo(output);
    }
}
