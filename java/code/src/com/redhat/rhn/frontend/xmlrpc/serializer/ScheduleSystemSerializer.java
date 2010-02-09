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

import com.redhat.rhn.frontend.dto.ActionedSystem;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * ScheduleSystemSerializer
 * @version $Rev$
 * @xmlrpc.doc
 * 
 * #struct("system")
 *   #prop("int", "server_id")
 *   #prop_desc("string", "server_name", "Server name.")
 *   #prop_desc("string", "base_channel", "Base channel used by the server.")
 *   #prop_desc($date, "timestamp", "The time the action was completed")
 *   #prop_desc("string", "message", "Optional message containing details 
 *   on the execution of the action.  For example, if the action failed, 
 *   this will contain the failure text.")
 * #struct_end()
 */
public class ScheduleSystemSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ActionedSystem.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        ActionedSystem action = (ActionedSystem)value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("server_id", action.getId());
        helper.add("server_name", action.getServerName());
        helper.add("base_channel", action.getChannelLabels());
        helper.add("timestamp", action.getDate());
        helper.add("message", action.getMessage());

        helper.writeTo(output);
    }

}
