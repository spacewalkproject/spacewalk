/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.frontend.dto.kickstart.KickstartDto;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;


/**
 * ActivationKeySerializer
 * @version $Rev$
 *
 * @xmlrpc.doc 
 *   #struct("kickstart")
 *          #prop("string", "label")
 *          #prop("string", "name")
 *          #prop("string", "boot_image")
 *          #prop("boolean", "advanced_mode")
 *          #prop("boolean", "org_default")
 *   #struct_end()
 */
public class KickstartDtoSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return KickstartDto.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        KickstartDto ks = (KickstartDto)value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("label", ks.getLabel());
        helper.add("name", ks.getLabel());
        helper.add("boot_image", ks.getBootImage());
        helper.add("advanced_mode", ks.isAdvancedMode());
        if (ks.getIsOrgDefault().equals("Y")) {
            helper.add("org_default", true);
        }
        else {
            helper.add("org_default", false);
        }
        
        
        helper.writeTo(output);
    }

}
