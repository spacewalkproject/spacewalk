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

import java.io.IOException;
import java.io.Writer;
import java.util.Arrays;
import java.util.Collections;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyContent;

import org.apache.commons.lang.StringUtils;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DynamicComparator;
import com.redhat.rhn.common.util.ExportWriter;
import com.redhat.rhn.common.util.ServletExportHandler;
import com.redhat.rhn.frontend.dto.BaseListDto;
import com.redhat.rhn.frontend.dto.UserOverview;
import com.redhat.rhn.frontend.struts.RequestContext;

/**
 * The UnpagedListDisplayTag defines the structure of the ListView.  This tag iterates
 * through the {@link com.redhat.rhn.common.db.datasource.DataResult DataResult}
 * contained in its parent tag,
 * {@link com.redhat.rhn.frontend.taglibs.ListTag ListTag}. In the first
 * iteration the {@link com.redhat.rhn.frontend.taglibs.ColumnTag ColumnTags}
 * render the headers of the ListView, while subsequent iterations render the
 * data contained within the
 * {@link com.redhat.rhn.common.db.datasource.DataResult DataResult}.
 * <p>
 * The UnpagedListTag has the following optional attributes:
 * <code>filterBy</code>
 * <code>renderDisabled</code>
 * <code>domainClass</code>
 * <code>title</code>
 * <code>type</code>
 * <code>transparent</code>
 *
 * The <code>filterBy</code> attribute specifies the column name with which
 * to filter the data.
 * <p>
 * The <code> type </code> attribute sepcifies what class the list is
 * <p>
 * <code>transparent</code> if set to true will make it so that the
 * table has no borders, and all the rows are white.
 * Example usage of the ListDisplayTag with no sets:
 * <pre>
 * ...
 * &lt;rhn:unpagedlistdisplay&gt;
 *   &lt;rhn:column header="l10n.jsp.messagekey"&gt;
 *      display this value
 *   &lt;/rhn:column&gt;
 *   &lt;rhn:column header="l10n.jsp.messagekey1"&gt;
 *      display this value too
 *   &lt;/rhn:column&gt;
 * &lt;/rhn:unpagedlistdisplay&gt;
 * ...
 * </pre>
 * The following shows how to define a ListView with a set column.
 * <pre>
 * ...
 * &lt;rhn:unpagedlistdisplay title="example.title"
 *                     transparent="true"&gt;
 *   &lt;rhn:column header="l10n.jsp.messagekey1"&gt;
 *      display this value
 *   &lt;/rhn:column&gt;
 * &lt;/rhn:unpagedlistdisplay&gt;
 * ...
 * </pre>
 *
 * @version $Rev: 79797 $
 * @see com.redhat.rhn.frontend.taglibs.ColumnTag
 * @see com.redhat.rhn.frontend.taglibs.ListTag
 */
public class UnpagedListDisplayTag extends ListDisplayTagBase {

    /** row count determines whether we're an even or odd row */
    private int rowCnt = 0;
    protected int currRow = 0;

    /** determines whether or not we should show the borders
     *  of the list and if the rows should all be white
     */
    private boolean transparent = false;
    /** determines whether we should show the disabled CSS */
    private String nodeIdString = null;

    /** Public constructor  */
    public UnpagedListDisplayTag() {
    }

    /**
     * @return returns whether or not the table is transparent
     */
    public boolean isTransparent() {
        return transparent;
    }

    /**
     * @param booleanIn sets transparent
     */
    public void setTransparent(boolean booleanIn) {
        transparent = booleanIn;
    }

    private void doSort(String sortedColumn) {
        HttpServletRequest request = (HttpServletRequest)pageContext.getRequest();
        Collections.sort(getPageList(), new DynamicComparator(sortedColumn,
                request.getParameter(RequestContext.SORT_ORDER)));
    }

    private String getSortedColumn() {
        HttpServletRequest request =
            (HttpServletRequest) pageContext.getRequest();
        return request.getParameter(RequestContext.LIST_SORT);
    }

