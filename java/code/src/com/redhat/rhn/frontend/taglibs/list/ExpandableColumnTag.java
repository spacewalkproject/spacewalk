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

import com.redhat.rhn.frontend.taglibs.RhnListTagFunctions;
import com.redhat.rhn.frontend.taglibs.list.row.ExpandableRowRenderer;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyTagSupport;

/**
 * List tag construct to render expandable columns
 * ExpandableColumnTag
 * @version $Rev$
 */
public class ExpandableColumnTag  extends BodyTagSupport {
    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 9164800881253245840L;
    private boolean renderIcon;

    private static final String IMAGE_SCRIPT = "<a onclick=\"toggleRowVisibility('%s', " +
                                                "rowHash%s);\" " +
                                        "style=\"cursor: pointer;\"><img name=\"%s\"" +
                                         " src=\"/img/list-expand.gif\"/></a>";    
    /**
     * true to render icon
     * @param render true to render icon
     */
    public void setRendericon(String render) {
        renderIcon = ListTagUtil.toBoolean(render);
    }
    protected Object getCurrent() {
        ListTag parent = (ListTag)
        BodyTagSupport.findAncestorWithClass(this, ListTag.class);
        return parent.getCurrentObject();
    }
    
    protected boolean canRender() {
        return RhnListTagFunctions.isExpandable(getCurrent());
    }

    /** {@inheritDoc} 
     * @throws JspException
     */
    public int doStartTag() throws JspException {
        ListCommand command = (ListCommand) ListTagUtil.
        getCurrentCommand(this, pageContext);
        if (command.equals(ListCommand.RENDER)) {
            try {
                if (canRender()) {
                    if (renderIcon) {
                        renderIcon();    
                    }
                    return EVAL_BODY_INCLUDE;
                }
                return SKIP_BODY;
            }
            catch (Exception e) {
                throw new JspException("Error writing to JSP file:", e);
            }
        }
        return super.doStartTag();
    }

    protected void renderIcon() throws JspException {
        String listName = getListName();
        Object current = getCurrent();
        String rowId = new ExpandableRowRenderer().getRowId(listName, current);
        String imageId = rowId + "-image";
        ListTagUtil.write(pageContext, String.format(IMAGE_SCRIPT,
                                            rowId, listName, imageId));
    }
    
    /** {@inheritDoc} 
     */
    @Override
    public void release() {
        renderIcon = false;
        super.release();
    }
    
    protected String getListName() {
        ListTag parent = (ListTag)
            BodyTagSupport.findAncestorWithClass(this, ListTag.class);
        return parent.getUniqueName();
    }    
}
