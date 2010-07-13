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

import com.redhat.rhn.frontend.dto.ChannelFamilySystem;
import com.redhat.rhn.frontend.dto.ChannelFamilySystemGroup;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.List;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * ChannelArchSerializer serializes ChannelArch object to XMLRPC.
 * @version $Rev$
 * @xmlrpc.doc
 *      #struct("channel family system group")
 *          #prop("string", "name")
 *          #prop("int", "id")
 *          #array_single("int", "systems")
 *      #struct_end()
 */
public class ChannelFamilySystemGroupSerializer implements XmlRpcCustomSerializer {

    /** {@inheritDoc} */
    public Class getSupportedClass() {
        return ChannelFamilySystemGroup.class;
    }

    /** {@inheritDoc}
     * @throws IOException */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
    throws XmlRpcException, IOException {
        ChannelFamilySystemGroup group = (ChannelFamilySystemGroup) value;


        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("name", group.getName());
        helper.add("id", group.getId());

        List<Long> ids = new ArrayList<Long>(group.expand().size());
        for (ChannelFamilySystem cfs : group.expand()) {
            ids.add(cfs.getId());
        }
        helper.add("systems", ids);
        helper.writeTo(output);
    }

}
