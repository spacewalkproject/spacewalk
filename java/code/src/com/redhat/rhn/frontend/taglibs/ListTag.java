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

package com.redhat.rhn.frontend.taglibs;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyTagSupport;

/**
 * The ListTag is the outer most tag of a ListView. The ListTag has two
 * attributes <code>pageList</code> and <code>noDataText</code>.  The 
 * <code>pageList</code> is a
 * {@link com.redhat.rhn.common.db.datasource.DataResult DataResult}
 * which contains the data to display. If the <code>pageList</code> is null
 * or empty, the ListTag will skip the body and display the message defined
 * by the <code>noDataText</code> attribute.
 * <p>
 * Both the <code>pageList</code> and <code>noDataText</code> attributes are
 * <strong>REQUIRED</strong>.
 * <p>
 * The ListTag should include at least one
 * {@link com.redhat.rhn.frontend.taglibs.ListDisplayTag ListDisplayTag}
 * <p>
 * Example usage of the ListTag:
 * <pre>
 * &lt;rhn:list pageList="${requestScope.pageList}"
 *           noDataText="l10n.jsp.messagekey"&gt;
 *   &lt;rhn:listdisplay&gt;
 *   ...
 *   &lt;/rhn:listdisplay&gt;
 * &lt;/rhn:list&gt;
 * </pre>
 * @version $Rev$
 * @see com.redhat.rhn.frontend.taglibs.ColumnTag
 * @see com.redhat.rhn.frontend.taglibs.ListDisplayTag
 * @see com.redhat.rhn.frontend.taglibs.SetTag
 */
public class ListTag extends BodyTagSupport {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 5028598487681062713L;
    private DataResult pageList;
    private String noDataText;
    private String legend;
    private boolean formatMessage = true;

    
    /** Public constructor  */
    public ListTag() {
    }

    
    /** {@inheritDoc} */
    public int doStartTag() throws JspException {
        JspWriter out = null;
        
        //if legend was set, process legends
        if (legend != null) {
            setLegends(legend);
        }
        
        try {
            out = pageContext.getOut();
            
            if (pageList == null || pageList.isEmpty()) {
                renderEmptyString(out);
                return SKIP_BODY;
            }
        
            return EVAL_BODY_INCLUDE;
        }
        catch (IOException ioe) {
            throw new JspException("IO error writing to JSP file:", ioe);
        }
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

    /** Set the pagelist for this tag
     * @param list the list to display
     */
    public void setPageList(DataResult list) {
        pageList = list;
    }

    /** Get the pageList for this tag
     * @return The page list to be displayed.
     */
    public DataResult getPageList() {
        return pageList;
    }
    
    /**
     * Set the string to print if there is no data in the 
     * list
     * @param noDataTextIn The string to print if there is
     *        no data.
     */
    public void setNoDataText(String noDataTextIn) {
        this.noDataText = noDataTextIn;
    }
    
    private void renderEmptyString(JspWriter out) throws IOException {
        
        if (formatMessage) {
            out.println("<div class=\"list-empty-message\">" + 
                    LocalizationService.getInstance().getMessage(noDataText) +
                    "</div>");
        }
        else {
            out.println(noDataText);
        }

    }
    
    /**
     * setLegends
     * Builds legends variable and sticks it back into the request.
     * legends can either be a single string or a comma separated list.
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
    public void release() {
        pageList = null;
        noDataText = null;
        legend = null;
        formatMessage = true;
        super.release();
    }


    /**
     * @param formatMessageIn The formatMessage to set.
     */
    public void setFormatMessage(boolean formatMessageIn) {
        this.formatMessage = formatMessageIn;
    }
}
