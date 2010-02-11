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
package com.redhat.rhn.frontend.taglibs.list;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyTagSupport;

/**
 * Provides a container for the new-style lists
 * 
 * @version $Rev $
 */
public class ListSetTag extends BodyTagSupport {
    
    private static final long serialVersionUID = -1693186305171539903L;
    
    private String uniqueName;
    
    private String legend;
    
    
    /**
     * Name for this list set
     * @param setName name
     */
    public void setName(String setName) {
        uniqueName = TagHelper.generateUniqueName(setName);
    }
    
    /**
     * Gets the unique name of the list set
     * @return unique name
     */
    public String getUniqueName() {
        return uniqueName;
    }
    
    /**
     * @return Returns the legend.
     */
    public String getLegend() {
        return legend;
    }
    
    /**
     * @param l The legend to set.
     */
    public void setLegend(String l) {
        this.legend = l;
    }
    
    /**
     * setLegends
     * Builds legends variable and sticks it back into the request.
     * legends can either be a single string or a comma separated list.
     *   Legend is rendered by includes/legends.jsp
     * @param l The legend to add to the list
     */
    private void setLegends(String l) {
        String legends = (String) pageContext.getRequest().getAttribute("legends");
        if (legends == null || legends.trim().equals("")) {
                //legends is empty, add the first legend
                legends = l;
        }
        else {
            /*
             * legends must look like either "foo" or "foo,bar". in 
             * either case, we just want to append a comma and a new
             * value.
             */
            legends = legends.trim() + "," + l;
        }
        pageContext.getRequest().setAttribute("legends", legends);
    }
    
    
    
    /**
     * {@inheritDoc}
     */
    public int doStartTag() throws JspException {
        //if legend was set, process legends
        if (legend != null) {
            setLegends(legend);
        }
        verifyEnvironment();
        startForm();
        return BodyTagSupport.EVAL_BODY_INCLUDE;
    }
    
    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        endForm();
        return BodyTagSupport.EVAL_PAGE;
    }
    
    /**
     * {@inheritDoc}
     */
    public void release() {
        uniqueName = null;
        super.release();
    }
    
    private void startForm() throws JspException {
        String targetUrl = (String) pageContext.getRequest().getAttribute("parentUrl");
        ListTagUtil.write(pageContext, "<form method=\"POST\" id=\"listset_");
        ListTagUtil.write(pageContext, uniqueName);
        ListTagUtil.write(pageContext, "\" name=\"name_");
        ListTagUtil.write(pageContext, uniqueName);        
        ListTagUtil.write(pageContext, "\" action=\"");
        ListTagUtil.write(pageContext, targetUrl);
        ListTagUtil.write(pageContext, "\">\n");
    }
    
    private void endForm() throws JspException {
        ListTagUtil.write(pageContext, "</form>\n");
    }
    
    private void verifyEnvironment() throws JspException {
        if (BodyTagSupport.findAncestorWithClass(this, this.getClass()) != null) {
            throw new JspException("ListSet tags may not be nested.");
        }
        if (pageContext.getRequest().getAttribute("parentUrl") == null) {
            throw new JspException("Request attribute 'parentUrl' must be set.");
        }
    }
}
