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

import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * ActivationKeySerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *   #struct("activation key")
 *     #prop("string", "key")
 *     #prop("string", "description")
 *     #prop("int", "usage_limit")
 *     #prop("string", "base_channel_label")
 *     #prop_array("child_channel_labels", "string", "childChannelLabel")
 *     #prop_array("entitlements", "string", "entitlementLabel")
 *     #prop_array("server_group_ids", "string", "serverGroupId")
 *     #prop_array("package_names", "string", "packageName - (deprecated by packages)")
 *     #prop_array_begin("packages")
 *       #struct("package")
 *         #prop_desc("string", "name", "packageName")
 *         #prop_desc("string", "arch", "archLabel - optional")
 *       #struct_end()
 *     #prop_array_end()
 *     #prop("boolean", "universal_default")
 *   #struct_end()
 */
public class ActivationKeySerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ActivationKey.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        ActivationKey key = (ActivationKey)value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        TokenSerializer.populateTokenInfo(key.getToken(), helper);
        helper.add("key", key.getKey());
        helper.writeTo(output);
    }

}
