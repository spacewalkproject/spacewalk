/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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

package com.redhat.satellite.search;

import org.picocontainer.defaults.DefaultPicoContainer;

/**
 * Runs a PicoContainer instance in a separate thread
 * to prevent the main process from exiting
 * 
 * @version $Rev$
 */
class ContainerRunner implements Runnable {
    
    private DefaultPicoContainer container;
    
    /**
     * Constructor
     * @param containerIn PicoContainer instance to use
     */
    ContainerRunner(DefaultPicoContainer containerIn) {
        container = containerIn;
    }
    
    /**
     * {@inheritDoc}
     */
    public void run() {
        container.start();
        try {
            synchronized (this) {
                this.wait();
            }
            container.stop();
        }
        catch (InterruptedException e) {
            container.stop();
        }
    }
    
    /**
     * Stop the thread
     */
    public void stop() {
        synchronized (this) {
            this.notify();
        }
    }
}
