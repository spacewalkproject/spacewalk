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
 * InvalidRepoUrlException
 * @version $Rev$
 */
public class InvalidRepoUrlException extends FaultException {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 7189002795067633123L;

    /**
     * Constructor
     * @param repoUrl Repository url already in use
     */
    public InvalidRepoUrlException(String repoUrl) {
        super(1, "Repo url already defined", "edit.channel.repo.repourlinuse",
                new Object[] {repoUrl});
    }
}
