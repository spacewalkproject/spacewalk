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
package com.redhat.rhn.taskomatic.task;

import org.quartz.Job;

/**
 * JobFactory
 * @version $Rev$
 */
public class JobFactory {

     private JobFactory() {
     }

    /**
     * Creates a Job from a classname
     * @param className fully qualified classname of Job to create
     * @return a Job matching the given classname
     * @throws ClassNotFoundException thrown if class is not found
     * @throws IllegalAccessException thrown if a malformed classname is given
     * @throws InstantiationException thrown if there is a problem creating Job
     */
    public static Job createJob(String className) throws ClassNotFoundException,
            IllegalAccessException, InstantiationException {
        Class c = Thread.currentThread().getContextClassLoader().loadClass(className);
        return (Job) c.newInstance();
    }
}
