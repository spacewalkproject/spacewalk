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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.AbstractLabelNameHelper;

/**
 * Class that represents the rhnServerGroupType table.
 * 
 * @version $Rev$
 */
public class ServerGroupType extends AbstractLabelNameHelper {
    private char permanent;
    private char isBaseChar;
    
    /**
     * @return Returns the isBase.
     */
    public char getIsBaseChar() {
        return isBaseChar;
    }
    /**
     * @param isBaseCharIn The isBase to set.
     */
    public void setIsBaseChar(char isBaseCharIn) {
        this.isBaseChar = isBaseCharIn;
    }
    
    /**
     * @return true if this server group type is a base type, false otherwise
     */
    public boolean isBase() {
        return getIsBaseChar() == 'Y';
    }
    /**
     * @return Returns the permanent.
     */
    public char getPermanent() {
        return permanent;
    }
    /**
     * @param permanentIn The permanent to set.
     */
    public void setPermanent(char permanentIn) {
        this.permanent = permanentIn;
    }
    
    
}
