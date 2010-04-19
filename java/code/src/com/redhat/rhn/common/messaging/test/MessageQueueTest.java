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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.apache.log4j.Logger;
import org.hibernate.Transaction;

import java.util.HashMap;
import java.util.Map;

public class MessageQueueTest extends RhnBaseTestCase {

    private static Logger logger = Logger.getLogger(MessageQueueTest.class);
    
    protected void setUp() {
        logger.debug("setUp - start");
        Config.get().setString("web.mailer_class", 
                MockMail.class.getName());
        TestAction.registerAction();
        TestDBAction.registerAction();
        MessageQueue.startMessaging();
        logger.debug("setUp - end");
    }

    protected void tearDown() {
        logger.debug("tearDown - start");
        TestAction.deRegisterAction();
        TestDBAction.deRegisterAction();
        MessageQueue.stopMessaging();
        logger.debug("tearDown - end");
        
    }

    public void testPublish() throws Exception {
        logger.debug("testPublish - start");
        TestEventMessage me = new TestEventMessage();
        MessageQueue.publish(me);
        // Just need to relinquish control to let the notify happen.
        Thread.sleep(1000);        
        assertTrue(me.getMessageReceived());
        logger.debug("testPublish - end");
    }
   
   
    public void testMultiThreadedPublish() throws Exception {
        logger.debug("testMultiThreadedPublish - start");
        // Crank up 10 Threads to add test messages to the queue
        for (int i = 0; i < 10; i++) {
            Thread pub = new MessagePublisher();
            pub.start();
        }
        // Wait for all the messages to be processed
        // If this unit test deadlocks we have a bug
        while (MessageQueue.getMessageCount() > 0) {
            Thread.sleep(1000);
        }
        // make sure we get here
        assertTrue(true);
        logger.debug("testMultiThreadedPublish - end");
        
    }

    /**
     * Test to make sure that Events process after the publisher's DB transaction
     * is complete.  Need to make sure this is the case because caller's may be
     * writing things to the DB that need to complete before the MessageQueue 
     * thread can process them.
     * 
     * @throws Exception
     */
    public void testDatabaseTransactionHandling() throws Exception {
        logger.debug("testDatabaseTransactionHandling - start");
        // === START TXN ===
        Transaction t = HibernateFactory.getSession().getTransaction();
        String testString = TestUtils.randomString();
        TestDBEventMessage me = new TestDBEventMessage(t, testString);
        
        MessageQueue.publish(me);
        assertFalse(me.getMessageReceived());

        WriteMode m = ModeFactory.getWriteMode("test_queries",
            "insert_time_series");
        Map params = new HashMap();
        params.put("entry_time", new Long(1));
        params.put("data", testString);
        m.executeUpdate(params);        
        commitAndCloseSession();
        // === END TXN ===
        boolean finished = false;
        for (int i = 0; i < 1000; i++) {
            if (me.getMessageReceived()) {
                finished = true;
                break;
            }
            Thread.sleep(100);
        }
        assertTrue(finished);
        logger.debug("testDatabaseTransactionHandling - end");
    }
    
    
    /**
     * tests to see if we can allow multiple registers, unregisters
     * and publishers.
     * @throws Exception
     */
    public void testMultiThreadedPublishRegister() throws Exception {
        logger.debug("testMultiThreadedPublishRegister - start");
        // Let's start 10 publishers, 10 registers,
        // and 10 unregisters.

        int size = 10;
        Thread[] pubs = new Thread[size];
        Thread[] regs = new Thread[size];
        Thread[] deregs = new Thread[size];
        
        for (int i = 0; i < size; i++) {
            pubs[i] = new MessagePublisher();
            regs[i] = new MessageRegister();
            deregs[i] = new MessageUnregister();
            pubs[i].start();
            regs[i].start();
            deregs[i].start();
        }    

        while (MessageQueue.getMessageCount() > 0) {
            Thread.sleep(1000);
        }
        
        for (int i = 0; i < size; i++) {
            while (pubs[i].isAlive()) {
                Thread.sleep(10);
            }
            while (regs[i].isAlive()) {
                Thread.sleep(10);
            }
            while (deregs[i].isAlive()) {
                Thread.sleep(10);
            }
        }
        
        assertTrue(true);
        logger.debug("testMultiThreadedPublishRegister - end");
    }

