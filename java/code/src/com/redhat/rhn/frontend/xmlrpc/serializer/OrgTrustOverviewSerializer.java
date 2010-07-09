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

import com.redhat.rhn.frontend.dto.OrgTrustOverview;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * OrgSerializer is a custom serializer for the XMLRPC library.
 * It converts an OrgTrustOverview to an XMLRPC &lt;struct&gt;.
 * @xmlrpc.doc
 *   #array()
 *     #struct("trusted organizations")
 *       #prop("int", "orgId")
 *       #prop("string", "orgName")
 *       #prop("bool", "trustEnabled")
 *     #struct_end()
 *   #array_end()
 * @version $Rev$
 */
public class OrgTrustOverviewSerializer implements XmlRpcCustomSerializer {

    /** {@inheritDoc} */
    public Class<OrgTrustOverview> getSupportedClass() {
        return OrgTrustOverview.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(serializer);
        OrgTrustOverview tr = (OrgTrustOverview) value;
        helper.add("orgId", tr.getId());
        helper.add("orgName", tr.getName());
        helper.add("trustEnabled", tr.getTrusted());
        helper.writeTo(output);

    }
}
