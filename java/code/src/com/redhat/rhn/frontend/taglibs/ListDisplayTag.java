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
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.dto.UserOverview;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.listview.AlphaBar;
import com.redhat.rhn.frontend.listview.PaginationUtil;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.acl.AclManager;

import org.apache.commons.lang.StringUtils;

import java.io.IOException;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyContent;
import javax.servlet.jsp.tagext.BodyTagSupport;

/**
 * The ListDisplayTag defines the structure of the ListView.  This tag iterates
 * through the {@link com.redhat.rhn.common.db.datasource.DataResult DataResult}
 * contained in its parent tag,
 * {@link com.redhat.rhn.frontend.taglibs.ListTag ListTag}. In the first
 * iteration the {@link com.redhat.rhn.frontend.taglibs.ColumnTag ColumnTags}
 * render the headers of the ListView, while subsequent iterations render the
 * data contained within the
 * {@link com.redhat.rhn.common.db.datasource.DataResult DataResult}.
 * <p>
 * The ListTag has the following optional attributes: 
 * <code>filterBy</code> 
 * <code>set</code> 
 * <code>hiddenvars</code>
 * <code>exportColumns</code>
 * <code>renderDisabled</code>
 * <code>mixins</code>
 * <code>button</code>
 * <code>button2</code>
 * <code>buttonAcl</code>
 * <code>button2Acl</code>
 * <code>domainClass</code>
 * <code>title</code>
 * <code>paging</code>
 * <code>type</code>
 * <code>reflink</code>
 * <code>reflinkkey</code>
 * <code>reflinkkeyarg0</code>
 * <code>description</code>
 * <code>transparent</code>
 * 
 * When using a child {@link com.redhat.rhn.frontend.taglibs.SetTag SetTag}, 
 * the <code>set</code> and <code>hiddenvars</code> become <strong>REQUIRED</strong>.
 * <p>
 * The <code>filterBy</code> attribute specifies the column name with which
 * to filter the data.
 * <p>
 * The <code>paging</code> attribute determines whether or not paging buttons should be
 * shown.
 * <p>
 * The <code> type </code> attribute sepcifies whether the list is a normal full list
 * or a half-table
 * <p>
 * <code> reflink </code> will cause a link to display in the lower right corner of the
 * table while <code> reflinkkey </code> is the localization message we wish to show
 * that will be the key of the link. <code>reflinkkeyarg0</code> is an optional 
 * argument to be passed to 
 * the LocalizationService. <code>description</code> is what will appear
 * in non-paged lists in the lower left corner in the "1 of 1 <code>description</code>
 * displayed." <code>transparent</code> if set to true will make it so that the
 * table has no borders, and all the rows are white.
 * Example usage of the ListDisplayTag with no sets:
 * <pre>
 * ...
 * &lt;rhn:listdisplay&gt;
 *   &lt;rhn:column header="l10n.jsp.messagekey"&gt;
 *      display this value
 *   &lt;/rhn:column&gt;
 *   &lt;rhn:column header="l10n.jsp.messagekey1"&gt;
 *      display this value too
 *   &lt;/rhn:column&gt;
 * &lt;/rhn:listdisplay&gt;
 * ...
 * </pre>
 * The following shows how to define a ListView with a set column.
 * <pre>
 * ...
 * &lt;rhn:listdisplay set="${requestScope.set}"
 *                     hiddenvars="${requestScope.keep}"&gt;
 *   &lt;rhn:set value="${current.id}"/&gt;
 *   &lt;rhn:column header="l10n.jsp.messagekey1"&gt;
 *      display this value
 *   &lt;/rhn:column&gt;
 * &lt;/rhn:listdisplay&gt;
 * ...
 * </pre>
 *
 * @version $Rev$
 * @see com.redhat.rhn.frontend.taglibs.ColumnTag
 * @see com.redhat.rhn.frontend.taglibs.ListTag
 * @see com.redhat.rhn.frontend.taglibs.SetTag
 * @see com.redhat.rhn.domain.rhnset.RhnSet
 */
