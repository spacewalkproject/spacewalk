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

import com.redhat.rhn.domain.server.NetworkInterface;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import org.apache.commons.lang.StringUtils;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * NetworkInterfaceSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *      #struct("network device")
 *          #prop_desc("string", "ip", "IP address assigned to this network device")
 *          #prop_desc("string", "interface", "Network interface assigned to device e.g.
 *                              eth0")
 *          #prop_desc("string", "netmask", "Network mask assigned to device")
 *          #prop_desc("string", "hardware_address", "Hardware Address of device.")
 *          #prop_desc("string", "module", "Network driver used for this device.")
 *          #prop_desc("string", "broadcase", " Broadcast address for device.")
 *      #struct_end()
 *
 */
public class NetworkInterfaceSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return NetworkInterface.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        NetworkInterface device = (NetworkInterface)value;
        SerializerHelper devMap = new SerializerHelper(builtInSerializer);

        devMap.add("interface", StringUtils.defaultString(device.getName()));
        devMap.add("ip", StringUtils.defaultString(device.getIpaddr()));
        devMap.add("netmask", StringUtils.defaultString(device.getNetmask()));
        devMap.add("broadcast", StringUtils.defaultString(device.getBroadcast()));
        devMap.add("hardware_address", StringUtils.defaultString(device.getHwaddr()));
        devMap.add("module", StringUtils.defaultString(device.getModule()));
        devMap.writeTo(output);
    }

}
