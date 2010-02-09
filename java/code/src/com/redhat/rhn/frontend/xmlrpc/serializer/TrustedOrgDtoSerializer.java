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

import com.redhat.rhn.frontend.dto.TrustedOrgDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * TrustedOrgDtoSerializer is a custom serializer for the XMLRPC library.
 * It converts an TrustedOrgDto to an XMLRPC &lt;struct&gt;.
 * @xmlrpc.doc
 *     #struct("trusted organizations")
 *       #prop("int", "org_id")
 *       #prop("string", "org_name")
 *       #prop("int", "shared_channels")
 *     #struct_end()
 * @version $Rev$
 */
public class TrustedOrgDtoSerializer implements XmlRpcCustomSerializer {
    
    /** {@inheritDoc} */
    public Class<TrustedOrgDto> getSupportedClass() {
        return TrustedOrgDto.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(serializer);
        TrustedOrgDto tr = (TrustedOrgDto) value;
        helper.add("org_id", tr.getId());
        helper.add("org_name", tr.getName());
        helper.add("shared_channels", tr.getSharedChannels());
        helper.writeTo(output);       
    }
}
