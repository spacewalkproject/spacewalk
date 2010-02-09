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

import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.common.messaging.MessageAction;
import com.redhat.rhn.common.messaging.MessageQueue;

/**
 * TestExceptionAction
 * @version $Rev$
 */
public class TestExceptionAction implements MessageAction  {
    private static MessageAction registered;

    public static void registerAction() {
        registered = new TestExceptionAction();
        MessageQueue.registerAction(registered, TestEventMessage.class);
    }
    
    public static void deRegisterAction() {
        MessageQueue.deRegisterAction(registered, TestEventMessage.class);
        registered = null;
    }
    
    /**
     * Perform the action on the EventMessage
     */
    public void execute(EventMessage msg) {
        TestEventMessage tm = (TestEventMessage) msg;
        tm.setMessageReceived(true);
        throw new RuntimeException("TEST: Try and kill the thread");
    }
}
