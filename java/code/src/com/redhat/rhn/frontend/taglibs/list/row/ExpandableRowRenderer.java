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
package com.redhat.rhn.frontend.taglibs.list.row;

import com.redhat.rhn.frontend.dto.NetworkDto;
import com.redhat.rhn.frontend.taglibs.RhnListTagFunctions;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;

/**
 *
 * ExpandableRowRenderer
 * @version $Rev$
 */
public class ExpandableRowRenderer extends RowRenderer {


    /**
     * ExpandableRowRenderer Construtor
     */
    public ExpandableRowRenderer() {

    }

    /**
     * get the row style for the current object
     * @param current the current object that is being rendered
     * @return the string that is the style to add to the row
     */
    @Override
    public String getRowClass(Object current) {
        if (RhnListTagFunctions.isExpandable(current)) {
            rowNum++;
            return rowClasses[rowNum % rowClasses.length];
        }
        else {
            NetworkDto dto = (NetworkDto) current;
            if (dto.getInactive() > 0) {
                return " inactive";
            }
            return rowClasses[rowNum % rowClasses.length];
        }
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public String getRowId(String listName, Object current) {
        if (RhnListTagFunctions.isExpandable(current)) {
            return super.getRowId(listName, current);
        }
        return "child-" + listName + "-" + ListTagHelper.getObjectId(current);
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public String getRowStyle(Object currentObject) {
        if (!RhnListTagFunctions.isExpandable(currentObject)) {
            return "display: none;";
        }
        return super.getRowStyle(currentObject);
    }    
}
