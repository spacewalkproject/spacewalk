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

package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.domain.kickstart.cobbler.CobblerSnippet;

/**
 * BaseCobblerSnippetCommand - base for edit/create CryptKeys
 * @version $Rev$
 */
public abstract class BaseCobblerSnippetCommand {

    protected CobblerSnippet snippet;
    protected String name;
    protected String contents;

    /**
     * Constructor
     */
    public BaseCobblerSnippetCommand() {
    }

    /**
     * get the name
     * @return name
     */
    public String getName() {
        return name;
    }

    /**
     * Set the name
     * @param nameIn to set
     */
    public void setName(String nameIn) {
        this.snippet.setName(nameIn);
    }

    /**
     * get the contents
     * @return contents
     */
    public String getContents() {
        return contents;
    }

    /**
     * Set the contents
     * @param contentsIn to set
     */
    public void setContents(String contentsIn) {
        this.snippet.setContents(contentsIn);
    }

    /**
     * Get the CobblerSnippet used by this cmd
     * @return CobblerSnippet instance
     */
    public CobblerSnippet getCobblerSnippet() {
        return snippet;
    }

}
