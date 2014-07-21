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

import org.apache.commons.lang.StringUtils;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.domain.server.Dmi;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

/**
 *
 * DmiSerializer
 * @version $Rev$
 * @xmlrpc.doc
 *      #struct("DMI")
 *          #prop("string", "vendor")
 *          #prop("string", "system")
 *          #prop("string", "product")
 *          #prop("string", "asset")
 *          #prop("string", "board")
 *          #prop_desc("string", "bios_release", "(optional)")
 *          #prop_desc("string", "bios_vendor", "(optional)")
 *          #prop_desc("string", "bios_version", "(optional)")
 *      #struct_end()
 */
public class DmiSerializer extends RhnXmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return Dmi.class;
    }
    /**
     * {@inheritDoc}
     */
    protected void doSerialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
        SerializerHelper bean = new SerializerHelper(serializer);
        Dmi dmi = (Dmi) value;

        bean.add("vendor", StringUtils.defaultString(dmi.getVendor()));
        bean.add("system", StringUtils.defaultString(dmi.getSystem()));
        bean.add("product", StringUtils.defaultString(dmi.getProduct()));
        bean.add("asset", StringUtils.defaultString(dmi.getAsset()));
        bean.add("board", StringUtils.defaultString(dmi.getBoard()));
        if (dmi.getBios() != null) {
            bean.add("bios_release", StringUtils.defaultString(dmi.getBios().getRelease()));
            bean.add("bios_vendor", StringUtils.defaultString(dmi.getBios().getVendor()));
            bean.add("bios_version", StringUtils.defaultString(dmi.getBios().getVersion()));
        }
        bean.writeTo(output);
    }

}