    protected void setupPageList() throws JspTagException {
        super.setupPageList();
        currRow = 0;
    }

    //////////////////////////////////////////////////////////////////////////
    // RENDER methods
    //////////////////////////////////////////////////////////////////////////

    @Override
    protected void renderHeadExtraAddons(Writer out) throws IOException {
        super.renderHeadExtraAddons(out);
        LocalizationService ls = LocalizationService.getInstance();
        if (getType().equals("treeview")) {
            out.append("<div class=\"spacewalk-list-channel-show-hide\">" +
                       "<a class=\"spacewalk-list-channel-show-all\"" +
                       " href=\"javascript:showAllRows();\" style=\"cursor: pointer;\">" +
                       ls.getMessage("channels.overview.showall") +
                       "</a>&nbsp;&nbsp;|&nbsp;&nbsp;" +
                       "<a class=\"spacewalk-list-channel-hide-all\"" +
                       " href=\"javascript:hideAllRows();\" style=\"cursor: pointer;\">" +
                       ls.getMessage("channels.overview.hideall") + "</a></div>");
        }
    }

    private String getTrElement(Object o, int row) {

        if (!(o instanceof BaseListDto &&
           !((BaseListDto)o).changeRowColor())) {
            rowCnt++;
            rowCnt = rowCnt % 2;
        }

        StringBuffer retval;
        if (rowCnt == 1 || isTransparent()) {
            retval = new StringBuffer("<tr class=\"list-row-odd");
        }
        else {
            retval = new StringBuffer("<tr class=\"list-row-even");
        }

        if (renderDisabled() && o instanceof UserOverview &&
                ((UserOverview)o).getStatus().equals("disabled")) {
                return retval.append("-disabled>").toString();
        }

        if ((o instanceof BaseListDto &&
                ((BaseListDto)o).greyOutRow())) {
                retval = retval.append(" greyed-out");
            }

        if ((o instanceof BaseListDto)) {
            nodeIdString = ((BaseListDto)o).getNodeIdString();
            retval = retval.append("\" id=\"" + createIdString(nodeIdString));

            if (getType().equals("treeview") && isChild(nodeIdString)) {
                retval.append("\" style=\"display: none;");
            }
        }
        return retval.append("\">").toString();
    }

    /**
     * Creates the id-string for a given tree-node.  For parents, it's id####.
     * For children, it's child-id####
     *
     * @param nId the node's id-string
     * @return tr/td id-string
     */
    public String createIdString(String nId) {
        StringBuffer retval = new StringBuffer();
        if (isParent(nId)) {
            retval.append("id" + nId.substring(1));

        }
        else if (isChild(nId)) {
            retval.append("child-id" + nId.substring(1) + "-" + currRow);
        }
        return retval.toString();
    }

    /**
     * Returns true if the node-id-string represent a parent-node
     * @param s string of interest
     * @return true if parent-string, false else
     */
    public boolean isParent(String s) {
        return (s != null && s.startsWith("p"));
    }

    /**
     * Returns true if the node-id-string represent a child-node
     * @param s string of interest
     * @return true if child-string, false else
     */
    public boolean isChild(String s) {
        return (s != null && s.startsWith("c"));
    }

    /**
     * If the User requested an Export or not.
     * @return boolean if export or not
     */
    public boolean isExport() {
        RequestContext ctx = new RequestContext((HttpServletRequest)
                pageContext.getRequest());
        return (ctx.isRequestedExport() && getExportColumns() != null);
    }

    //////////////////////////////////////////////////////////////////////////
    // JSP Tag lifecycle methods
    //////////////////////////////////////////////////////////////////////////

