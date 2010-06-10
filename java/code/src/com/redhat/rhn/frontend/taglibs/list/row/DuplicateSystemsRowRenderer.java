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
package com.redhat.rhn.frontend.taglibs.list.row;

import com.redhat.rhn.frontend.dto.NetworkDto;
import com.redhat.rhn.frontend.taglibs.RhnListTagFunctions;


/**
 * DuplicateSystemsRowRenderer
 * @version $Rev$
 */
public class DuplicateSystemsRowRenderer extends ExpandableRowRenderer {
    /**
     * get the row style for the current object
     * @param current the current object that is being rendered
     * @return the string that is the style to add to the row
     */
    @Override
    public String getRowClass(Object current) {
        if (!RhnListTagFunctions.isExpandable(current)) {
            NetworkDto dto = (NetworkDto) current;
            if (dto.getInactive() > 0) {
                return " inactive";
            }
        }
        return super.getRowClass(current);
    }

}
