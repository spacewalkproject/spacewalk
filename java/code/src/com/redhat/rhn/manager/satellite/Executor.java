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
package com.redhat.rhn.manager.satellite;

/**
 * Executor - simple interface to describe a way to execute a generic
 * command with the passed in arguments.  No contract is specified about
 * what is contained in the arguments.  
 * @version $Rev$
 */
public interface Executor {
    
    /**
     * Execute any command with the passed in arguments.  
     * @param args array of command you wish to execute.
     * @return exit code of command executed.
     */
    int execute(String[] args);
}
