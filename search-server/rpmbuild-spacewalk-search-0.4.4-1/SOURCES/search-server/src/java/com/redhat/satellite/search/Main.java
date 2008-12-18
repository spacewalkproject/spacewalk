/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.satellite.search.config.Configuration;
import com.redhat.satellite.search.db.DatabaseManager;
import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.rpc.RpcServer;
import com.redhat.satellite.search.scheduler.ScheduleManager;

import org.apache.log4j.Logger;
import org.picocontainer.defaults.DefaultPicoContainer;
import org.tanukisoftware.wrapper.WrapperListener;
import org.tanukisoftware.wrapper.WrapperManager;

/**
 * Entry point for the Tanuki daemon wrapper
 * 
 * @version $Rev$
 */
public class Main implements WrapperListener {
    
    private static Logger log = Logger.getLogger(Main.class);
    private static final Class[] COMPONENTS = {DatabaseManager.class,
                                               IndexManager.class,
                                               RpcServer.class,
                                               ScheduleManager.class};
    
    private DefaultPicoContainer container;
    private ContainerRunner runner;

    /**
     * {@inheritDoc}
     */
    public void controlEvent(int arg) {
    }

    /**
     * {@inheritDoc}
     */
    public Integer start(String[] argv) {
        Configuration config = new Configuration();
        container = new DefaultPicoContainer();
        container.registerComponentInstance(config);
        for (int x = 0; x < COMPONENTS.length; x++) {
            container.registerComponentImplementation(COMPONENTS[x]);
        }
        runner = new ContainerRunner(container);
        Thread t = new Thread(runner);
        t.setDaemon(false);
        t.start();

        return null;
    }

    /**
     * {@inheritDoc}
     */
    public int stop(int arg) { 
        log.info("Stopping Main");
        runner.stop();
        return 0;
    }
    
    /**
     * Main entry point
     * @param argv  command-line args
     */
    public static void main(String[] argv) {
        Main m = new Main();
        WrapperManager.start(m, argv);
        if (log.isDebugEnabled()) {
            log.debug("Returned from WrapperManager.start");
        }
    }
}
