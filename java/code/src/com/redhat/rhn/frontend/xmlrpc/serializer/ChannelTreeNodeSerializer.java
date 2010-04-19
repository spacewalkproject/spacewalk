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

import com.redhat.rhn.frontend.dto.ChannelTreeNode;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * ChannelTreeNodeSerializer: Converts a ChannelTreeNode object for 
 * representation as an XMLRPC struct.
 * @version $Rev$
 * 
 * @xmlrpc.doc 
 *   #struct("channel info")
 *     #prop("int", "id")
 *     #prop("string", "label")
 *     #prop("string", "name")
 *     #prop("string", "provider_name")
 *     #prop("int", "packages")
 *     #prop("int", "systems")
 *     #prop("string", "arch_name")
 *   #struct_end()
 */
public class ChannelTreeNodeSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ChannelTreeNode.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        
        ChannelTreeNode ctn = (ChannelTreeNode)value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("id", ctn.getId());
        helper.add("label", ctn.getChannelLabel());
        helper.add("name", ctn.getName());
        
        if (ctn.getOrgId() != null) {
            helper.add("provider_name", ctn.getOrgName());
        }
        else {
            helper.add("provider_name", "Red Hat, Inc.");
        }
        
        helper.add("packages", ctn.getPackageCount());

        if (ctn.getSystemCount() == null) {
            // it is possible for the current query to result in the count
            // being null; however, in this scenario, we still want to serialize the
            // result as 0.
            helper.add("systems", new Integer(0));
        }
        else {
            helper.add("systems", ctn.getSystemCount());
        }

        helper.add("arch_name", ctn.getArchName());

        helper.writeTo(output);
    }
}
