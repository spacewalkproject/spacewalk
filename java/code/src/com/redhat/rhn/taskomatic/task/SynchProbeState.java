/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import org.quartz.JobExecutionContext;

/**
 * SynchProbeState
 * @version $Rev$
 */
public class SynchProbeState extends RhnJavaJob {

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext arg0In) {
        // Do nothing.
        // Probes are a monitoring thing and no longer exist, but there's no easy
        // way to delete the task from Quartz's database. Instead let's just keep
        // this empty job around for people who upgraded, and not add the task to
        // new installs.
    }
}
