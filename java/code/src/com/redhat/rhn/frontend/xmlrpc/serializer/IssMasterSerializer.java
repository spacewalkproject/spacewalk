/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.domain.iss.IssMaster;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

/**
 * IssMasterSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 * #struct("IssMaster info")
 *   #prop("int", "id")
 *   #prop("string", "label")
 *   #prop("string", "caCert")
 *   #prop("boolean", "isCurrentMaster")
 * #struct_end()
 */
public class IssMasterSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return IssMaster.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object obj, Writer writer, XmlRpcSerializer serializer)
            throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(serializer);

        IssMaster master = (IssMaster) obj;
        helper.add("id", master.getId());
        helper.add("label", master.getLabel());
        helper.add("caCert", master.getCaCert());
        helper.add("isCurrentMaster", master.isDefaultMaster());
        helper.writeTo(writer);
    }

}
