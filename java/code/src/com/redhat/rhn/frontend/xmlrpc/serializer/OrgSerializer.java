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

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * OrgSerializer is a custom serializer for the XMLRPC library.
 * It converts an Org to an XMLRPC &lt;struct&gt;.
 * @version $Rev$
 */
public class OrgSerializer implements XmlRpcCustomSerializer {
    
    /** {@inheritDoc} */
    public Class getSupportedClass() {
        return Org.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
        
        SerializerHelper helper = new SerializerHelper(serializer);
        Org org = (Org) value;
        
        helper.add("id", org.getId());
        helper.add("name", org.getName());
        helper.writeTo(output);       
        
    }
}
