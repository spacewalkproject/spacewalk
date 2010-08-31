/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.channel.repo;

import com.redhat.rhn.FaultException;


/**
 * InvalidRepoLabelException
 * @version $Rev$
 */
public class InvalidRepoLabelException extends FaultException {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -8506595413724954752L;

    /**
     * Constructor
     * @param repoLabel Repository label already in use
     */
    public InvalidRepoLabelException(String repoLabel) {
        super(2, "Repo label already in use", "edit.channel.repo.repolabelinuse",
                new Object[] {repoLabel});
    }

}
