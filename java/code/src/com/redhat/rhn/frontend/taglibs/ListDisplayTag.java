/**
 * Copyright (c) 2009--2016 Red Hat, Inc.
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
import java.io.StringWriter;
import java.io.Writer;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyContent;

import org.apache.commons.lang.StringUtils;

import com.redhat.rhn.common.localization.LocalizationService;
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
import com.redhat.rhn.frontend.taglibs.list.DataSetManipulator;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * The ListDisplayTag defines the structure of the ListView.  This tag iterates
 * through the {@link com.redhat.rhn.common.db.datasource.DataResult DataResult}
 * contained in its parent tag,
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
public class ListDisplayTag extends ListDisplayTagBase {
    private static final long serialVersionUID = 8952182346554627507L;
    private static final Set<String> PAGINATION_WASH_SET = buildPaginationWashSet();

    /** row count determines whether we're an even or odd row */
    protected int rowCnt = 0;
    private RhnSet set;
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
    private String button;
    private String buttonAcl;
    private String button2;
    private String button2Acl;
    private String mixins;
    private String domainClass;

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
    @Override
    public void setType(String stringIn) {
        type = stringIn;
    }

    /**
     * Gets the type of the list
     * @return String alignment of the list
     */
    @Override
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
        Collections.sort(getPageList(), new DynamicComparator(sortedColumn,
                request.getParameter(RequestContext.SORT_ORDER)));
    }

    private String getSortedColumn() {
        HttpServletRequest request =
            (HttpServletRequest) pageContext.getRequest();
        return request.getParameter(RequestContext.LIST_SORT);
    }

    // ////////////////////////////////////////////////////////////////////////
    // RENDER methods
    //////////////////////////////////////////////////////////////////////////

    private void renderExport(JspWriter out) throws IOException {
        HttpServletRequest request =
            (HttpServletRequest) pageContext.getRequest();

        StringBuilder page =
            new StringBuilder((String) request.getAttribute("requestedUri"));

        page.append("?" + RequestContext.LIST_DISPLAY_EXPORT + "=1");
        if (request.getQueryString() != null) {
            page.append("&" + request.getQueryString());
        }
        IconTag i = new IconTag("item-download-csv");
        out.println("<div class=\"spacewalk-csv-download\"><a class=\"btn btn-link\"" +
              " href=\"" + page + "\">" + i.render() +
              LocalizationService.getInstance().getMessage("listdisplay.csv") +
              "</a></div>");
    }

    private void renderBoundsVariables(Writer out) throws IOException {
        StringBuilder target = new StringBuilder();
        // pagination formvars
        renderHidden(target, "lower", String.valueOf(getPageList().getStart()));

        PaginationUtil putil = new PaginationUtil(
                                    getPageList().getStart(),
                                    getPageList().getEnd(),
                                    getPageList().getEnd() - getPageList().getStart() + 1,
                                    getPageList().getTotalSize());

        renderHidden(target, RequestContext.Pagination.FIRST.getLowerAttributeName(),
                putil.getFirstLower());
        renderHidden(target, RequestContext.Pagination.PREV.getLowerAttributeName(),
                putil.getPrevLower());
        renderHidden(target, RequestContext.Pagination.NEXT.getLowerAttributeName(),
                putil.getNextLower());
        renderHidden(target, RequestContext.Pagination.LAST.getLowerAttributeName(),
                putil.getLastLower());
        out.append(target.toString());
    }

    private void renderSetButtons(Writer out) throws IOException {
        StringBuilder buf = new StringBuilder();
        if (set != null) {
            if (showSetButtons) {
                buf.append("<span class=\"spacewalk-list-selection-btns\">");
                buf.append(addButtonTo(buf, RequestContext.DISPATCH, UPDATE_LIST_KEY,
                                                    "update_list_key_id").render());
                buf.append(" ");
                buf.append(addButtonTo(buf,
                                       RequestContext.DISPATCH, SELECT_ALL_KEY).render());

                if (numItemsChecked > 0) {
                    buf.append(" ");
                    buf.append(addButtonTo(buf, RequestContext.DISPATCH, UNSELECT_ALL_KEY)
                        .render());
                }
                buf.append("</span>");
            }
        }
        out.append(buf.toString());
    }

    private HtmlTag addButtonTo(StringBuilder buf, String name,
                               String label) {

        LocalizationService ls = LocalizationService.getInstance();

        HtmlTag btn = new HtmlTag("button");
        btn.setAttribute("class", "btn btn-default");
        btn.setAttribute("type", "submit");
        btn.setAttribute("name", name);
        btn.setAttribute("value", ls.getMessage(label));
        btn.addBody(ls.getMessage(label));
        return btn;

    }

    private HtmlTag addButtonTo(StringBuilder buf, String name,
                               String label, String id) {

        HtmlTag input = addButtonTo(buf, name, label);
        input.setAttribute("id", id);
        return input;

    }

    private void renderPagination(Writer out, boolean top)
        throws IOException {

        out.append("<div class=\"spacewalk-list-pagination\">\n");
        int finalResult = getPageList().getEnd();
        if (finalResult > getPageList().getTotalSize()) {
            finalResult = getPageList().getTotalSize();
        }

        Object [] args = new Object[4];
        if (getPageList().size() == 0) {
            args[0] = new Integer(0);
            args[1] = args[0];
            args[2] = args[0];
        }
        else {
            args[0] = new Integer(getPageList().getStart());
            args[1] = new Integer(finalResult);
            args[2] = new Integer(getPageList().getTotalSize());
        }
        out.append(LocalizationService.getInstance()
                    .getMessage("message.range", args));

        if ((set != null) && (!RhnSetDecl.SYSTEMS.getLabel().equals(set.getLabel()))) {
            if (top) {
                out.append(" <strong><span id=\"pagination_selcount_top\">");
            }
            else {
                out.append(" <strong><span id=\"pagination_selcount_bottom\">");
            }
            out.append(LocalizationService.getInstance()
                      .getMessage("message.numselected",
                           Integer.toString(set.size()))
                      );
            out.append("</span></strong>\n");
        }

        appendButtons(out);
        out.append("  </div>");
    }

    private void appendButtons(Writer out) throws IOException {
        out.append("<div class=\"spacewalk-list-pagination-btns btn-group\">\n");

        boolean canGoForward = getPageList().getEnd() < getPageList()
                .getTotalSize();
        boolean canGoBack = getPageList().getStart() > 1;

        if (canGoForward || canGoBack) {
            out.append(renderPaginationButton(
                    RequestContext.Pagination.FIRST.getElementName(),
                    DataSetManipulator.ICON_FIRST, canGoBack));
            out.append(renderPaginationButton(
                    RequestContext.Pagination.PREV.getElementName(),
                    DataSetManipulator.ICON_PREV,
                    canGoBack));
            out.append(renderPaginationButton(
                    RequestContext.Pagination.NEXT.getElementName(),
                    DataSetManipulator.ICON_NEXT,
                    canGoForward));
            out.append(renderPaginationButton(
                    RequestContext.Pagination.LAST.getElementName(),
                    DataSetManipulator.ICON_LAST, canGoForward));
        }
        out.append("</div>\n");
    }

    private String renderPaginationButton(String name, String icon,
            boolean active) {
        HtmlTag ret = new HtmlTag("button");
        ret.setAttribute("name", name);
        String styleClass = "btn btn-default btn-xs " + icon;

        if (!active) {
            styleClass += " disabled";
        }
        else {
            ret.setAttribute("title", name);
        }
        ret.setAttribute("class", styleClass);
        return ret.render();
    }

    private void renderActionButtons(JspWriter out) throws IOException {
        if (getPageList().size() == 0 || getButton() == null) {
            return;
        }

        if (!hasButtonAttrs()) {
            return;
        }

        out.println("<div class=\"col-sm-12 text-right\">");
        if (getButton2() != null && AclManager.hasAcl(getButton2Acl(),
                (HttpServletRequest) pageContext.getRequest(), getMixins())) {

            out.println("<button class=\"btn btn-default\"" +
                        " type=\"submit\" name=\"dispatch\" value=\"" +
                        LocalizationService.getInstance().getMessage(getButton2()) +
                        "\">" +
                        LocalizationService.getInstance().getMessage(getButton2()) +
                        "</button>");
        }
        if (getButton() != null && AclManager.hasAcl(getButtonAcl(),
                (HttpServletRequest) pageContext.getRequest(), getMixins())) {

            out.println("<button class=\"btn btn-primary\"" +
                    " type=\"submit\" name=\"dispatch\" value=\"" +
                    LocalizationService.getInstance().getMessage(getButton()) +
                    "\">" +
                    LocalizationService.getInstance().getMessage(getButton()) +
                    "</button>");
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

        StringBuilder retval;
        if (rowCnt == 1 || isTransparent()) {
            retval = new StringBuilder("<tr class=\"list-row-odd");
        }
        else {
            retval = new StringBuilder("<tr class=\"list-row-even");
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
     * @param buf StringBuilder that will be affected.
     * @param name Name of hidden input tag.
     * @param value Value of hidden input tag.
     */
    private void renderHidden(StringBuilder buf, String name, String value) {
        HtmlTag input = new HtmlTag("input");
        input.setAttribute("type", "hidden");
        input.setAttribute("name", name);
        input.setAttribute("value", value);
        buf.append(input.render() + "\n");
    }

    private void renderAlphabar(Writer out) throws IOException {
        StringBuilder target = new StringBuilder();

        target.append("<ul class=\"spacewalk-alphabar pagination pagination-sm\">");
        StringBuilder enabled = new StringBuilder("<li><a href=\"");
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
                if (keys[j].equals("submitted")) {
                    continue;
                }
                if (!PAGINATION_WASH_SET.contains(keys[j])) {
                    String encodedParam = StringUtil.urlEncode(rq.getParameter(keys[j]));
                    enabled.append("&amp;" +
                                   StringUtil.urlEncode(keys[j]) + "=" + encodedParam);
                }
            }
        }
        else { //get vars from url
            Iterator iter = rq.getParameterMap().keySet().iterator();
            while (iter.hasNext()) {
                String key = (String) iter.next();
                if (key.equals("submitted") || key.equals("lower")) {
                    continue;
                }
                if (!PAGINATION_WASH_SET.contains(key)) {
                    String encodedParam = StringUtil.urlEncode(rq.getParameter(key));
                    enabled.append("&amp;" +
                                   StringUtil.urlEncode(key) + "=" + encodedParam);
                }
            }
        }

        enabled.append("\">{0}</a><li>");
        AlphaBar ab = new AlphaBar(enabled.toString(),
                      "<li class=\"disabled\"><a href=\"#\">{0}</a></li>");
        target.append(ab.getAlphaList(getPageList().getIndex()));
        target.append("</ul>");
        out.append(target.toString());
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
        return (ctx.isRequestedExport() && this.getExportColumns() != null);
    }

    /**
     * Build a set of all URL variables that are pagination-specific
     * and should not be part of the URL's in the Alphabar
     * @return a set of all URL variables that are pagination-specific
     */
    private static Set<String> buildPaginationWashSet() {
        Set<String> result = new HashSet<String>();
        for (RequestContext.Pagination pagination : RequestContext.Pagination.values()) {
            result.add(pagination.getElementName());
            result.add(pagination.getLowerAttributeName());
        }
        return Collections.unmodifiableSet(result);
    }

    //////////////////////////////////////////////////////////////////////////
    // JSP Tag lifecycle methods
    //////////////////////////////////////////////////////////////////////////

    /** {@inheritDoc} */
    @Override
    public int doStartTag() throws JspException {
        rowCnt = 0;
        numItemsChecked = 0;
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

            out.print("<div class=\"spacewalk-list ");
            out.println(type + "\"");
            if (tableId != null) {
                out.print(" id=\"" + tableId + "\"");
            }
            out.println(">");

            /*
             * If pageList contains an index and pageList.size() (what we are
             * displaying on the page) is less than pageList.getTotalSize() (the
             * total number of items in the data result), render alphabar. This
             * prevents the alphabar from showing up on pages that show all of
             * the entries on a single page and is similar to how the perl code
             * behaves.
             */
            StringWriter alphaBarContent = new StringWriter();
            StringWriter paginationContent = new StringWriter();

            pageContext.pushBody(alphaBarContent);
            if (getPageList().getIndex().size() > 0 &&
                    getPageList().size() < getPageList().getTotalSize()) {

                //renderViewAllLink(alphaBarContent);
                renderAlphabar(alphaBarContent);
            }
            pageContext.popBody();

            pageContext.pushBody(paginationContent);
            if (isPaging()) {
                renderPagination(paginationContent, true);
                renderBoundsVariables(paginationContent);
            }
            pageContext.popBody();

            int topAddonsContentLen = alphaBarContent.getBuffer().length() +
                    paginationContent.getBuffer().length();

            if (topAddonsContentLen > 0) {
                out.println("<div class=\"spacewalk-list-top-addons\">");
                out.println("<div class=\"spacewalk-list-alphabar\">");
                out.print(alphaBarContent.getBuffer().toString());
                out.println("</div>");
                out.print(paginationContent.getBuffer().toString());
                out.println("</div>");
            }

            out.print("<div class=\"panel panel-default\">");

            renderPanelHeading(out);

            out.print("<table class=\"table table-striped\">");
            // we render the pagination controls as an additional head
            out.println("<thead>");
            out.println("\n<tr>");

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
    @Override
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
                // The toReplace string is kind of odd, but it is because
                // HtmlTag doesn't understand adding a property to be replaced.
                if (numItemsChecked == getPageList().size()) {
                    bodyString = bodyString.replaceFirst("@@CHECKED@@=\"\"",
                                                         "checked=\"1\"");
                }
                else {
                    bodyString = bodyString.replaceFirst("@@CHECKED@@=\"\"", "");
                }
                out.println(bodyString);
            }
            out.println("</tbody>");

            out.println("</table>");

            /* If the type is a half-table, we must draw an extra row on the
             * end of the table if the reflink has been set
             */
            out.println("<div class=\"panel-footer\">");
            out.println("<div class=\"spacewalk-list-footer-addons\">");
            out.println("<div class=\"spacewalk-list-footer-addons-extra\">");
            renderSetButtons(out);
            out.println("</div>");
            out.println("<div class=\"spacewalk-list-reflinks\">");
            if (reflink != null) {
                setColumnCount(0);
                out.println("<a href=\"" + reflink + "\" >");

                /*
                 * Here we render the reflink and its key. If the key hasn't
                 * been set we just display the link address itself.
                 */
                if (reflinkkey != null) {
                    Object[] args = new Object[2];

                    args[0] = new Integer(getPageList().getTotalSize());
                    args[1] = reflinkkeyarg0;

                    String message = LocalizationService.getInstance()
                            .getMessage(reflinkkey, args);
                    out.println(message);
                }
                else {
                    out.println(reflink);
                }

                out.println("</a>");
            }
            out.println("</div>");
            out.println("</div>");

            // close footer
            out.println("</div>");

            // close panel
            out.println("</div>");

            out.println("<div class=\"spacewalk-list-bottom-addons\">");
            out.println("<div class=\"spacewalk-list-pagination\">");
            /* If paging is on, we render the pagination */
            if (isPaging()) {
                renderPagination(out, false);
            }
            /* If paging is off and we are rendering a normal list,
             * we show a count of the results in the lower left corner
             * of the list
             */
            else if (type.equals("list")) {

                int finalResult = getPageList().getEnd();
                if (finalResult > getPageList().getTotalSize()) {
                    finalResult = getPageList().getTotalSize();
                }

                Object [] args = new Object[4];
                args[0] = new Integer(getPageList().getStart());
                args[1] = new Integer(finalResult);
                args[2] = new Integer(getPageList().getTotalSize());
                args[3] = LocalizationService.getInstance().getMessage(description);

                out.print("<span class=\"text-right\">\n");
                out.print(LocalizationService.getInstance()
                            .getMessage("message.range.withtypedescription", args));
                out.println("</span>");
            }
            out.println("</div>");
            if (isPaging()) {
                out.print("<div class=\"row-0\">\n");
                renderActionButtons(out);
                out.println("</div>");
            }
            out.println("</div>");

            // close list
            out.println("</div>");

            // export button goes outside of the list because in the new
            // implementation it is data-set dependent and not list dependent
            if (getExportColumns() != null) {
                renderExport(out);
            }

            setColumnCount(0);
            setNumberOfColumns(0);
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
    @Override
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
    @Override
    public void release() {
        // reset the state of the tag
        rowCnt = 0;
        set = null;
        numItemsChecked = 0;
        showSetButtons = false;
        paging = true;
        type = "list";
        button = null;
        buttonAcl = null;
        button2 = null;
        button2Acl = null;
        mixins = null;
        domainClass = null;
        buttonsAttrName = null;
        buttonsAttrValue = null;

        // now release our super classes
        super.release();
    }
}
