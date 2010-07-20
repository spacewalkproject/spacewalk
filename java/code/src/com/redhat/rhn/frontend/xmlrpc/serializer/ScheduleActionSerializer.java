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

import com.redhat.rhn.frontend.dto.ScheduledAction;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * ScheduleActionSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *
 * #struct("action")
 *   #prop_desc("int", "id", "Action Id.")
 *   #prop_desc("string", "name", "Action name.")
 *   #prop_desc("string", "type", "Action type.")
 *   #prop_desc("string", "scheduler", "The user that scheduled the action.")
 *   #prop_desc($date, "earliest", "The earliest date and time the action
 *   will be performed")
 *   #prop_desc("int", "completedSystems", "Number of systems that completed the action.")
 *   #prop_desc("int", "failedSystems", "Number of systems that failed the action.")
 *   #prop_desc("int", "inProgressSystems", "Number of systems that are in progress.")
 * #struct_end()
 */
public class ScheduleActionSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ScheduledAction.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        ScheduledAction action = (ScheduledAction)value;
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("id", action.getId());
        helper.add("name", action.getActionName());
        helper.add("type", action.getTypeName());
        helper.add("scheduler", action.getSchedulerName());
        helper.add("earliest", action.getEarliestDate());
        helper.add("completedSystems", action.getCompletedSystems());
        helper.add("failedSystems", action.getFailedSystems());
        helper.add("inProgressSystems", action.getInProgressSystems());

        helper.writeTo(output);
    }

}
