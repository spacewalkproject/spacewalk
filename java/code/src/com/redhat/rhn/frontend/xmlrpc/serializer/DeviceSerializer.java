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

import com.redhat.rhn.domain.server.Device;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * 
 * DeviceSerializer
 * @version $Rev$
 * 
 * @xmlrpc.doc
 *  #struct("device")
 *      #prop_desc("string", "device", "optional")
 *      #prop_desc("string", "device_class",  "Includes CDROM, FIREWIRE, HD, USB, VIDEO,
 *                  OTHER, etc.")
 *      #prop("string", "driver")
 *      #prop("string", "description")
 *      #prop("string", "bus")
 *      #prop("string", "pcitype")
 *   #struct_end()
 */
public class DeviceSerializer implements XmlRpcCustomSerializer {

    /**
     * 
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
    throws XmlRpcException, IOException {
        
        Device dev = (Device) value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("device", dev.getDevice());
        helper.add("device_class", dev.getDeviceClass());
        helper.add("driver", dev.getDriver());
        helper.add("description", dev.getDescription());
        helper.add("pcitype", dev.getPcitype());
        helper.add("bus", dev.getBus());
        helper.add("prop1", dev.getProp1());
        helper.add("prop2", dev.getProp2());
        helper.add("prop3", dev.getProp3());
        helper.add("prop4", dev.getProp4());
        helper.writeTo(output);        
    }
    
    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return Device.class;
    }


}
