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

import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * KickstartTreeSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *
 * #struct("kickstartable tree")
 *   #prop("int", "id")
 *   #prop("string", "label")
 *   #prop("string", "base_path")
 *   #prop("int", "channel_id")
 * #struct_end()
 */
public class KickstartTreeSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return KickstartableTree.class;
    }

    /**
     * {@inheritDoc}
     * @throws IOException
     */
    public void serialize(Object value, Writer output,
                          XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {

        KickstartableTree tree = (KickstartableTree)value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("id", tree.getId());
        helper.add("label", tree.getLabel());
        helper.add("base_path", tree.getBasePath());
        helper.add("channel_id", tree.getChannel().getId());
        helper.writeTo(output);
    }

}
