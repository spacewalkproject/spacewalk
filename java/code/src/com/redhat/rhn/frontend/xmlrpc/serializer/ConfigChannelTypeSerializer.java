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

import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;


/**
 * ConfigChannelTypeSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 * #struct("Configuration Channel Type information")
 *   #prop("int", "id")
 *   #prop("string", "label")
 *   #prop("string", "name")
 *   #prop("int", "priority")
 * #struct_end()
 */
public class ConfigChannelTypeSerializer extends RhnXmlRpcCustomSerializer {

    /**
     *
     * {@inheritDoc}
     */
    protected void doSerialize(Object value, Writer output, XmlRpcSerializer serializer)
       throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(serializer);
        ConfigChannelType type = (ConfigChannelType) value;
        helper.add("id", type.getId());
        helper.add("label", type.getLabel());
        helper.add("name", type.getName());
        helper.add("priority", type.getPriority());
        helper.writeTo(output);
    }
    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ConfigChannelType.class;
    }


}
