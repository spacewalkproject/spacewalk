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
import com.redhat.rhn.common.util.CSVWriter;
import com.redhat.rhn.common.util.DynamicComparator;
import com.redhat.rhn.common.util.ExportWriter;
import com.redhat.rhn.common.util.ServletExportHandler;
import com.redhat.rhn.frontend.dto.BaseListDto;
import com.redhat.rhn.frontend.dto.UserOverview;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.commons.lang.StringUtils;

import java.io.IOException;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyContent;
import javax.servlet.jsp.tagext.BodyTagSupport;

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
public class UnpagedListDisplayTag extends BodyTagSupport {
    
    /** iterates through the page list */
    private Iterator iterator;
    /** list of data to show on page */
    private DataResult pageList;
    /** row count determines whether we're an even or odd row */
    private int rowCnt = 0;
    /** How many columns are there? */
    protected int numberOfColumns = 0;
    /** Which column are we rendering now? */
    protected int columnCount = 0;
    /** Which row are we on now? */
    protected int currRow = 0;

    private String filterBy;
    /** type of table we are using. default is list" */
    private String type = "list";
    /** determines whether or not we should show the borders
     *  of the list and if the rows should all be white
     */
    private boolean transparent = false;
    /** determines whether we should show the disabled CSS */
    private boolean renderDisabled;
    /** comma separated list of columns to be exported */
    private String exportColumns;
    /** optional title attribute for displaying a titled list */
    private String title;
    private String hiddenvars;
    private String nodeIdString = null;

    /** Public constructor  */
    public UnpagedListDisplayTag() {
    }

    /**
     * @return Returns the disabled.
     */
    public boolean renderDisabled() {
        return renderDisabled;
    }
    /**
     * @param disabled The disabled to set.
     */
    public void setRenderDisabled(String disabled) {
        renderDisabled = disabled.equals("true");
    }
    
    /**
     * Set the header of the filter on which to filter
     * @param filterByIn The filterBy to set.
     */
    public void setFilterBy(String filterByIn) {
        this.filterBy = filterByIn;
    }
    
    /**
     * Returns the title message key.
     * @return Returns the title.
     */
    public String getTitle() {
        return title;
    }

    /**
     * Sets the title message key.
     * @param titleIn The title to set.
     */
    public void setTitle(String titleIn) {
        title = titleIn;
    }
    
    
    /**
     * Sets the type of the list
     * @param stringIn desired alignment for the list
     */
    public void setType(String stringIn) {
        type = stringIn;
    }
    
    /**
     * Gets the type of the list
     * @return String alignment of the list
     */
    public String getType() {
        return type;
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
        Collections.sort(pageList, new DynamicComparator(sortedColumn, 
                request.getParameter(RequestContext.SORT_ORDER)));
    }
    
    /**
     * @return Returns the hiddenvars.
     */
    public String getHiddenvars() {
        return hiddenvars;
    }
    
    /**
     * @param hv The hiddenvars to set.
     */
    public void setHiddenvars(String hv) {
        this.hiddenvars = hv;
    }

    private String getSortedColumn() {
        HttpServletRequest request =
            (HttpServletRequest) pageContext.getRequest();
        return request.getParameter(RequestContext.LIST_SORT);        
    }

    private void setupPageList() throws JspTagException {
        ListTag listTag = (ListTag) findAncestorWithClass(this, ListTag.class);
        if (listTag == null) {
            throw new JspTagException("Tag nesting error: " + 
                    "listDisplay must be nested in a list tag");
        }
        pageList = listTag.getPageList();
        iterator = pageList.iterator();
        currRow = 0;
    }
    
    /**
     * Method to fetch a new ExportWriter instance.  Override
     * if desired to use different instance.  Currently creates
     * a new CSVWriter instance.
     * @return new instance of an ExportWriter
     */
    protected ExportWriter createExportWriter() {
        return new CSVWriter(new StringWriter());
    }
    
    /**
     * Increment the column # that is being rendered at this moment.
     **/
    public void incrColumnCount() {
        this.columnCount++;
    }

    /**
     * Increment the total number of columns
     **/
    public void incrNumberOfColumns() {
        this.numberOfColumns++;
    }

    /**
     * Get the number of the column that is being rendered at this moment.
     * (0 == The first column)
     * @return int the column number
     **/
    public int getColumnCount() {
        return this.columnCount;
    }

    /**
     * Get the number of columns in the list.
     * @return int the number of columns
     **/
    public int getNumberOfColumns() {
        return this.numberOfColumns;
    }

    /**
     * Set the number of columns in the list.
     * @param num number of columns i nthe list
     **/
    public void setNumberOfColumns(int num) {
        this.numberOfColumns = num;
    }

    /**
     * Set the column # that is being rendered at this moment
     *
     * Used when 'colspan' is used for an element to skip over the
     * intervening columns.
     *
     * @param columnCountIn The column count to set.
     **/
    public void setColumnCount(int columnCountIn) {
        this.columnCount = columnCountIn;
    }

