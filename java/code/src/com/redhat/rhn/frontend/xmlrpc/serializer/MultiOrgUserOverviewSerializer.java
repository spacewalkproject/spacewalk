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

import com.redhat.rhn.frontend.dto.MultiOrgUserOverview;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 *
 * MultiOrgAllUserOverviewSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 * #struct("user")
 *   #prop("string", "login")
 *   #prop("string", "login_uc")
 *   #prop("string", "name")
 *   #prop("string", "email")
 *   #prop("boolean", "is_org_admin")
 * #struct_end()
 */
public class MultiOrgUserOverviewSerializer implements
        XmlRpcCustomSerializer {

    /**
     *
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        // TODO Auto-generated method stub
        return MultiOrgUserOverview.class;
    }
    /**
     *
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output,
            XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        SerializerHelper se = new SerializerHelper(builtInSerializer);
        MultiOrgUserOverview dto = (MultiOrgUserOverview) value;

        se.add("login", dto.getLogin());
        se.add("login_uc", dto.getLoginUc());
        se.add("name", dto.getUserDisplayName());
        se.add("email", dto.getAddress());
        se.add("is_org_admin", dto.getOrgAdmin() == 1);
        se.writeTo(output);

    }

}
