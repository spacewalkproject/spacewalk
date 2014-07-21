/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

/**
 *
 * UserSerializer a serializer for the User class
 * @version $Rev$
 *
 * @xmlrpc.doc
 *      #struct("user")
 *              #prop("int", "id")
 *              #prop("string", "login")
 *              #prop_desc("string", "login_uc", "upper case version of the login")
 *              #prop_desc("boolean", "enabled", "true if user is enabled,
 *                         false if the user is disabled")
 *      #struct_end()
 */
public class UserSerializer extends RhnXmlRpcCustomSerializer {
    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return User.class;
    }

    /**
     * {@inheritDoc}
     */
    protected void doSerialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
       SerializerHelper helper = new SerializerHelper(serializer);

       User user = (User) value;
       helper.add("id", user.getId());
       helper.add("login", user.getLogin());
       helper.add("login_uc", user.getLoginUc());

       if (user.isDisabled()) {
           helper.add("enabled", Boolean.FALSE);
       }
       else {
           helper.add("enabled", Boolean.TRUE);
       }

       helper.writeTo(output);
    }
}



