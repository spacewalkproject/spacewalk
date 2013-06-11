/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.domain.iss.IssMasterOrg;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

/**
 * IssMasterOrgSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 * #struct("IssMasterOrg info")
 *   #prop("int", "masterOrgId")
 *   #prop("string", "masterOrgName")
 *   #prop("int", "localOrgId")
 * #struct_end()
 */
public class IssMasterOrgSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return IssMasterOrg.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object obj, Writer writer, XmlRpcSerializer serializer)
            throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(serializer);

        IssMasterOrg anOrg = (IssMasterOrg) obj;
        helper.add("masterOrgId", anOrg.getMasterOrgId());
        helper.add("masterOrgName", anOrg.getMasterOrgName());
        if (anOrg.getLocalOrg() != null) {
            helper.add("localOrgId", anOrg.getLocalOrg().getId());

        }
        helper.writeTo(writer);
    }

}
