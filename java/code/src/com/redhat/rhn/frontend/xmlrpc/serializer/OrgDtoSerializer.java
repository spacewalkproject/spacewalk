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

import com.redhat.rhn.frontend.dto.OrgDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * OrgDtoSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 * #struct("organization info")
 *   #prop("int", "id")
 *   #prop("string", "name")
 *   #prop_desc("int", "active_users", "Number of active users in the organization.")
 *   #prop_desc("int", "systems", "Number of systems in the organization.")
 *   #prop_desc("int", "trusts", "Number of trusted organizations.")
 *   #prop_desc("int", "system_groups",
 *                              "Number of system groups in the organization.")
 *   #prop_desc("int", "activation_keys",
 *                              "Number of activation keys in the organization. (optional)")
 *   #prop_desc("int", "kickstart_profiles",
 *                          "Number of kickstart profiles in the organization. (optional)")
 *   #prop_desc("int", "configuration_channels",
 *                      "Number of configuration channels in the organization. (optional)")
 * #struct_end()
 */
public class OrgDtoSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        // TODO Auto-generated method stub
        return OrgDto.class;
    }

    /**
     *
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output,
            XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        OrgDto dto = (OrgDto) value;
        helper.add("id", dto.getId());
        helper.add("name", dto.getName());
        add(helper, "active_users", dto.getUsers());
        add(helper, "systems", dto.getSystems());
        add(helper, "trusts", dto.getTrusts());
        add(helper, "activation_keys", dto.getActivationKeys());
        add(helper, "system_groups", dto.getActivationKeys());
        add(helper, "kickstart_profiles", dto.getKickstartProfiles());
        add(helper, "configuration_channels", dto.getConfigChannels());
        helper.writeTo(output);
    }

    private void add(SerializerHelper helper, String name, Object value) {
        if (value != null) {
            helper.add(name, value);
        }
    }
}
