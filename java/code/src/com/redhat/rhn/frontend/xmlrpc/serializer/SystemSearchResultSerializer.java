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

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.frontend.dto.SystemSearchResult;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;
/**
 *
 * SystemSearchResultSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *
 * #struct("system")
 *      #prop("int", "id")
 *      #prop("string", "name")
 *      #prop_desc("dateTime.iso8601",  "last_checkin", "Last time server
 *              successfully checked in")
 *      #prop("string", "hostname")
 *      #prop("string", "ip")
 *      #prop_desc("string",  "hw_description", "hw description if not null")
 *      #prop_desc("string",  "hw_device_id", "hw device id if not null")
 *      #prop_desc("string",  "hw_vendor_id", "hw vendor id if not null")
 *      #prop_desc("string",  "hw_driver", "hw driver if not null")
 * #struct_end()
 *
 */
public class SystemSearchResultSerializer extends RhnXmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return SystemSearchResult.class;
    }

    /**
     * {@inheritDoc}
     */
    protected void doSerialize(Object value, Writer output,
            XmlRpcSerializer serializer) throws XmlRpcException,
            IOException {
        SystemSearchResult result = (SystemSearchResult) value;
        SerializerHelper helper = new SerializerHelper(serializer);
        helper.add("id", result.getId());
        helper.add("name", result.getName());
        helper.add("last_checkin", result.getLastCheckinDate());
        helper.add("hostname", result.getHostname());
        helper.add("ip", result.getIpaddr());
        if (result.getHw() != null) {
            helper.add("hw_description", result.getHw().getDescription());
            helper.add("hw_device_id", result.getHw().getDeviceId());
            helper.add("hw_vendor_id", result.getHw().getVendorId());
            helper.add("hw_driver", result.getHw().getDriver());
        }
        helper.writeTo(output);
    }

}
