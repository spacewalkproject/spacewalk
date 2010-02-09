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

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.server.ServerAction;
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
 *      #struct("action")
 *          #prop_desc("int", "failed_count", "Number of times action failed.")
 *          #prop_desc("string", "modified", "Date modified. (Deprecated by modified_date)")
 *          #prop_desc($date, "modified_date", "Date modified.")
 *          #prop_desc("string", "created", "Date created. (Deprecated by created_date)")
 *          #prop_desc($date, "created_date", "Date created.")
 *          #prop("string", "action_type")
 *          #prop_desc("int", "successful_count", 
 *                      "Number of times action was successful.")
 *          #prop_desc("string", "earliest_action", "Earliest date this action 
 *                      will occur.")
 *          #prop_desc("int", "archived", "If this action is archived. (1 or 0)")
 *          #prop("string", "scheduler_user")
 *          #prop_desc("string", "prerequisite", "Pre-requisite action. (optional)")
 *          #prop_desc("string", "name", "Name of this action.")
 *          #prop_desc("int", "id", "Id of this action.")
 *          #prop_desc("string", "version", "Version of action.")
 *          #prop_desc("string", "completion_time", "The date/time the event was completed.
 *                                  Format ->YYYY-MM-dd hh:mm:ss.ms 
 *                                  Eg ->2007-06-04 13:58:13.0. (optional)
 *                                  (Deprecated by completed_date)")
 *          #prop_desc($date, "completed_date", "The date/time the event was completed.
 *                                  (optional)")
 *          #prop_desc("string", "pickup_time", "The date/time the action was picked up.
 *                                   Format ->YYYY-MM-dd hh:mm:ss.ms
 *                                   Eg ->2007-06-04 13:58:13.0. (optional)
 *                                   (Deprecated by pickup_date)")
 *          #prop_desc($date, "pickup_date", "The date/time the action was picked up.
 *                                   (optional)")
 *          #prop_desc("string", "result_msg", "The result string after the action
 *                                       executes at the client machine. (optional)")
 *      #struct_end()     
 */
public class ServerActionSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ServerAction.class;
    }

    /** {@inheritDoc} */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        ServerAction sAct = (ServerAction) value;
        Action act = sAct.getParentAction();
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        
        helper.add("failed_count", act.getFailedCount());
        helper.add("modified", act.getModified().toString());
        helper.add("created", act.getCreated().toString());
        helper.add("action_type", act.getActionType().getName());
        helper.add("successful_count", act.getSuccessfulCount());
        helper.add("earliest_action", act.getEarliestAction().toString());
        helper.add("archived", act.getArchived());
        helper.add("scheduler_user", act.getSchedulerUser().getLogin());
        helper.add("prerequisite", act.getPrerequisite());
        helper.add("name", act.getName());
        helper.add("id", act.getId());
        helper.add("version", act.getVersion().toString());
        
        if (sAct.getCompletionTime() != null) {
            helper.add("completion_time", sAct.getCompletionTime().toString());
        }
        if (sAct.getPickupTime() != null) {
            helper.add("pickup_time", sAct.getPickupTime().toString());
        }

        helper.add("modified_date", act.getModified());
        helper.add("created_date", act.getCreated());
        helper.add("completed_date", sAct.getCompletionTime());
        helper.add("pickup_date", sAct.getPickupTime());

        helper.add("result_msg", sAct.getResultMsg());

        helper.writeTo(output);
    }

}
