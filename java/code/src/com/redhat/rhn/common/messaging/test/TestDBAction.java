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

package com.redhat.rhn.common.messaging.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.common.messaging.MessageAction;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.testing.TestUtils;

import java.util.HashMap;

public class TestDBAction implements MessageAction {

    
    private static MessageAction registered;

    public static void registerAction() {
        registered = new TestDBAction();
        MessageQueue.registerAction(registered, TestDBEventMessage.class);
    }
    
    public static void deRegisterAction() {
        MessageQueue.deRegisterAction(registered, TestDBEventMessage.class);
        registered = null;
    }
    
    /**
     * Perform the action on the EventMessage
     */
    public void execute(EventMessage msg) {
        TestDBEventMessage tm = (TestDBEventMessage) msg;
        System.out.println("Execute ..");
        HashMap params = new HashMap();
        params.put("data", tm.getTestString());
        DataResult dr = 
            TestUtils.runTestQuery("select_test_time_series", params);

        if (dr.size() > 0) {
            System.out.println("setMessageReceived ..");
            tm.setMessageReceived(true);
        }
        else {
            System.out.println("not found!");
        }
        
        
    }

}


