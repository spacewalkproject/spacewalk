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
package com.redhat.rhn.frontend.taglibs.list.decorators;

import com.redhat.rhn.frontend.taglibs.list.ListSetTag;
import com.redhat.rhn.frontend.taglibs.list.ListTag;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;

/**
 * General-use base class for writing decorators
 *
 * @version $Rev $
 */
public abstract class BaseListDecorator implements ListDecorator {

    protected PageContext pageContext;
    protected ListSetTag parent;
    protected String listName;
    protected int columnCount;
    protected ListTag currentList;

    /**
     * {@inheritDoc}
     */
    public void setEnvironment(PageContext ctx, ListSetTag parentIn, String name) {
        pageContext = ctx;
        parent = parentIn;
        listName = name;
    }

    /**
     * {@inheritDoc}
     */
    public void addColumn() {
        columnCount++;
    }

    /**
     * {@inheritDoc}
     */
    public void setCurrentList(ListTag current) {
        currentList = current;
    }

    /**
     *
     * @return the associated list tag.
     */
    protected ListTag getCurrentList() {
        return currentList;
    }

    /**
     * {@inheritDoc}
     */
    public void afterList() throws JspException {

    }

    /**
     * {@inheritDoc}
     */
    public void afterBottomPagination() throws JspException {
    }

    /**
     * {@inheritDoc}
     */
    public void afterTopPagination() throws JspException {

    }

    /**
     * {@inheritDoc}
     */
    public void beforeList() throws JspException {

    }

    /**
     *
     * {@inheritDoc}
     */
    public void beforeTopPagination() throws JspException {

    }

}
