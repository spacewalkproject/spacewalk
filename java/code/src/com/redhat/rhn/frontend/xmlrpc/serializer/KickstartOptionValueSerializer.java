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

import com.redhat.rhn.frontend.dto.kickstart.KickstartOptionValue;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * Serializer for {@link KickstartOptionValue} objects.
 *
 * @version $Revision$
 *
 * @xmlrpc.doc
 *      #struct("value")
 *          #prop("string", "name")
 *          #prop("string", "value")
 *          #prop("boolean", "enabled")
 *      #struct_end()

 */
public class KickstartOptionValueSerializer implements XmlRpcCustomSerializer {

    /** {@inheritDoc} */
    public Class getSupportedClass() {
        return KickstartOptionValue.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object o, Writer writer, XmlRpcSerializer xmlRpcSerializer)
        throws XmlRpcException, IOException {
        if (!(o instanceof KickstartOptionValue)) {
            throw new XmlRpcException("Object of incorrect type to be serialized. " +
                "Expected: KickstartOptionValue, Found: " +
                (o != null ? o.getClass() : null));
        }

        KickstartOptionValue value = (KickstartOptionValue) o;

        SerializerHelper serializer = new SerializerHelper(xmlRpcSerializer);
        serializer.add("name", value.getName());
        serializer.add("value", value.getArg());

        // Null check so if enabled is effectively false, we send that and don't squash it
        Boolean enabled = value.getEnabled();
        if (enabled == null) {
            enabled = Boolean.FALSE;
        }
        serializer.add("enabled", enabled);

        serializer.writeTo(writer);
    }
}
