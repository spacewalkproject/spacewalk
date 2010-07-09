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
package com.redhat.rhn.taskomatic.core.test;

import com.redhat.rhn.taskomatic.core.BaseDaemon;

import org.apache.commons.cli.CommandLine;

public class TestDaemon extends BaseDaemon {

    protected int onShutdown(boolean breakFromUser) {
        return BaseDaemon.SUCCESS;
    }

    protected int onStartup(CommandLine commandLine) {
        new Thread(new DaemonLogic()).start();
        return BaseDaemon.SUCCESS;
    }

    public static void main(String[] argv) {
        TestDaemon td = new TestDaemon();
        td.registerImplementation(argv);
    }

    class DaemonLogic implements Runnable {
        public void run() {
            System.out.println("Hello, world!");
            try {
                Thread.sleep(10000);
            }
            catch (InterruptedException e) {
                return;
            }
        }
    }
}
