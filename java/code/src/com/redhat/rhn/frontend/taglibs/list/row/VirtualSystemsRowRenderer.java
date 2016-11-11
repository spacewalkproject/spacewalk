/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import com.redhat.rhn.frontend.dto.VirtualSystemOverview;

/**
 *
 * VirtualSystemsRowRenderer
 * @version $Rev$
 */
public class VirtualSystemsRowRenderer extends RowRenderer {
    private static final String TREE_ROW_PARENT     = "tree-row-parent";
    private static final String TREE_ROW_CHILD_EVEN = "tree-row-child-even";
    private static final String TREE_ROW_CHILD_ODD  = "tree-row-child-odd";

    private boolean evenRow = false;

    /**
     * get the row class for the current object
     * @param currentObject the current object that is being rendered
     * @return the string that is the style to add to the row
     */
    @Override
    public String getRowClass(Object currentObject) {
        if (currentObject instanceof VirtualSystemOverview) {
            VirtualSystemOverview vso = (VirtualSystemOverview)currentObject;
            if (vso.getIsVirtualHost()) {
                evenRow = false;
                return TREE_ROW_PARENT;
            }
        }
        String retval = evenRow ? TREE_ROW_CHILD_EVEN : TREE_ROW_CHILD_ODD;
        evenRow = !evenRow;
        return retval;
    }
}
