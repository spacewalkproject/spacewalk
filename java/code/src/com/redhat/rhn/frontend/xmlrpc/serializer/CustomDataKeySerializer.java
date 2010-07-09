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

import com.redhat.rhn.frontend.dto.CustomDataKeyOverview;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * CustomDataKeySerializer: Converts a CustomDataKeyOverview object for
 * representation as an XMLRPC struct.
 *
 * @version $Rev$
 *
 * @xmlrpc.doc
 *      #struct("custom info")
 *          #prop("int", "id")
 *          #prop("string", "label")
 *          #prop("string", "description")
 *          #prop("int", "system_count")
 *          #prop("dateTime.iso8601", "last_modified")
 *      #struct_end()
 */
public class CustomDataKeySerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return CustomDataKeyOverview.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {

        CustomDataKeyOverview key = (CustomDataKeyOverview)value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("id", key.getId());
        helper.add("label", key.getLabel());
        helper.add("description", key.getDescription());
        helper.add("system_count", key.getServerCount().intValue());
        helper.add("last_modified", key.getLastModified());
        helper.writeTo(output);
    }
}
