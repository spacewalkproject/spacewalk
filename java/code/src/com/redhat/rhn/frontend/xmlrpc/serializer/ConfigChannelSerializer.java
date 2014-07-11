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

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;


/**
 * ConfigurationChannelSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 * #struct("Configuration Channel information")
 *   #prop("int", "id")
 *   #prop("int", "orgId")
 *   #prop("string", "label")
 *   #prop("string", "name")
 *   #prop("string", "description")
 *   #prop("struct", "configChannelType")
 *   $ConfigChannelTypeSerializer
 * #struct_end()
 */
public class ConfigChannelSerializer extends RhnXmlRpcCustomSerializer {
    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ConfigChannel.class;
    }

    /**
     *
     * {@inheritDoc}
     * @throws IOException
     */
    protected void doSerialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
        ConfigChannel chan = (ConfigChannel) value;
        SerializerHelper helper = new SerializerHelper(serializer);
        helper.add("id", chan.getId());
        helper.add("label", chan.getLabel());
        helper.add("name", chan.getName());
        helper.add("description", chan.getDescription());
        helper.add("orgId", chan.getOrgId());
        helper.add("configChannelType", chan.getConfigChannelType());
        helper.writeTo(output);
    }
}