public class ListDisplayTag extends BodyTagSupport {
    public static final String FILTER_DISPATCH = "filter.dispatch";
    private static final String LAST = "Last";
    private static final String NEXT = "Next";
    private static final String PREV = "Prev";
    private static final String FIRST = "First";
    private static final String LAST_LOWER = "last_lower";
    private static final String NEXT_LOWER = "next_lower";
    private static final String PREV_LOWER = "prev_lower";
    private static final String FIRST_LOWER = "first_lower";
    private static final Set PAGINATION_WASH_SET = buildPaginationWashSet();
    
    /** iterates through the page list */
    private Iterator iterator;
    /** list of data to show on page */
    private DataResult pageList;
    /** row count determines whether we're an even or odd row */
    protected int rowCnt = 0;
    /** How many columns are there? */
    protected int numberOfColumns = 0;
    /** Which column are we rendering now? */
    protected int columnCount = 0;

    private String filterBy;
    private RhnSet set;
    private String hiddenvars;
    /** contains the number of items checked */
    private int numItemsChecked;
    /** true if we are to show the set operation buttons */
    private boolean showSetButtons;
    
    private String buttonsAttrName;
    private String buttonsAttrValue;
   
    /** true if we are a paging list */
    private boolean paging = true;
    /** type of table we are using. default is list" */
    private String type = "list";
    /** The URL that will appear in the lower right corner of the table */
    private String reflink;
    /** The text of the refferal that will appear 
     * in lower right corner of the table. Should
     * be a trans-unit id.
     */
    private String reflinkkey;
    /**
     * Argument to the localization service
     * for the reflinkkey. Optional
     */
    private String reflinkkeyarg0;
    /**
     * Description of what data the list is
     * showing. Should be a trans-unit id
     */
    private String description;
    /** determines whether or not we should show the borders
     *  of the list and if the rows should all be white
     */
    private boolean transparent = false;
    /** determines whether we should show the disabled CSS */
    private boolean renderDisabled;
    /** buttons and associated acls */
    private String button;
    private String buttonAcl;
    private String button2;
    private String button2Acl;
    private String mixins;
    private String domainClass;
    /** comma separated list of columns to be exported */
    private String exportColumns;
    /** optional title attribute for displaying a titled list */
    private String title;
    /** **/
    private String tableId;

    // The following keys apply to functionality that affects the contents of the list
    // tag's table
    public static final String UPDATE_LIST_KEY = "Update List";
    public static final String SELECT_ALL_KEY = "Select All";
    public static final String UNSELECT_ALL_KEY = "Unselect All";
    public static final String ADD_TO_SSM_KEY = "Add to SSM";

    /**
     * @return Returns the tableId.
     */
    public String getTableId() {
        return tableId;
    }

    /**
     * @param tableIdIn The tableId to set.
     */
    public void setTableId(String tableIdIn) {
        this.tableId = tableIdIn;
    }

    /** Public constructor  */
    public ListDisplayTag() {
    }
    
    /**
     * domainClass is used by the page loader to display what
     * domain object it is loading. For example, if this is 
     * a system display list, the domainClass should be "systems".
     * This is a key to the StringResource for the translated version
     * of the domain object.
     * @return Key for the domain object
     */
    public String getDomainClass() {
        // If domainClass wasn't set, default to "Items"
        if (domainClass == null) {
            return "items";
        }
        return domainClass;
    }
    
    /**
     * Set the name:value pair for the request attribute controlling display
     * of any optional buttons
     * @param attrNameValue name/value pair separated by ":"
     * @throws JspException indicates attrNameValue is in the wrong format
     */
    public void setButtonsAttr(String attrNameValue) throws JspException {
        String[] parts = attrNameValue.split(":");
        if (parts.length != 2) {
            throw new JspException("buttonsAttr value must be of the form \"name:value\"");
        }
        buttonsAttrName = parts[0];
        buttonsAttrValue = parts[1];
    }
    
    /**
     * @param domainClassIn The domainClass to set.
     */
    public void setDomainClass(String domainClassIn) {
        this.domainClass = domainClassIn;
    }
    