    public void testStop() throws Exception {
        logger.debug("testStop - start");
        MessageQueue.stopMessaging();
        assertFalse(MessageQueue.isMessaging());
        Thread.sleep(5000);
        // Just need to relinquish control to let the notify happen.
        TestEventMessage me = new TestEventMessage();
        // TODO: figure out why this breaks on galaga but not on my 
        // workstation
        verifyMessageEvent(me, false);
        logger.debug("testStop - end");
    }

    /**
     * This test seems to fail randomly every few days.  going to skip it
     *  for now
     * @throws Exception
     */
    public void SKIPtestDeRegister() throws Exception {
        logger.debug("testDeRegister - start");
        TestAction.deRegisterAction();
        Thread.sleep(1000);
        TestEventMessage me = new TestEventMessage();
        verifyMessageEvent(me, false);
        logger.debug("testDeRegister - end");
    }

    public void testDeRegisterMultiple() throws Exception {
        logger.debug("testDeRegisterMultiple - start");
        TestAction.deRegisterAction();
        TestAction.deRegisterAction();
        logger.debug("testDeRegisterMultiple - end");
    }

    public void testQueueSetup() { 
        logger.debug("testQueueSetup - start");
        assertTrue(MessageQueue.isMessaging());
        assertTrue(MessageQueue.getRegisteredEventNames().length > 0);
        logger.debug("testQueueSetup - end");
    }

    public void testThreadKiller() throws InterruptedException {
        logger.debug("testThreadKiller - start");
        TestAction.deRegisterAction();
        TestExceptionAction.registerAction();
        TestEventMessage me = new TestEventMessage();
        MessageQueue.publish(me);
        // Just need to relinquish control to let the notify happen.
        Thread.sleep(2000);     
        assertTrue(me.getMessageReceived());
        TestExceptionAction.deRegisterAction();
        logger.debug("testThreadKiller - end");
    }
    
    private void verifyMessageEvent(TestEventMessage me, boolean matchingValue) 
            throws InterruptedException {
        MessageQueue.publish(me);        
        boolean wasReceived = true;
        int count = 0;
        while (true) {
            wasReceived = me.getMessageReceived();
            if (!wasReceived) {
                break;
            }
            count++;
            if (count > 25) {
                break;
            }
            Thread.sleep(500);
        }
        if (matchingValue) {
            assertTrue(wasReceived);
        }
        else {
            assertFalse(wasReceived);
        }
        
    }
    
    /**
    * Util thread to simulate multiple Threads publishing
    * events.
    */
    public class MessagePublisher extends Thread {
        
        /**
          * Run the thread.
          * This is the method that loops waiting for a message so that it can
          * hand the message to the regstered action types.
          */
        public void run() {
            // simulate doing some work
            try {
                Thread.sleep(1);    
            } 
            catch (InterruptedException iee) {
                logger.debug("Caught iee" + iee);
            }
            for (int i = 0; i < 10; i++) {
                MessageQueue.publish(new TestEventMessage());
            }
        }
    }
    
    /**
     * Util thread to simulate multiple Threads publishing
     * events.
     */
    public class MessageRegister extends Thread {
        
        /**
          * Run the thread.
          * This is the method that loops waiting for a message so that it can
          * hand the message to the regstered action types.
          */
        public void run() {
            // simulate doing some work
            try {
                Thread.sleep(1);
                for (int i = 0; i < 10; i++) {
                    TestAction.registerAction();
                }
            } 
            catch (InterruptedException iee) {
                logger.debug("Caught iee" + iee);
            }
        }
        
    }

    /**
     * Util thread to simulate multiple Threads publishing
     * events.
     */
    public class MessageUnregister extends Thread {
        /**
          * Run the thread.
          * This is the method that loops waiting for a message so that it can
          * hand the message to the regstered action types.
          */
        public void run() {
            // simulate doing some work
            try {
                Thread.sleep(1);
                for (int i = 0; i < 10; i++) {
                    TestAction.deRegisterAction();
                }
            } 
            catch (InterruptedException iee) {
                logger.debug("Caught iee" + iee);
            }
        }
    }
}