    /** {@inheritDoc} */
    public int doStartTag() throws JspException {
        rowCnt = 0;
        JspWriter out = null;

        try {
            out = pageContext.getOut();
            setupPageList();

            // Now that we have setup the proper tag state we
            // need to return if this is an export render.
            if (isExport()) {
                return SKIP_PAGE;
            }

            String sortedColumn = getSortedColumn();
            if (sortedColumn != null) {
                doSort(sortedColumn);
            }

            out.print("<div class=\"spacewalk-list\">");
            out.print("<div class=\"panel panel-default\">");

            renderPanelHeading(out);

            /* If the type is list, we must set the width explicitly. Otherwise,
             * it shouldn't matter
             */
            if (getType().equals("list")) {
                out.print("<table class=\"table table-striped\"");
            }
 else if (getType().equals("treeview")) {
                out.print("<table class=\"table table-striped\" id=\"channel-list\"");
            }
            else {
                out.print("<table class=\"" + getType() + "\"");
            }

            /*if (isTransparent()) {
                out.print(" style=\"border-bottom: 1px solid #ffffff;\" ");
            }*/


            out.println(">");
            out.println("<thead>");
            out.println("<tr>");

            if (getIterator() != null && getIterator().hasNext()) {
                // Push a new BodyContent writer onto the stack so that
                // we can buffer the body data.
                bodyContent = pageContext.pushBody();
                return EVAL_BODY_INCLUDE;
            }
            return SKIP_BODY;
        }
        catch (IOException ioe) {
            throw new JspException("IO error writing to JSP file:", ioe);
        }
    }

    /** {@inheritDoc} */
    public int doEndTag() throws JspException {
        JspWriter out = null;
        try {
            if (getPageList().isEmpty()) {
                return EVAL_PAGE;
            }

            if (isExport()) {
                ExportWriter eh = createExportWriter();
                String[] columns = StringUtils.split(this.getExportColumns(),
                        ',');
                eh.setColumns(Arrays.asList(columns));
                ServletExportHandler seh = new ServletExportHandler(eh);
                pageContext.getOut().clear();
                pageContext.getOut().clearBuffer();
                pageContext.getResponse().reset();
                seh.writeExporterToOutput(
                        (HttpServletResponse) pageContext.getResponse(),
                        getPageList());
                return SKIP_PAGE;
            }

            // Get the JSPWriter that the body used, then pop the
            // bodyContent, so that we can get the real JspWriter with getOut.
            BodyContent body = getBodyContent();
            pageContext.popBody();
            out = pageContext.getOut();

            if (body != null) {
                String bodyString = body.getString();
                out.println(bodyString);
            }
            // Rely on content to have emitted a tbody tag somewhere
            out.println("</tbody>");
            out.println("</table>\n");
            out.println("</div>\n");
            out.println("</div>\n");
            setNumberOfColumns(0);
            setColumnCount(0);
            setCurrRow(0);

        }
        catch (IOException e) {
            throw new JspException("IO error" + e.getMessage());
        }
        finally {
            pageContext.setAttribute("current", null);
        }

        return EVAL_PAGE;
    }

    /** {@inheritDoc} */
    public int doAfterBody() throws JspException {
        JspWriter out = null;
        try {
            out = pageContext.getOut();

            if (pageContext.getAttribute("current") == null) {
                out.println("</tr>");
                out.println("</thead>");
                out.println("<tbody>");
            }
            else {
                out.println("</tr>");
            }

            if (getIterator().hasNext()) {
                setColumnCount(0);
                Object next = getIterator().next();
                out.println(getTrElement(next, currRow++));
                pageContext.setAttribute("current", next);
                return EVAL_BODY_AGAIN;
            }
        }
        catch (IOException e) {
            throw new JspException("Error while writing to JSP: " +
                                   e.getMessage());
        }

        return SKIP_BODY;
    }

    /** {@inheritDoc} */
    @Override
    public void release() {
        // reset the state of the tag
        currRow = 0;
        rowCnt = 0;
        nodeIdString = null;
        // now release our super classes
        super.release();
    }

    /**
     * @return Returns the nodeIdString.
     */
    public String getNodeIdString() {
        return nodeIdString;
    }

    /**
     * Returns row currently being rendered
     * @return current row
     */
    public int getCurrRow() {
        return currRow;
    }

    /**
     * Set current row being rendered
     * @param curr new current row
     */
    public void setCurrRow(int curr) {
        currRow = curr;
    }
}