    //////////////////////////////////////////////////////////////////////////
    // RENDER methods
    //////////////////////////////////////////////////////////////////////////
    
    /**
     * Renders the title header if set.
     * @param out JspWriter
     * @throws IOException thrown if there's a problem writing to the JSP
     */
    private void renderTitle(JspWriter out) throws IOException {
        if (!StringUtils.isEmpty(title)) {
            HtmlTag tr = new HtmlTag("tr");
            HtmlTag th = new HtmlTag("th");
            th.addBody(LocalizationService.getInstance().getMessage(title));
            tr.addBody(th);
            out.println(tr.render());
        }
    }
    
    private void renderFilterBox(JspWriter out) throws IOException {
        LocalizationService ls = LocalizationService.getInstance();        
        HtmlTag tag = new HtmlTag("div");
        tag.setAttribute("class", "filter-input");

        StringBuffer buf = new StringBuffer();
        HtmlTag input = new HtmlTag("input");
        input.setAttribute("type", "text");
        input.setAttribute("size", "12");
        input.setAttribute("name", RequestContext.FILTER_STRING);
        input.setAttribute("value", pageList.getFilterData());
        buf.append(input.render());
        
        input = new HtmlTag("input");
        input.setAttribute("type", "hidden");
        input.setAttribute("name", "prev_filter_value");
        input.setAttribute("value", pageList.getFilterData());
        buf.append(input.render());
        
        input = new HtmlTag("input");
        input.setAttribute("type", "submit");
        input.setAttribute("name", ListDisplayTag.FILTER_DISPATCH);        
        input.setAttribute("value", ls.getMessage(RequestContext.FILTER_KEY));
        buf.append(input.render());
        
        /* 
         * TODO: This is BAD. Makes the code specific to the Chanel Tree view
         * Should be fixed in future versions
         */
        tag.addBody(ls.getMessage("message.filterby", ls.getMessage(filterBy)) +
                    buf.toString());
        
        
        if (type.equals("treeview")) {
            tag.addBody("<div style=\"text-align: right;\">" +
                    "<a href=\"javascript:showAllRows();\" style=\"cursor: pointer;\">" +
                    ls.getMessage("channels.overview.showall") +
                    "</a>&nbsp;&nbsp;|&nbsp;&nbsp;" +
                    "<a href=\"javascript:hideAllRows();\" style=\"cursor: pointer;\">" +
                    ls.getMessage("channels.overview.hideall") + "</a></div>");
        }

        
        out.println(tag.render());        
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
        return (ctx.isRequestedExport() && this.exportColumns != null); 
    }

    /**
     * @return Returns the exportColumns.
     */
    public String getExportColumns() {
        return exportColumns;
    }

    /**
     * @param exportIn The export to set.
     */
    public void setExportColumns(String exportIn) {
        this.exportColumns = exportIn;
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

            if (pageList.hasFilter()) {
                renderFilterBox(out);
            }
            
            /* If the type is list, we must set the width explicitly. Otherwise,
             * it shouldn't matter
             */
            if (type.equals("list")) {
                out.print("<table width=\"100%\" cellspacing=\"0\"" +
                        " cellpadding=\"0\" " + "class=\"list\"");               
            }
            else if (type.equals("treeview")) {
                out.print("<table width=\"100%\" cellspacing=\"0\"" +
                        " cellpadding=\"0\" " + "class=\"list\" id=\"channel-list\""); 
            }
            else {
                out.print("<table cellspacing=\"0\" " + " cellpadding=\"0\" " +
                            "class=\"" + type + "\"");
            }

            /*if (isTransparent()) {
                out.print(" style=\"border-bottom: 1px solid #ffffff;\" ");
            }*/
            
            
            out.println(">");
            
            out.println("<thead>");
            renderTitle(out);
            
            out.println("\n<tr>");
            
            if (iterator != null && iterator.hasNext()) {
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
            if (pageList.isEmpty()) {
                return EVAL_PAGE;
            }

            if (isExport()) {
                ExportWriter eh = createExportWriter();
                String[] columns  = StringUtils.split(this.exportColumns, ',');
                eh.setColumns(Arrays.asList(columns));
                ServletExportHandler seh = new ServletExportHandler(eh);
                pageContext.getOut().clear();
                pageContext.getOut().clearBuffer();
                pageContext.getResponse().reset();
                seh.writeExporterToOutput(
                        (HttpServletResponse) pageContext.getResponse(),
                        pageList);
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

            if (iterator.hasNext()) {
                columnCount = 0;
                Object next = iterator.next();
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
    public void release() {
        // reset the state of the tag
        iterator = null;
        currRow = 0;
        pageList = null;
        rowCnt = 0;
        filterBy = null;
        type = "list";
        renderDisabled = false;
        exportColumns = null;
        title = null;
        hiddenvars = null;
        nodeIdString = null;
        columnCount = 0;
        numberOfColumns = 0;
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
