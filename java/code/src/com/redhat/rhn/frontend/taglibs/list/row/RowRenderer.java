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

import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagUtil;

/**
 * 
 * RowRenderer
 * @version $Rev$
 */
public class RowRenderer {

    protected String[] rowClasses;
    protected int rowNum;

    /**
     * RowRenderer Construtor
     */
    public RowRenderer() {
        rowClasses = new String[2];
        rowClasses[0] = "list-row-even";
        rowClasses[1] = "list-row-odd";
        rowNum = -1;
        
    }
    
    /**
     * get the row class for the current object
     * @param currentObject the current object that is being rendered
     * @return the string that is the style to add to the row
     */
    public String getRowClass(Object currentObject) {
        rowNum++;
        return rowClasses[rowNum % rowClasses.length];
    }
    
    /**
     * Set the list of row styles
     * @param stylesIn the styles
     */
    public void setRowClasses(String stylesIn) {
            rowClasses = ListTagUtil.parseStyles(stylesIn);
    }
    /**
     * Returns the row id given the list name and the current object
     * @param listName the listname
     * @param currentObject the current object
     * @return the row id
     */
    public String getRowId(String listName, Object currentObject) {
        return ListTagHelper.makeRowId(listName, currentObject);
    }

    /**
     * get the row style for the current object
     * @param currentObject the current object that is being rendered
     * @return the string that is the style to add to the row
     */
    public String getRowStyle(Object currentObject) {
        return "";
    }
}
