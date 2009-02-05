/**
 * Copyright (c) 2009 Red Hat, Inc.
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

package com.redhat.rhn.common.messaging;

import EDU.oswego.cs.dl.util.concurrent.Channel;
import EDU.oswego.cs.dl.util.concurrent.LinkedQueue;

import com.redhat.rhn.frontend.events.NewUserAction;
import com.redhat.rhn.frontend.events.NewUserEvent;
import com.redhat.rhn.frontend.events.RestartSatelliteAction;
import com.redhat.rhn.frontend.events.RestartSatelliteEvent;
import com.redhat.rhn.frontend.events.TraceBackAction;
import com.redhat.rhn.frontend.events.TraceBackEvent;
import com.redhat.rhn.frontend.events.UpdateErrataCacheAction;
import com.redhat.rhn.frontend.events.UpdateErrataCacheEvent;

import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * A class that passes messages from the sender to an action class
 *
 * @version $Rev$
 */
public class MessageQueue {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger.getLogger(MessageQueue.class);

    private static Map actions = new HashMap();
    private static Channel messages = new LinkedQueue();
    private static Thread dispatcherThread = null;
    private static MessageDispatcher dispatcher = null;
    private static int messageCount;

    /**
    * Util class so we don't have a usable constructor
    */
    private MessageQueue() {
    }
    
    /**
     * Publish a new message
     * Each message is wrapped in a ActionExecutor instance
     * @param msg EventMessage to publish to queue.
     */
    public static void publish(EventMessage msg) {
        if (logger.isDebugEnabled()) {
            logger.debug("publish(EventMessage) - start: " + msg.getClass().getName());
        }
        if (!isMessaging()) {
            startMessaging();
        }
        if (msg != null) {
            synchronized (actions) {
                List handlers = (List) actions.get(msg.getClass());
                if (handlers != null && handlers.size() > 0) {
                    logger.debug("creating ActionExecutor");
                    ActionExecutor executor = new ActionExecutor(handlers, msg);
                    try {
                        messages.put(executor);
                        messageCount++;
                    }
                    catch (InterruptedException e) {
                        logger.error(e.getMessage(), e);
                    }
                } 
                else {
                    logger.debug("handlers is null, not processing!");
                }
            }
        }

        if (logger.isDebugEnabled()) {
            logger.debug("publish(EventMessage) - end");
        }
    }
    
    static Runnable popEventMessage() throws InterruptedException {
        Runnable retval = (Runnable) messages.poll(500);
        if (retval != null) {
            synchronized (actions) {
                messageCount--;
            }
        }
        return retval;
    }

    /**
     * Start the messaging system
     */
    public static synchronized void startMessaging() {
        if (logger.isDebugEnabled()) {
            logger.debug("startMessaging() - start");
        }
        if (isMessaging()) {
            return;
        }
        dispatcher = new MessageDispatcher();
        dispatcherThread = new Thread(dispatcher);
        dispatcherThread.setName("RHN Message Dispatcher");
        dispatcherThread.setDaemon(false);
        dispatcherThread.start();
        if (logger.isDebugEnabled()) {
            logger.debug("startMessaging() - end"); 
        }        
    }

    /**
     * Stop the messaging system
     */
    public static synchronized void stopMessaging() {
        if (logger.isDebugEnabled()) {
            logger.debug("stopMessaging() - start");
        }
        dispatcher.stop();
        if (logger.isDebugEnabled()) {
            logger.debug("stopMessaging() - end");
        }
    }

    /**
    * Get the number of messages in the queue
    * @return int number of messages in queue.
    */
    public static int getMessageCount() {
        return messageCount;
    }    

    /**
     * Register an action
     * @param act MessageAction
     * @param eventType type of event.
     */
    public static void registerAction(MessageAction act, Class eventType) {
        if (logger.isDebugEnabled()) {
            logger.debug("registerAction(MessageAction, Class) - : " + act +
                    " class: " + eventType.getName());
        }
        synchronized (actions) {
            List handlers = (List) actions.get(eventType);
            if (handlers == null) {
                handlers = new ArrayList();
                actions.put(eventType, handlers);
            }
            handlers.add(act);
        }
    }

    /**
     * De-register an action
     * @param act MessageAction.
     * @param eventType Type of event.
     */
    public static void deRegisterAction(MessageAction act, Class eventType) {
        if (logger.isDebugEnabled()) {
            logger.debug("deRegisterAction(MessageAction, Class) - start"); 
        }
        synchronized (actions) {
            List handlers = (List) actions.get(eventType);
            handlers.remove(act);
        }
        if (logger.isDebugEnabled()) {
            logger.debug("deRegisterAction(MessageAction, Class) - end");
        }
    }
    
    /** 
     * Get list of String Classnames of the registered Actions.  For Managment
     * of the MessageQueue and testability.
     * @return String[] array of registered events.
     */
    public static String[] getRegisteredEventNames() {
        if (logger.isDebugEnabled()) {
            logger.debug("getRegisteredEventNames() - start"); 
        }
        String[] retval = null;
        synchronized (actions) {
            if (actions.keySet().size() > 0) {
                retval = new String[actions.keySet().size()];
                int index = 0;
                for (Iterator iter = actions.keySet().iterator(); iter.hasNext();) {
                    Class klazz = (Class) iter.next();
                    retval[index] = klazz.getName();
                    index++;
                }
            }
        }

        if (logger.isDebugEnabled()) {
            logger.debug("getRegisteredEventNames() - end - null");
        }
        return retval;
    }
    
    /** 
    * Check to see if the MessageQueue is running and available to 
    * publish MessageEvents to
    * @return boolean true if MessageQueue is running.
    */
    public static boolean isMessaging() {
        return (dispatcher != null && !dispatcher.isStopped());
    }
    
    
    /**
     * Configures defaut messaging actions needed by RHN
     * This method should be called directly after <code>startMessaging</code>.
     *
     */
    public static void configureDefaultActions() {
        // Register the Actions for the Events
        // If we develop a large set of MessageEvents we may want to
        // refactor this block out into a class or method that
        // reads in some configuration from an XML file somewhere
        TraceBackAction tbe = new TraceBackAction();
        MessageQueue.registerAction(tbe, TraceBackEvent.class);
        NewUserAction nua = new NewUserAction();
        MessageQueue.registerAction(nua, NewUserEvent.class);
        // this is to update the errata cache without blocking the login
        // for 40 seconds.
        UpdateErrataCacheAction ueca = new UpdateErrataCacheAction();
        MessageQueue.registerAction(ueca, UpdateErrataCacheEvent.class);
        
        // Used for asynchronusly restarting the satellite
        RestartSatelliteAction ra = new RestartSatelliteAction();
        MessageQueue.registerAction(ra, RestartSatelliteEvent.class);
    }
}

