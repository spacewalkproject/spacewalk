/**
 * Copyright (c) 2010 Red Hat, Inc.
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

import com.redhat.rhn.domain.channel.DistChannelMap;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 *
 * DistChannelMapSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *      #struct("distChannelMap")
 *          #prop_desc("string", "os", "Operationg System")
 *          #prop_desc("string", "release", "OS Relase")
 *          #prop_desc("string", "arch_label", "Channel architecture")
 *          #prop_desc("string", "channel_label", "Channel label")
 *     #struct_end()
 */
public class DistChannelMapSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return DistChannelMap.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {

        DistChannelMap dstChannelMap = (DistChannelMap) value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("os", dstChannelMap.getOs());
        helper.add("release", dstChannelMap.getRelease());
        helper.add("arch_name", dstChannelMap.getChannelArch().getName());
        helper.add("channel_label", dstChannelMap.getChannel().getLabel());

        helper.writeTo(output);
    }
}
