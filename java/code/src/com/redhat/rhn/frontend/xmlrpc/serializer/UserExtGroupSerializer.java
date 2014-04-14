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

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.domain.org.usergroup.UserExtGroup;
import com.redhat.rhn.domain.role.Role;
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
public class UserExtGroupSerializer extends RhnXmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return UserExtGroup.class;
    }

    /**
     * {@inheritDoc}
     */
    protected void doSerialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(serializer);
        UserExtGroup g = (UserExtGroup) value;

        helper.add("name", g.getLabel());

        List<String> roleList = new ArrayList<String>();
        for (Role role : g.getRoles()) {
            roleList.add(role.getLabel());
        }
        helper.add("roles", roleList);

        helper.writeTo(output);
    }
}
