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
package com.redhat.rhn.frontend.struts;


/**
 * SelectableAdapter
 * @version $Rev$
 */
public abstract class SelectableAdapter implements Selectable {
    private boolean selected;
    /**
     * {@inheritDoc}
     */
    public abstract String getSelectionKey();

    /**
     * This says whether this object is selectable on a page with a set The
     * default as can be seen is true. Any dto class that cares should override
     * this method. This is used by RhnSet in the select all method. In order to
     * disable checkboxes on a page use <code>&lt;rhn:set value="${current.id}"
     * disabled="${not current.selectable}"  /&gt;</code>
     * @return whether this object is selectable for RhnSet
     */
    public boolean isSelectable() {
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public boolean isSelected() {
        return selected;
    }

    /**
     * {@inheritDoc}
     */
    public void setSelected(boolean selectedIn) {
        selected = selectedIn;
    }

}