    /**
     * @return Returns the button.
     */
    public String getButton() {
        return button;
    }
    /**
     * @param buttonIn The button to set.
     */
    public void setButton(String buttonIn) {
        this.button = buttonIn;
    }
    /**
     * @return Returns the button2.
     */
    public String getButton2() {
        return button2;
    }
    /**
     * @param button2In The button2 to set.
     */
    public void setButton2(String button2In) {
        this.button2 = button2In;
    }
    /**
     * @return Returns the button2Acl.
     */
    public String getButton2Acl() {
        return button2Acl;
    }
    /**
     * @param button2AclIn The button2Acl to set.
     */
    public void setButton2Acl(String button2AclIn) {
        this.button2Acl = button2AclIn;
    }
    /**
     * @return Returns the buttonAcl.
     */
    public String getButtonAcl() {
        return buttonAcl;
    }
    /**
     * @param buttonAclIn The buttonAcl to set.
     */
    public void setButtonAcl(String buttonAclIn) {
        this.buttonAcl = buttonAclIn;
    }
    /**
     * @return Returns the mixins.
     */
    public String getMixins() {
        return mixins;
    }
    /**
     * @param mixinsIn The mixins to set.
     */
    public void setMixins(String mixinsIn) {
        this.mixins = mixinsIn;
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
     * Set the set for this listview.
     * @param s The set to set.
     */
    public void setSet(RhnSet s) {
        this.set = s;
    }
    
    /**
     * Get the set
     * @return The set for this page
     */
    public RhnSet getSet() {
        return set;
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
     * Returns true if this is a paging list.
     * @return true if this is a paging list.
     */
    public boolean isPaging() {
        return paging;
    }
   
    /**
     * Sets this list as either a paging or non-paging list.
     * @param topageornottopage true for a paging list, false otherwise.
     */
    public void setPaging(boolean topageornottopage) {
        paging = topageornottopage;
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
     * sets the reflink to be used
     * @param stringIn the reflink to be used
     */
    public void setReflink(String stringIn) {
        reflink = stringIn;
    }
    
    /**
     * @return returns the reflink
     */
    public String getReflink() {
        return reflink;
    }
    
    /**
     * Sets the refLinkKey to be used
     * @param stringIn the reflinkkey to be used
     */
    public void setReflinkkey(String stringIn) {
        reflinkkey = stringIn;
    }
    
    /**
     * @return returns the reflinkkey
     */
    public String getReflinkkey() {
        return reflinkkey;
    }
    
    /**
     * Sets the first argument for the reflinkkey
     * @param stringIn the reflinkkeyarg0 to be used
     */
    public void setReflinkkeyarg0(String stringIn) {
        reflinkkeyarg0 = stringIn;
    }
    
    /**
     * @return returns reflinkeyarg1
     */
    public String getReflinkkeyarg0() {
        return reflinkkeyarg0;
    }
    /**
     * @param stringIn trans-unit id of the description we wish to use
     */
    public void setDescription(String stringIn) {
        description = stringIn;
    }
    
    /**
     * @return String that is the trans-unit id of the description we wish
     * to use 
     */
    public String getDescription() {
        return description;
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

    private void renderExport(JspWriter out) throws IOException {
        HttpServletRequest request =
            (HttpServletRequest) pageContext.getRequest();

        StringBuffer page =
            new StringBuffer((String) request.getAttribute("requestedUri"));

        page.append("?" + RequestContext.LIST_DISPLAY_EXPORT + "=1");
        if (request.getQueryString() != null) {
            page.append("&" + request.getQueryString());
        }
        out.println("<div class=\"csv-download\"><a href=\"" + page + 
              "\"><img src=\"/img/csv-16.png\"/ alt=\"\">" + 
              LocalizationService.getInstance().getMessage("listdisplay.csv") +
              "</a></div>");
    }
    
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
    
    private void renderBoundsVariables(JspWriter out) throws IOException {
        StringBuffer target = new StringBuffer();
        // pagination formvars
        renderHidden(target, "lower", String.valueOf(pageList.getStart()));
            
        PaginationUtil putil = new PaginationUtil(
                                    pageList.getStart(), 
                                    pageList.getEnd(),
                                    pageList.getEnd() - pageList.getStart() + 1, 
                                    pageList.getTotalSize());
    
        renderHidden(target, FIRST_LOWER, putil.getFirstLower());
        renderHidden(target, PREV_LOWER, putil.getPrevLower());
        renderHidden(target, NEXT_LOWER, putil.getNextLower());
        renderHidden(target, LAST_LOWER, putil.getLastLower());
        out.println(target.toString());
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
        input.setAttribute("name", RequestContext.PREVIOUS_FILTER_STRING);
        input.setAttribute("value", pageList.getFilterData());
        buf.append(input.render());
        
        input = new HtmlTag("input");
        input.setAttribute("type", "submit");
        input.setAttribute("name", FILTER_DISPATCH);
        input.setAttribute("value", ls.getMessage(RequestContext.FILTER_KEY));
        buf.append(input.render());
        

        tag.addBody(ls.getMessage("message.filterby", ls.getMessage(filterBy)) +
                    buf.toString());
        out.println(tag.render());        
    }

    
    private void renderSetButtons(JspWriter out) throws IOException {
        StringBuffer buf = new StringBuffer();
        addButtonTo(buf, RequestContext.DISPATCH, UPDATE_LIST_KEY);
        buf.append(" ");
        addButtonTo(buf, RequestContext.DISPATCH, SELECT_ALL_KEY);
        
        if (numItemsChecked > 0) {
            buf.append(" ");
            addButtonTo(buf, RequestContext.DISPATCH, UNSELECT_ALL_KEY);            
        }
        out.println(buf.toString());
    }
    
    private void addButtonTo(StringBuffer buf, String name, 
                               String label) {
        
        LocalizationService ls = LocalizationService.getInstance();
        
        HtmlTag input = new HtmlTag("input");
        input.setAttribute("type", "submit");
        input.setAttribute("name", name);
        input.setAttribute("value", ls.getMessage(label));
        buf.append(input.render());

    }    
    private void renderPagination(JspWriter out, boolean top) 
        throws IOException {

        if (type.equals("list")) {
            out.println("<table width=\"100%\" class=\"list-pagination\"");
        }
        else {
            out.println("<table class=\"list-pagination\"");
        }
        
        if (tableId != null) {
            out.print("id=\"" + tableId + "\" ");
        }
        
        out.println(">");
        out.println("<tr>");
       // if (!showSetButtons) {
            out.println("<td valign=\"middle\" width=\"90%\">");            
        //}
        //else {
        //    out.println("<td valign=\"middle\">");  
        //}

        if (top && pageList.hasFilter()) {
            renderFilterBox(out);
        }
        if (!top && set != null) {
            if (showSetButtons) {
                out.print("<span class=\"list-selection-buttons\">");
                renderSetButtons(out);
                out.print("</span>");
            }
        }
        if (!top && exportColumns != null) {
            renderExport(out);
        }
        
        
        out.println("</td>");
        out.print("<td valign=\"middle\" class=\"list-infotext\">");
        int finalResult = pageList.getEnd();
        if (finalResult > pageList.getTotalSize()) {
            finalResult = pageList.getTotalSize();
        }
        
        Object [] args = new Object[4];
        if (pageList.size() == 0) {
            args[0] = new Integer(0);
            args[1] = args[0];
            args[2] = args[0];
        }
        else {
            args[0] = new Integer(pageList.getStart());
            args[1] = new Integer(finalResult);
            args[2] = new Integer(pageList.getTotalSize());
        }
        out.println(LocalizationService.getInstance()
                    .getMessage("message.range", args));
        
        if (set != null) {
            if (top) {
                out.print("<strong><span id=\"pagination_selcount_top\">");
            }
            else {
                out.print("<strong><span id=\"pagination_selcount_bottom\">");
            }
            out.print(LocalizationService.getInstance()
                      .getMessage("message.numselected",
                           Integer.toString(set.size()))
                      );
            out.print("</span></strong>\n");
        }

        out.println("</td>");
        appendButtons(out);
        out.println("  </tr>\n");
        out.println("</table>");
    }
    
    private void appendButtons(JspWriter out) throws IOException {
        out.println("<td valign=\"middle\" class=\"list-navbuttons\">");

        boolean canGoForward = pageList.getEnd() < pageList.getTotalSize();
        boolean canGoBack = pageList.getStart() > 1;

        if (canGoForward || canGoBack) {
            out.println(renderPaginationButton(FIRST,
                    "/img/list-allbackward", " |&lt; ", canGoBack));
            out.println(renderPaginationButton(PREV, "/img/list-backward",
                    " &lt; ", canGoBack));
            out.println(renderPaginationButton(NEXT, "/img/list-forward",
                    " &gt; ", canGoForward));
            out.println(renderPaginationButton(LAST,
                    "/img/list-allforward", " &gt;| ", canGoForward));
        }
        out.println("</td>\n");
    }
    
    private String renderPaginationButton(String name, String imgPrefix,
            String text, boolean active) {
        HtmlTag ret = new HtmlTag("input");
        ret.setAttribute("type", "image");
        ret.setAttribute("name", name);
        ret.setAttribute("value", text);

        if (active) {
            ret.setAttribute("class", "list-nextprev-active");
            ret.setAttribute("src", imgPrefix + ".gif");
        }
        else {
            ret.setAttribute("class", "list-nextprev-inactive");
            ret.setAttribute("src", imgPrefix + "-unfocused.gif");
        }

        return ret.render();
    }
    
    private void renderActionButtons(JspWriter out) throws IOException {
        if (pageList.size() == 0 || getButton() == null) {
            return;
        }
        
        if (!hasButtonAttrs()) {
            return;
        }
        
        
        out.println("<div align=\"right\">");
        out.println("  <hr />");
        
        if (getButton() != null && AclManager.hasAcl(getButtonAcl(), 
                (HttpServletRequest) pageContext.getRequest(), getMixins())) {
            
            out.println("<input type=\"submit\" name=\"dispatch\" value=\"" + 
                    LocalizationService.getInstance().getMessage(getButton()) +
                    "\" />");
        }
        if (getButton2() != null && AclManager.hasAcl(getButton2Acl(),
                (HttpServletRequest) pageContext.getRequest(), getMixins())) {
            
            out.println("<input type=\"submit\" name=\"dispatch\" value=\"" + 
                    LocalizationService.getInstance().getMessage(getButton2()) +
                    "\" />");
        }
        
        out.println("</div>");
    }
    
    private boolean hasButtonAttrs() {
        boolean retval = true;
        if (buttonsAttrName != null && buttonsAttrValue != null) {
            String value = (String) pageContext.getAttribute(buttonsAttrName);
            if (value == null) {
                value = (String) pageContext.getRequest().getAttribute(buttonsAttrName);
            }
            if (value != null) {
                retval = value.equals(buttonsAttrValue);
            }
        }
        return retval;
    }

    protected String getTrElement(Object o) {
        rowCnt++;
        rowCnt = rowCnt % 2;

        StringBuffer retval;
        if (rowCnt == 1 || isTransparent()) {
            retval = new StringBuffer("<tr class=\"list-row-odd");
        }
        else {
            retval = new StringBuffer("<tr class=\"list-row-even");
        }
        if (renderDisabled() && o instanceof UserOverview && 
                ((UserOverview)o).getStatus() != null &&
                ((UserOverview)o).getStatus().equals("disabled")) {
                return retval.append("-disabled\">").toString();
        }
        return retval.append("\">").toString();
    }

    /**
     * Renders an HTML Input hidden tag into the given buffer
     * with the given name and value.
     *
     * For a name of foo and a value of bar the following
     * will be appended to the buffer.
     * <pre>
     * <input type="hidden" name="foo" value="bar" />
     * </pre>
     * @param buf StringBuffer that will be affected.
     * @param name Name of hidden input tag.
     * @param value Value of hidden input tag.
     */
    private void renderHidden(StringBuffer buf, String name, String value) {
        HtmlTag input = new HtmlTag("input");
        input.setAttribute("type", "hidden");
        input.setAttribute("name", name);
        input.setAttribute("value", value);
        buf.append(input.render() + "\n");
    }

    private void renderViewAllLink(JspWriter out) throws IOException {
        
        
        /*
         * Bugzilla #185976
         * Link isn't working correctly commenting out for now
         * TODO: fix this
         * HtmlTag link = new HtmlTag("a");*/
        
        /*
        link.setAttribute("href", "/rhn/Load.do?pagesize=" +
                pageList.getTotalSize() + "&amp;what=" + getDomainClass() +
                "&amp;return_url=" + buildReturnUrl());
        
        link.addBody(
                LocalizationService.getInstance().getMessage(
                        "listdisplaytag.viewall"));
        
        out.println(link.render());*/
    }

    private void renderAlphabar(JspWriter out) throws IOException {
        StringBuffer target = new StringBuffer();
        
        if (type.equals("list")) {
            target.append("<table width=\"100%\" cellspacing=\"0\"" + 
            " cellpadding=\"1\">");
        }
        else {
            target.append("<table cellspacing=\"0\" " + " cellpadding=\"1\">");
        }

        target.append("<tr valign=\"top\">");
        target.append("<td class=\"list-alphabar\"><div align=\"center\"><strong>");
        StringBuffer enabled = new StringBuffer("<a href=\"");
        enabled.append("?lower={1}");

        /**
         * Add any query args we got to alphabar links.
         * We do it this way to ensure that any variables set on the page
         * carry from form submission (by pressing the pagination buttons) 
         * to the alphabar links and vice-versa.
         */
        ServletRequest rq = pageContext.getRequest();
        String formvars = rq.getParameter("formvars");
        if (formvars != null) { //get vars from form submission
            String[] keys = formvars.split(",\\s?");
            for (int j = 0; j < keys.length; j++) {
                if (!PAGINATION_WASH_SET.contains(keys[j])) {
                    String encodedParam = StringUtil.urlEncode(rq.getParameter(keys[j]));
                    enabled.append("&amp;" + keys[j] + "=" + encodedParam);
                }
            }
        }
        else { //get vars from url
            Map qvars = rq.getParameterMap();
            qvars.remove("lower"); //don't repeat lower
            Iterator iter = qvars.keySet().iterator();
            while (iter.hasNext()) {
                String key = (String) iter.next();
                if (!PAGINATION_WASH_SET.contains(key)) {
                    String encodedParam = StringUtil.urlEncode(rq.getParameter(key)); 
                    enabled.append("&amp;" + key + "=" + encodedParam);
                }
            }
        }

        enabled.append("\" class=\"list-alphabar-enabled\">{0}</a>");
        AlphaBar ab = new AlphaBar(enabled.toString(),
                      "<span class=\"list-alphabar-disabled\">{0}</span>");
        target.append(ab.getAlphaList(pageList.getIndex()));
        target.append("</strong></div>");
        target.append("<br />");
        target.append("</td>");
        target.append("  </tr>");
        target.append("</table>");

        out.println(target.toString());
    }

    /**
     * Increment the count of the number of checked checkboxes.  Only for
     * use with the SetTag.
     */
    protected void incrementChecked() {
        numItemsChecked++;
    }
    
    /**
     * Tells the ListDisplayTag to show Update List and Select All buttons.
     */
    protected void showButtons() {
        showSetButtons = true;
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
    
    /**
     * Build a set of all URL variables that are pagination-specific
     * and should not be part of the URL's in the Alphabar
     * @return a set of all URL variables that are pagination-specific
     */
    private static Set buildPaginationWashSet() {
        String [] keys = new String[] {FIRST, PREV, NEXT, LAST, 
                                        FIRST_LOWER, PREV_LOWER, 
                                            NEXT_LOWER, LAST_LOWER };
        Set result = new HashSet();
        for (int i = 0; i < keys.length; i++) {
            result.add(keys[i]);
            //add the .x & .y's becasue these are image files
            //so certain browsers may add the .x & .y's
            result.add(keys[i] + ".x");
            result.add(keys[i] + ".X");
            result.add(keys[i] + ".y");
            result.add(keys[i] + ".Y");
        }
        return Collections.unmodifiableSet(result);
    }

    //////////////////////////////////////////////////////////////////////////
    // JSP Tag lifecycle methods
    //////////////////////////////////////////////////////////////////////////
    
    /** {@inheritDoc} */
    public int doStartTag() throws JspException {
        rowCnt = 0;
        numItemsChecked = 0;
        numberOfColumns = 0;
        JspWriter out = null;
        showSetButtons = false;
        
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
            
            /* If pageList contains an index and pageList.size() (what we are
             * displaying on the page) is less than pageList.getTotalSize()
             * (the total number of items in the data result), render alphabar.
             * This prevents the alphabar from showing up on pages that show
             * all of the entries on a single page and is similar to how the
             * perl code behaves. 
             */
            if (pageList.getIndex().size() > 0 && 
                    pageList.size() < pageList.getTotalSize()) {
                
                renderViewAllLink(out);
                renderAlphabar(out);
            }
            
            if (isPaging()) {
                renderPagination(out, true);
                renderBoundsVariables(out);
            }

            /* If the type is list, we must set the width explicitly. Otherwise,
             * it shouldn't matter
             */
            if (type.equals("list") && title == null) {
                out.print("<table width=\"100%\" cellspacing=\"0\"" +
                        " cellpadding=\"0\" " + "class=\"list\"");               
            }
            else if (type.equals("list") && title != null) {
                out.print("<table width=\"100%\" cellspacing=\"0\"" +
                        " cellpadding=\"0\" " + "class=\"list list-doubleheader\"");    
            }
            else {
                out.print("<table cellspacing=\"0\" " + " cellpadding=\"0\" " +
                            "class=\"" + type + "\"");
            }

            /*if (isTransparent()) {
                out.print(" style=\"border-bottom: 1px solid #ffffff;\" ");
            }*/
            
            if (tableId != null) {
                out.print(" id=\"" + tableId + "\"");
            }
            
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
                // The toReplace string is kind of odd, but it is because
                // HtmlTag doesn't understand adding a property to be replaced.
                if (numItemsChecked == pageList.size()) {
                    bodyString = bodyString.replaceFirst("@@CHECKED@@=\"\"", 
                                                         "checked=\"1\"");
                }
                else {
                    bodyString = bodyString.replaceFirst("@@CHECKED@@=\"\"", "");
                }
                out.println(bodyString);
            }
            
            /* If the type is a half-table, we must draw an extra row on the 
             * end of the table if the reflink has been set
             */
                if (reflink != null) {
                    columnCount = 0;

                    out.println(getTrElement(null));

                    out.print("<td style=\"text-align: center;\" " +
                              "class=\"first-column last-column\" ");
                    
                    
                    /* TODO: Make this colspan setting dynamic so that
                     * the reflink row display correctly for lists of
                     * with n columns instead of just 2
                     */
                    out.println("colspan=\"2\">");
                    
                    out.println("<a href=\"" + reflink + "\" >");
                    
                    /* Here we render the reflink and its key. If the key hasn't been set
                     * we just display the link address itself.
                     */
                    if (reflinkkey != null) {
                        Object[] args = new Object[2];
                        
                        args[0] = new Integer(pageList.getTotalSize());
                        args[1] = reflinkkeyarg0;
                        
                        String message = LocalizationService.getInstance().
                                         getMessage(reflinkkey, args);
                        out.println(message);
                    }
                    else {
                        out.println(reflink);
                    }
                
                    out.println("</a>");
                    out.println("</td>");
                    out.println("</tr>");
                }
            
            out.println("</tbody>");
            out.println("</table>\n");

            /* If paging is on, we render the pagination */
            if (isPaging()) {
                renderPagination(out, false);
                renderActionButtons(out);
            }
            /* If paging is off and we are rendering a normal list,
             * we show a count of the results in the lower left corner
             * of the list
             */
            else if (type.equals("list")) {
                
                int finalResult = pageList.getEnd();
                if (finalResult > pageList.getTotalSize()) {
                    finalResult = pageList.getTotalSize();
                }
                
                Object [] args = new Object[4];
                args[0] = new Integer(pageList.getStart());
                args[1] = new Integer(finalResult);
                args[2] = new Integer(pageList.getTotalSize());
                args[3] = LocalizationService.getInstance().getMessage(description);
                
                out.print("<span class=\"full-width-note-left\">\n");
                out.print(LocalizationService.getInstance()
                            .getMessage("message.range.withtypedescription", args));
                out.println("</span>");
            }
            setColumnCount(0);
            numberOfColumns = 0;
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
                out.println(getTrElement(next));
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
        pageList = null;
        rowCnt = 0;
        filterBy = null;
        set = null;
        hiddenvars = null;
        numItemsChecked = 0;
        showSetButtons = false;
        paging = true;
        type = "list";
        renderDisabled = false;
        button = null;
        buttonAcl = null;
        button2 = null;
        button2Acl = null;
        mixins = null;
        domainClass = null;
        exportColumns = null;
        title = null;
        columnCount = 0;
        numberOfColumns = 0;
        buttonsAttrName = null;
        buttonsAttrValue = null;

        // now release our super classes
        super.release();
    }
}
