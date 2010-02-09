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
package com.redhat.rhn.domain.action.rhnpackage;

import com.redhat.rhn.domain.action.Action;

import java.util.HashSet;
import java.util.Set;

/**
 * PackageAction
 * @version $Rev$
 */
public class PackageAction extends Action {

    private Set details = new HashSet();
    
    /**
     * Add a PackageActionDetails to the set of details
     * for a PackageAction.
     * @param d PackageActionDetails to add
     */
    public void addDetail(PackageActionDetails d) {
        d.setParentAction(this);
        details.add(d);
    }
    
    /**
     * @return Returns the details.
     */
    public Set getDetails() {
        return details;
    }
    
    /**
     * @param d The details to set.
     */
    public void setDetails(Set d) {
        this.details = d;
    }
    
}
