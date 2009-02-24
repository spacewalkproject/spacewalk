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

package com.redhat.rhn.domain.kickstart.cobbler;

/**
 * CobblerSnippet - Class representation of a Cobbler snippet
 * @version $Rev: 1 $
 */

public class CobblerSnippet {

    private String name;
    private String contents;

    /** 
     * Getter for name 
     * @return String to get
    */
    public String getName() {
        return this.name;
    }

    /** 
     * Setter for name 
     * @param nameIn to set
    */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /** 
     * Getter for contents 
     * @return String to get
    */
    public String getContents() {
        return this.contents;
    }

    /** 
     * Setter for contents 
     * @param contentsIn to set
    */
    public void setContents(String contentsIn) {
        this.contents = contentsIn;
    }

}
