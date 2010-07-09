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
package com.redhat.rhn.frontend.taglibs.list;

import javax.servlet.jsp.JspException;
/**
 * List tag construct to render expandable columns
 * NonExpandableColumnTag
 * @version $Rev$
 */
public class NonExpandableColumnTag  extends ExpandableColumnTag {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -5967265795977525121L;

    @Override
    protected boolean canRender() {
        return !super.canRender();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected void renderIcon() throws JspException {
        ListTagUtil.write(pageContext, "<img style=\"margin-left: 4px;\"" +
                                        " src=\"/img/channel_child_node.gif\"/>");
    }
}
