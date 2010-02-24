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

import com.redhat.rhn.frontend.dto.kickstart.KickstartableTreeDetail;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * KickstartTreeDetailSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *
 * #struct("kickstartable tree")
 *   #prop("int", "id")
 *   #prop("string", "label")
 *   #prop("string", "abs_path")
 *   #prop("int", "channel_id")
 *   $KickstartInstallTypeSerializer
 * #struct_end()
 */
public class KickstartTreeDetailSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return KickstartableTreeDetail.class;
    }

    /**
     * {@inheritDoc}
     * @throws IOException
     */
    public void serialize(Object value, Writer output,
                          XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {

        KickstartableTreeDetail treeDetail = (KickstartableTreeDetail) value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("id", treeDetail.getId());
        helper.add("label", treeDetail.getLabel());
        helper.add("abs_path", treeDetail.getAbsolutePath());
        helper.add("channel_id", treeDetail.getChannel().getId());
        helper.add("install_type", treeDetail.getInstallType());
        helper.writeTo(output);
    }

}
