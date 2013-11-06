/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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


import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.BodyTagSupport;

import org.apache.commons.lang.StringUtils;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.RhnListTagFunctions;
import com.redhat.rhn.frontend.taglibs.list.decorators.ListDecorator;
import com.redhat.rhn.frontend.taglibs.list.decorators.PageSizeDecorator;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.row.RowRenderer;

/**
 * Renders a list of data bean in a page
 *
 * The list is rendered as a bootstrap 3.x panel
 *
 * The title of the list is put in the panel-heading
 * Pagination, alphabars and addons go into the panel-body
 * Bottom pagination and reflinks g into the panel-footer
 * The table goes as is, for seamless display into the panel
 *
 * @see http://getbootstrap.com/components/#panels
 *
 * @version $Rev $
 */
public class ListTag extends BodyTagSupport {

    private static final long serialVersionUID = 8581790371344355223L;
    private static final String[] PAGINATION_NAMES = { "allBackward",
            "backward", "forward", "allForward" };
    private static final String HIDDEN_TEXT = "<input type=\"hidden\" " +
                                                "name=\"%s\" value=\"%s\"/>";
    private boolean haveColsEnumerated = false;
    private boolean haveTblHeadingRendered = false;
    private boolean haveTblAddonsRendered = false;
    private boolean haveTblFootersRendered = false;
    private boolean haveColHeadersRendered = false;

    private int columnCount;
    private int pageSize = -1;
    private String dataSetName = ListHelper.DATA_SET;
    private String name = ListHelper.LIST;
    private String uniqueName;
    private List pageData;
    private Iterator iterator;
    private Object currentObject;
    private Object parentObject;
    private String styleClass = "list";
    private String styleId;
    private int rowCounter = -1;
    private String width;
    private ListFilter filter;
    private String rowName = "current";
    private DataSetManipulator manip;
    private String emptyKey;
    private String decoratorName = null;
    private List<ListDecorator> decorators;
    private RowRenderer rowRender;
    private String alphaBarColumn;
    private boolean hidePageNums = false;
    private String refLink;
    private String refLinkKey;
    private String refLinkKeyArg0;
    private String title;
    private boolean sortable;
    private boolean parentIsElement = true;
    private boolean searchParent = true;
    private boolean searchChild;

    /**
     * @param searchParentIn The searchParent to set.
     */
    public void setSearchparent(String searchParentIn) {
        searchParent = ListTagUtil.toBoolean(searchParentIn);
    }


    /**
     * @param searchChildIn The searchChild to set.
     */
    public void setSearchchild(String searchChildIn) {
        searchChild = ListTagUtil.toBoolean(searchChildIn);
    }

    /**
     * method to let the list tag know
     * that atleast one of its columns
     * is sortable. This will help the
     * list tag render the hidden sortBy
     * and sortDir fields..
     * This method has only package access
     * because on ColumnTag needs to talk to this.
     * @param isSortable true if atleast
     * one of the columns in this list is sortable
     */
    void setSortable(boolean isSortable) {
        sortable = isSortable;
    }

    private boolean isSortable() {
        return sortable;
    }
    /**
     * Adds a decorator to the parent class..
     * @param decName the name of the decorator
     * @throws JspException if the decorator can't be loaded.
     */
    public void addDecorator(String decName) throws JspException {
        ListDecorator dec = getDecorator(decName);
        if (dec != null) {
            getDecorators().add(dec);
        }
    }

    private List<ListDecorator> getDecorators() {
        if (decorators == null) {
            decorators = new LinkedList<ListDecorator>();
        }
        return decorators;
    }

    /**
     * Set the row renderer
     * @param newRender the row renderer
     */
    public void setRowRenderer(RowRenderer newRender) {
        rowRender = newRender;
    }

    private RowRenderer getRowRenderer() {
        if (rowRender == null) {
            rowRender = new RowRenderer();
        }
        return rowRender;
    }

    private ListDecorator getDecorator(String decName) throws JspException {
        if (decName != null) {
            ClassLoader cl = Thread.currentThread().getContextClassLoader();
            try {
                if (decName.indexOf('.') == -1) {
                    decName = "com.redhat.rhn.frontend.taglibs.list.decorators." +
                                                            decName;
                }
                ListDecorator dec = (ListDecorator) cl.loadClass(decName)
                        .newInstance();
                ListSetTag parent = (ListSetTag) BodyTagSupport
                        .findAncestorWithClass(this, ListSetTag.class);
                dec.setEnvironment(pageContext, parent, getUniqueName());
                return dec;
            }
            catch (Exception e) {
                String msg = "Exception while adding Decorator [" + decName + "]";
                throw new JspException(msg, e);
            }
        }
        return null;

    }
    /**
     * Sets the decorator class name to use for a list
     * @param nameIn decorator class name
     */
    public void setDecorator(String nameIn) {
        decoratorName = nameIn;
    }

    /**
     * Sets the localized message key used when the list is empty
     * @param key message key
     */
    public void setEmptykey(String key) {
        emptyKey = key;
    }

    /**
     * Bumps up the column count
     *
     */
    public void addColumn() {
        columnCount++;
        for (ListDecorator dec : getDecorators()) {
            dec.addColumn();
        }
    }

    /**
     * Returns
     * @return true if the data in use for the current page is empty
     */
    public boolean isEmpty() {
        return getPageData() == null || getPageData().isEmpty();
    }

    /**
     * Returns the data in use for the current page
     * @return list of data
     */
    public List getPageData() {
        return pageData;
    }

    /**
     * Gets column count
     * @return column count
     */
    public int getColumnCount() {
        return columnCount;
    }

    /**
     * Stores the "name" of the list. This is the "salt" used to build the
     * uniqueName used by the ListTag and ColumnTag.
     * @param nameIn list name
     */
    public void setName(String nameIn) {
        name = nameIn;
    }

    /**
     * The name of the list
     * @return the list name
     */
    public String getName() {
        return name;
    }

    /**
     * Build the list's unique name Algorithm for the unique name is: Take the
     * CRC value of the following string: request url + ";" + name
     * @return unique name
     */
    public synchronized String getUniqueName() {
        if (uniqueName == null) {
            uniqueName = TagHelper.generateUniqueName(name);
        }
        return uniqueName;
    }

    /**
     * Sets the CSS style class This applies to the enclosing table tag
     * @param styleIn class name
     */
    public void setStyleclass(String styleIn) {
        styleClass = styleIn;
    }


    /**
     * Total width of the table, either in px or percent
     * @param widthIn table width
     */
    public void setWidth(String widthIn) {
        width = widthIn;
    }

    /**
     * Sets the filter used to filter list data
     * @param filterIn name of the filter class to use
     * @throws JspException error occurred creating an instance of the filter
     */
    public void setFilter(String filterIn) throws JspException {
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        try {
            Class klass = cl.loadClass(filterIn);
            filter = (ListFilter) klass.newInstance();
            Context threadContext = Context.getCurrentContext();
            filter.prepare(threadContext.getLocale());
        }
        catch (Exception e) {
            throw new JspException(e.getMessage());
        }
    }

    /**
     *
     * @param f the filter to set
     */
    void setColumnFilter(ListFilter f) throws JspException {
        if (filter != null) {
            String msg = "Cannot set the column filter - [%s], " +
                        "since the table has been has already assigned a filter - [%s]";

            throw new JspException(String.format(msg, String.valueOf(f),
                                                        String.valueOf(filter)));
        }
        filter = f;
        Context threadContext = Context.getCurrentContext();
        filter.prepare(threadContext.getLocale());
        manip.filter(filter,  pageContext);
    }

    /**
     * Sets the title row needed for this page
     * @param titleIn the title row..
     */
    public void setTitle(String titleIn) {
        title = titleIn;
    }

    /**
     * Get current page row count
     * @return number of rows on current page
     */
    public int getPageRowCount() {
        int retval = pageData == null ? 0 : pageData.size();
        return retval;
    }

    /**
     * Sets the name of the dataset to use Tries to locate the list in the
     * following order: page context, request attribute, session attribute
     *
     * @param nameIn name of dataset
     * @throws JspException indicates something went wrong
     */
    public void setDataset(String nameIn) throws JspException {
        dataSetName = nameIn;
        Object d = pageContext.getAttribute(nameIn);
        if (d == null) {
            d = pageContext.getRequest().getAttribute(nameIn);
        }
        if (d == null) {
            HttpServletRequest request = (HttpServletRequest) pageContext
                    .getRequest();
            d = request.getSession(true).getAttribute(nameIn);
        }
        if (d != null) {
            if (d instanceof List) {
                pageData = (List) d;
            }
            else {
                throw new JspException("Dataset named \'" + nameIn +
                         "\' is incompatible." +
                         " Must be an an instance of java.util.List.");
            }
        }
        else {
            pageData = Collections.EMPTY_LIST;
        }
    }

    /**
     * The current object being displayed
     * @return current object being displayed
     */
    public Object getCurrentObject() {
        return currentObject;
    }

    /**
     * The parent if this list is dealing with expandable objects
     * @return the parent of the current object being displayed
     */
    public Object getParentObject() {
        return parentObject;
    }

    /**
     * Name used to store the currentObject in the page
     * @param nameIn row name
     * @throws JspException if row name is empty
     */
    public void setRowname(String nameIn) throws JspException {
        if (rowName == null || rowName.length() == 0) {
            throw new JspException("Row name cannot be empty");
        }
        rowName = nameIn;
    }

    /**
     * ${@inheritDoc}
     */
    @Override
    public int doEndTag() throws JspException {
        // print the hidden fields after the list widget is printed
        // but before the form of the listset is closed.
        ListTagUtil.write(pageContext, String.format(HIDDEN_TEXT,
                ListTagUtil.makeFilterSearchParentLabel(uniqueName),
                searchParent));
        ListTagUtil.write(pageContext,
                String.format(HIDDEN_TEXT,
                        ListTagUtil.makeFilterSearchChildLabel(uniqueName),
                        searchChild));
        ListTagUtil.write(pageContext, String.format(HIDDEN_TEXT,
                ListTagUtil.makeParentIsAnElementLabel(uniqueName),
                parentIsElement));

        // here decorators should insert other e.g hidden input fields
        for (ListDecorator dec : getDecorators()) {
            dec.setCurrentList(this);
            dec.afterList();
        }

        ListTagUtil.write(pageContext, "<!-- END " + getUniqueName() + " -->");
        release();
        return BodyTagSupport.EVAL_PAGE;
    }

    /**
     * ${@inheritDoc}
     */
    @Override
    public int doAfterBody() throws JspException {
        int retval = BodyTagSupport.EVAL_BODY_AGAIN;

        ListCommand cmd = ListTagUtil.getCurrentCommand(this, pageContext);

        if (cmd.equals(ListCommand.COL_HEADER)) {
            ListTagUtil.write(pageContext, "</tr>");
        }

        setState();

        if (haveColsEnumerated && !haveTblHeadingRendered) {
            ListTagUtil.setCurrentCommand(pageContext, getUniqueName(),
                    ListCommand.TBL_HEADING);
        }
        else if (haveColsEnumerated && !haveTblAddonsRendered) {

            setupManipulator();
            manip.sort();
            pageData = manip.getPage();

            StringWriter topAlphaBarContent = new StringWriter();
            StringWriter topPaginationContent = new StringWriter();
            StringWriter topAddonsContent = new StringWriter();
            StringWriter topExtraContent = new StringWriter();

            pageContext.pushBody(topAlphaBarContent);
            if (!manip.isListEmpty() && !StringUtils.isBlank(alphaBarColumn)) {
                AlphaBarHelper.getInstance().writeAlphaBar(pageContext,
                        manip.getAlphaBarIndex(), getUniqueName());
            }
            pageContext.popBody();

            pageContext.pushBody(topPaginationContent);
            if (!isEmpty()) {
                for (ListDecorator dec : getDecorators()) {
                    dec.setCurrentList(this);
                    dec.beforeTopPagination();
                }
            }
            renderTopPaginationControls();
            pageContext.popBody();

            pageContext.pushBody(topAddonsContent);
            if (!isEmpty()) {
                for (ListDecorator dec : getDecorators()) {
                    dec.setCurrentList(this);
                    dec.onTopExtraAddons();
                }
            }
            pageContext.popBody();

            int topContentLength = topAddonsContent.getBuffer().length() +
                    topAlphaBarContent.getBuffer().length() +
                    topPaginationContent.getBuffer().length() +
                    topExtraContent.getBuffer().length();

            if (topContentLength > 0) {
                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-top-addons\">");
                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-alphabar\">");
                ListTagUtil.write(pageContext, topAlphaBarContent.toString());
                ListTagUtil.write(pageContext, "</div>");
                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-pagination\">");
                ListTagUtil.write(pageContext, topPaginationContent.toString());
                ListTagUtil.write(pageContext, "</div>");
                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-top-addons-extra\">");
                ListTagUtil.write(pageContext, topAddonsContent.toString());
                ListTagUtil.write(pageContext, "</div>");
                ListTagUtil.write(pageContext, "</div>");
                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-top-extra\">");
                ListTagUtil.write(pageContext, "</div>");
            }

            ListTagUtil.write(pageContext, "<div class=\"panel panel-default\">");
            // as the header addons is populated with decorators, we don't
            // know if there will be content or not, but we want to avoid
            // writing the head tag at all if there is none, so we push a
            // buffer into the stack, and empty it later.
            StringWriter headAddons = new StringWriter();
            StringWriter headFilterContent = new StringWriter();
            StringWriter headExtraContent = new StringWriter();

            pageContext.pushBody(headAddons);
            if (!isEmpty()) {
                for (ListDecorator dec : getDecorators()) {
                    dec.setCurrentList(this);
                    dec.onHeadExtraAddons();
                }
            }
            pageContext.popBody();

            pageContext.pushBody(headFilterContent);
            if (filter != null && manip.getUnfilteredDataSize() !=  0) {
                ListTagUtil.renderFilterUI(pageContext, filter,
                            getUniqueName(), width, columnCount,
                            searchParent, searchChild);
            }
            pageContext.popBody();

            pageContext.pushBody(headExtraContent);
            if (!isEmpty()) {
                for (ListDecorator dec : getDecorators()) {
                    dec.setCurrentList(this);
                    dec.onHeadExtraContent();
                }
            }
            pageContext.popBody();

            int headContentLength = headFilterContent.getBuffer().length() +
                    headAddons.getBuffer().length() +
                    headExtraContent.getBuffer().length();
            if (!StringUtils.isBlank(title)) {
                headContentLength += title.length();
            }

            // this avoid render the row is there is no content at all
            if (headContentLength > 0) {
                ListTagUtil.write(pageContext, "<div class=\"panel-heading\">");
             // only if there is a title, add a panel-heading
                if (!StringUtils.isBlank(title)) {
                    HtmlTag h3 = new HtmlTag("h3");
                    h3.setAttribute("class", "panel-title");
                    h3.addBody(title);
                    ListTagUtil.write(pageContext, h3.render());
                }
                // render the navigation and filters as a row of the header

                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-head-addons\">");

                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-filter\">");
                ListTagUtil.write(pageContext, headFilterContent.toString());
                ListTagUtil.write(pageContext, "</div>");
                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-head-addons-extra\">");
                ListTagUtil.write(pageContext, headAddons.toString());
                ListTagUtil.write(pageContext, "</div>");

                ListTagUtil.write(pageContext, "</div>");

                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-head-extra\">");
                ListTagUtil.write(pageContext, headExtraContent.toString());
                ListTagUtil.write(pageContext, "</div>");
                // close the panel heading
                ListTagUtil.write(pageContext, "</div>");
            }

            HttpServletRequest request = (HttpServletRequest) pageContext
                    .getRequest();
            manip.bindPaginationInfo();
            request.setAttribute("dataSize", String
                   .valueOf(pageData.size() + 1));
            ListTagUtil.setCurrentCommand(pageContext, getUniqueName(),
                ListCommand.TBL_ADDONS);
            if (pageData != null && pageData.size() > 0) {
                iterator = pageData.iterator();
            }
            else {
                iterator = null;
            }
        }
        if (haveColsEnumerated && haveTblAddonsRendered &&
                            !haveColHeadersRendered) {

            startTable();
            ListTagUtil.write(pageContext, "<thead>");
            // open the row tag for the column header th's
            ListTagUtil.write(pageContext, "<tr>");
            ListTagUtil.setCurrentCommand(pageContext, getUniqueName(),
                    ListCommand.COL_HEADER);

        }
        if (haveColHeadersRendered && !haveTblFootersRendered) {
            ListTagUtil.write(pageContext, "</tr>");
            ListTagUtil.write(pageContext, "</thead>");

            if (manip.isListEmpty()) {
                renderEmptyList();
                ListTagUtil.write(pageContext, "</table>");
                // close panel
                ListTagUtil.write(pageContext, "</div>");
                // close list
                ListTagUtil.write(pageContext, "</div>");

                return BodyTagSupport.SKIP_BODY;
            }
            ListTagUtil.setCurrentCommand(pageContext, getUniqueName(),
                    ListCommand.RENDER);
            if (iterator.hasNext()) {
                Object obj = iterator.next();
                if (RhnListTagFunctions.isExpandable(obj)) {
                    parentObject = obj;
                }
                currentObject = obj;
            }
            else {
                currentObject = null;
            }
            if (currentObject == null) {
                ListTagUtil.write(pageContext, "</tbody>");
                ListTagUtil.setCurrentCommand(pageContext, getUniqueName(),
                        ListCommand.TBL_FOOTER);
            }
            else {
                ListTagUtil.write(pageContext, "<tr");
                renderRowClassAndId();

                ListTagUtil.write(pageContext, ">");
                pageContext.setAttribute(rowName, currentObject);
            }
        }
        else if (haveTblFootersRendered) {
            retval = BodyTagSupport.SKIP_BODY;

            ListTagUtil.write(pageContext, "</table>");
            // as the footer addons are populated with decorators, we don't
            // know if there will be content or not, but we want to avoid
            // writing the tfoot tag at all if there is none, so we push a
            // buffer into the stack, and empty it later.
            StringWriter footAddonsContent = new StringWriter();
            StringWriter footLinksContent = new StringWriter();
            StringWriter footExtraContent = new StringWriter();

            pageContext.pushBody(footAddonsContent);
            if (!manip.isListEmpty()) {
                for (ListDecorator dec : getDecorators()) {
                    dec.setCurrentList(this);
                    dec.onFooterExtraAddons();
                    dec.setCurrentList(null);
                }
            }
            pageContext.popBody();

            pageContext.pushBody(footExtraContent);
            if (!manip.isListEmpty()) {
                for (ListDecorator dec : getDecorators()) {
                    dec.setCurrentList(this);
                    dec.onFooterExtraContent();
                    dec.setCurrentList(null);
                }
            }
            pageContext.popBody();

            pageContext.pushBody(footLinksContent);
            // if there is reference links, put them as a panel footer
            if ((refLink != null) && (!isEmpty())) {

                ListTagUtil.write(pageContext, "<a href=\"" + refLink + "\" >");
                /* Here we render the reflink and its key. If the key hasn't been set
                 * we just display the link address itself.
                 */
                if (refLinkKey != null) {
                    Object[] args = new Object[2];
                    args[0] = new Integer(getPageRowCount());
                    args[1] = refLinkKeyArg0;
                    String message = LocalizationService.getInstance().
                        getMessage(refLinkKey, args);

                    ListTagUtil.write(pageContext, message);
                }
                else {
                    ListTagUtil.write(pageContext, refLink);
                }

                ListTagUtil.write(pageContext, "</a>");
            }
            pageContext.popBody();

            int footerContentLength = footLinksContent.getBuffer().length()
                    + footAddonsContent.getBuffer().length()
                    + footExtraContent.getBuffer().length();

            if (footerContentLength > 0) {
                ListTagUtil.write(pageContext, "<div class=\"panel-footer\">");
                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-footer-addons\">");
                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-reflinks\">");
                ListTagUtil.write(pageContext, footLinksContent.toString());
                ListTagUtil.write(pageContext, "</div>");
                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-footer-addons-extra\">");
                ListTagUtil.write(pageContext, footAddonsContent.toString());
                ListTagUtil.write(pageContext, "</div>");
                ListTagUtil.write(pageContext, "</div>");
                ListTagUtil.write(pageContext,
                        "<div class=\"spacewalk-list-footer-extra\">");
                ListTagUtil.write(pageContext, footExtraContent.toString());
                ListTagUtil.write(pageContext, "</div>");
                // closes the panel footer
                ListTagUtil.write(pageContext, "</div>");
            }

            // close the panel
            ListTagUtil.write(pageContext, "</div>");

            ListTagUtil.write(pageContext,
                    "<div class=\"spacewalk-list-bottom-addons\">");
            renderFooterPaginationControls();
            ListTagUtil.write(pageContext,
                    "<div class=\"spacewalk-list-bottom-addons-extra\">");
            if (!isEmpty()) {
                for (ListDecorator dec : getDecorators()) {
                    dec.setCurrentList(this);
                    dec.onBottomExtraAddons();
                }
            }
            ListTagUtil.write(pageContext, "</div>");
            ListTagUtil.write(pageContext, "</div>");
            ListTagUtil.write(pageContext,
                    "<div class=\"spacewalk-list-bottom-addons-extra\">");
            if (!isEmpty()) {
                for (ListDecorator dec : getDecorators()) {
                    dec.setCurrentList(this);
                    dec.onBottomExtraContent();;
                }
            }
            ListTagUtil.write(pageContext, "</div>");
            // we render the hidden fields outside of the table
            if (isSortable()) {
                renderSortableHiddenFields();
            }
        }
        return retval;
    }

    private void renderSortableHiddenFields() throws JspException {
        String sortByLabel = ListTagUtil.makeSortByLabel(getUniqueName());
        String sortDirLabel = ListTagUtil.makeSortDirLabel(getUniqueName());

        HtmlTag sortByInputTag = new HtmlTag("input");
        sortByInputTag.setAttribute("type", "hidden");
        sortByInputTag.setAttribute("name", sortByLabel);
        sortByInputTag.setAttribute("id",
                ListTagUtil.makeSortById(getUniqueName()));
        sortByInputTag.setAttribute("value", StringUtils.defaultString(
                pageContext.getRequest().getParameter(sortByLabel)));

        HtmlTag sortByDirTag = new HtmlTag("input");
        sortByDirTag.setAttribute("type", "hidden");
        sortByDirTag.setAttribute("name", sortDirLabel);
        sortByDirTag.setAttribute("id", ListTagUtil.
                                        makeSortDirId(getUniqueName()));
        sortByDirTag.setAttribute("value", StringUtils.defaultString(
                pageContext.getRequest().getParameter(sortDirLabel)));

        ListTagUtil.write(pageContext, sortByInputTag.render());
        ListTagUtil.write(pageContext, sortByDirTag.render());
    }

    private void setupPageData() throws JspException {
        Object d = pageContext.getAttribute(dataSetName);
        if (d == null) {
            d = pageContext.getRequest().getAttribute(dataSetName);
        }
        if (d == null) {
            HttpServletRequest request = (HttpServletRequest) pageContext
                    .getRequest();
            d = request.getSession(true).getAttribute(dataSetName);
        }
        if (d != null) {
            if (d instanceof List) {
                pageData = (List) d;
            }
            else {
                throw new JspException("Dataset named \'" + dataSetName +
                         "\' is incompatible." +
                         " Must be an an instance of java.util.List.");
            }
        }
        else {
            pageData = Collections.EMPTY_LIST;
        }
    }
    /**
     * ${@inheritDoc}
     */
    @Override
    public int doStartTag() throws JspException {
        verifyEnvironment();
        addDecorator(decoratorName);
        setupPageData();
        setPageSize();
        manip = new DataSetManipulator(pageSize, pageData,
                (HttpServletRequest) pageContext.getRequest(),
                getUniqueName(), isParentAnElement(), searchParent, searchChild);

        ListTagUtil.write(pageContext, "<!-- START LIST " + getUniqueName() + " -->");

        String listId = (getStyleId() != null) ? getStyleId() : getUniqueName();
        ListTagUtil.setCurrentCommand(pageContext, getUniqueName(),
                ListCommand.ENUMERATE);

        for (ListDecorator dec : getDecorators()) {
            dec.setCurrentList(this);
            dec.beforeList();
        }

        ListTagUtil.write(pageContext, "<div class=\"spacewalk-list");
        if (styleClass != null) {
            ListTagUtil.write(pageContext, " " + styleClass);
        }
        ListTagUtil.write(pageContext, "\" id=\"" + listId + "\">");
        return BodyTagSupport.EVAL_BODY_INCLUDE;
    }

    private void setupManipulator() throws JspException {
        manip.setAlphaColumn(alphaBarColumn);
        manip.filter(filter, pageContext);
        if (!StringUtils.isBlank(ListTagHelper.
                getFilterValue(pageContext.getRequest(), uniqueName))) {
            LocalizationService ls = LocalizationService.getInstance();

            ListTagUtil.write(pageContext, "<div class=\"site-info\">");

            if (manip.getTotalDataSetSize() != manip.getUnfilteredDataSize()) {
                if (manip.getAllData().size() == 0) {
                    ListTagUtil.write(pageContext, ls.getMessage(
                            "listtag.filteredmessageempty",
                            new Integer(manip.getTotalDataSetSize())));
                }
                else {
                    ListTagUtil.write(pageContext,
                                        ls.getMessage("listtag.filteredmessage",
                            new Integer(manip.getTotalDataSetSize())));
                }

                ListTagUtil.write(pageContext, "<br /><a href=\"");
                List<String> excludeParams = new ArrayList<String>();
                excludeParams.add(ListTagUtil.makeSelectActionName(getUniqueName()));
                excludeParams.add(ListTagUtil.makeFilterByLabel(getUniqueName()));
                excludeParams.add(ListTagUtil.makeFilterValueByLabel(getUniqueName()));
                excludeParams.add(ListTagUtil.makeOldFilterValueByLabel(getUniqueName()));
                excludeParams.add(ListTagUtil.makeFilterSearchChildLabel(getUniqueName()));
                excludeParams.add(ListTagUtil.
                        makeFilterSearchParentLabel(getUniqueName()));
                excludeParams.add(ListTagUtil.
                        makeParentIsAnElementLabel(getUniqueName()));
                excludeParams.add("submitted");

                ListTagUtil.write(pageContext,
                        ListTagUtil.makeParamsLink(pageContext.getRequest(), name,
                                Collections.EMPTY_MAP, excludeParams));

                ListTagUtil.write(pageContext, "\">" +
                                            ls.getMessage("listtag.clearfilter"));
                ListTagUtil.write(pageContext, ls.getMessage("listtag.seeall",
                        new Integer(manip.getUnfilteredDataSize())));
                ListTagUtil.write(pageContext, "</a>");
            }
            else {
                ListTagUtil.write(pageContext, ls.getMessage(
                         "listtag.all_items_in_filter",
                          ListTagHelper.getFilterValue(pageContext.getRequest(),
                                                uniqueName)));
            }

            ListTagUtil.write(pageContext, "</div>");
        }
    }

    /**
     * ${@inheritDoc}
     */
    @Override
    public void release() {
        if (pageContext.getAttribute("current") != null) {
            pageContext.removeAttribute("current");
        }
        dataSetName = ListHelper.DATA_SET;
        name = ListHelper.LIST;
        uniqueName = null;
        pageData = null;
        iterator = null;
        currentObject = null;
        parentObject = null;
        styleClass = "list";
        styleId = null;
        rowCounter = -1;
        setRowRenderer(null);
        width = null;
        columnCount = 0;
        pageSize = -1;
        rowName = "current";
        filter = null;
        haveColsEnumerated = false;
        haveColHeadersRendered = false;
        haveTblAddonsRendered = false;
        haveTblFootersRendered = false;
        getDecorators().clear();
        decorators = null;
        decoratorName = null;
        title = null;
        sortable = false;
        parentIsElement = true;
        searchParent = true;
        searchChild = false;
        super.release();
    }

    private void renderEmptyList() throws JspException {
        ListTagUtil.write(pageContext, "<tbody>");
        ListTagUtil.write(pageContext, "<tr><td ");
        ListTagUtil.write(pageContext, "colspan=\"");
        ListTagUtil.write(pageContext, String.valueOf(columnCount));
        ListTagUtil.write(pageContext, "\">");

        if (emptyKey != null) {
            LocalizationService ls = LocalizationService.getInstance();
            String msg = ls.getMessage(emptyKey);
            ListTagUtil
                    .write(pageContext, "<div class=\"list-empty-message\">");
            ListTagUtil.write(pageContext, msg);
            ListTagUtil.write(pageContext, "</div>");
        }

        ListTagUtil.write(pageContext, "</td></tr>");
        ListTagUtil.write(pageContext, "</tbody>");
    }

    private void renderRowClassAndId() throws JspException {
        rowCounter++;

        ListTagUtil.write(pageContext, " class=\"");
        ListTagUtil.write(pageContext, getRowRenderer().getRowClass(getCurrentObject()));
        if (rowCounter == manip.findAlphaPosition() % pageSize) {
            ListTagUtil.write(pageContext, " alphaResult");
        }
        ListTagUtil.write(pageContext, "\" ");
        if (getCurrentObject() != null) { //if we're rendering a non-item row (e.g. reflink)
            ListTagUtil.write(pageContext, "id=\"");
            ListTagUtil.write(pageContext, getRowRenderer().getRowId(getUniqueName(),
                                                                    getCurrentObject()));
            ListTagUtil.write(pageContext, "\" ");
            String style = getRowRenderer().getRowStyle(getCurrentObject());
            if (!StringUtils.isBlank(style)) {
                ListTagUtil.write(pageContext, "style=\"");
                ListTagUtil.write(pageContext, style);
                ListTagUtil.write(pageContext, "\" ");
            }
        }
    }

    private void startTable() throws JspException {
        ListTagUtil.write(pageContext, "<table class=\"table table-striped\"");

        if (width != null) {
            ListTagUtil.write(pageContext, " width=\"");
            ListTagUtil.write(pageContext, width);
            ListTagUtil.write(pageContext, "\"");
        }
        ListTagUtil.write(pageContext, ">");
    }

    private void setState() {
        ListCommand cmd = ListTagUtil.getCurrentCommand(this, pageContext);
        if (cmd.equals(ListCommand.ENUMERATE)) {
            haveColsEnumerated = true;
        }
        else if (cmd.equals(ListCommand.TBL_HEADING)) {
            haveTblHeadingRendered = true;
        }
        else if (cmd.equals(ListCommand.TBL_ADDONS)) {
            haveTblAddonsRendered = true;
        }
        else if (cmd.equals(ListCommand.COL_HEADER)) {
            haveColHeadersRendered = true;
        }
        else if (cmd.equals(ListCommand.TBL_FOOTER)) {
            haveTblFootersRendered = true;
        }
    }

    private void renderFooterPaginationControls() throws JspException {

        if (isEmpty() || hidePageNums) {
            return;
        }

        ListTagUtil.write(pageContext,
                "<div class=\"spacewalk-list-pagination\">");
        if (!isEmpty() && !hidePageNums) {
            ListTagUtil.write(pageContext, manip.getPaginationMessage());
        }

        if (!manip.isListEmpty()) {
            for (ListDecorator dec : getDecorators()) {
                dec.setCurrentList(this);
                dec.afterBottomPagination();
                dec.setCurrentList(null);
            }
        }

        ListTagUtil.renderPaginationLinks(pageContext, PAGINATION_NAMES,
                manip.getPaginationLinks());
        ListTagUtil.write(pageContext, "</div>");
    }


    private void renderTopPaginationControls() throws JspException {
        if (!isEmpty() && !hidePageNums) {
            ListTagUtil.write(pageContext, manip.getPaginationMessage());
        }

        if (!manip.isListEmpty()) {
            for (ListDecorator dec : getDecorators()) {
                dec.afterTopPagination();
            }
        }

        ListTagUtil.renderPaginationLinks(pageContext, PAGINATION_NAMES,
                manip.getPaginationLinks());
    }

    private void setPageSize() {
        int tmp = -1;
        RequestContext rctx = new RequestContext(
                (HttpServletRequest) pageContext.getRequest());
        User user = rctx.getLoggedInUser();
        if (user != null) {
            tmp = user.getPageSize();
            if (tmp > 0) {
                pageSize = tmp;
            }
        }
        if (pageSize < 1) {
            pageSize = 10;
        }


        HttpServletRequest httpRequest = (HttpServletRequest)
            pageContext.getRequest();

        if (PageSizeDecorator.pageWidgetSelected(httpRequest, getUniqueName())) {
            int size = PageSizeDecorator.getSelectedPageSize(httpRequest,
                                                        getUniqueName());
            List <Integer> pageSizes = PageSizeDecorator.getPageSizes();
            if (size < 1 || size > pageSizes.get(pageSizes.size() - 1)) {
                return;
            }
            pageSize = size;

        }
    }

    private void verifyEnvironment() throws JspException {
        if (BodyTagSupport.findAncestorWithClass(this, ListSetTag.class) == null) {
            throw new JspException("List must be enclosed by a ListSetTag");
        }
    }

    /**
     *
     * @return returns the page context
     */
    public PageContext getContext() {
        return pageContext;
    }

    /**
     * @return Returns the manip.
     */
    public DataSetManipulator getManip() {
        return manip;
    }


    /**
     * @param alphaBarColumnIn The alphaBarColumn to set.
     */
    public void setAlphabarcolumn(String alphaBarColumnIn) {
        this.alphaBarColumn = alphaBarColumnIn;
    }


    /**
     * provides the current page size
     * @return the page size
     */
    public int getPageSize() {
        return pageSize;
    }


    /**
     * @return Returns the alphaBarColumn.
     */
    public String getAlphaBarColumn() {
        return alphaBarColumn;
    }

    /**
     * if set to true, the page numbers at the top and bottom of the list will not
     *      be displayed
     * @param value true or false
     */
    public void setHidepagenums(String value) {
        hidePageNums = ListTagUtil.toBoolean(value);
    }

    /**
     * if set to true, the parent in a tree setup will
     * be considered as an element by itself
     * @param value true or false
     */
    public void setParentiselement(String value) {
        parentIsElement = ListTagUtil.toBoolean(value);
    }

    /**
     * if set to true, the parent in a tree setup will
     * be considered as an element by itself
     * @return true if the parent itself is an element
     */
    public boolean isParentAnElement() {
        return parentIsElement;
    }


    /**
     *
     * @return CSS ID for <table>
     */
    public String getStyleId() {
        if (StringUtils.isBlank(styleId)) {
            styleId = "list_" + getUniqueName() + "style_id";
        }
        return styleId;
    }


    /**
     *
     * @param styleIdIn CSS ID to set for HTML table tag
     */
    public void setStyleId(String styleIdIn) {
        this.styleId = styleIdIn;
    }

    /**
     *
     * @return the optional reference link that will be included in the last row
     * of the table
     */
    public String getRefLink() {
        return refLink;
    }

    /**
     *
     * @param refLinkIn the optional reference link that will be added to the last row
     * of the table
     */
    public void setReflink(String refLinkIn) {
        this.refLink = refLinkIn;
    }

    /**
     *
     * @return the key for the reference link
     */
    public String getRefLinkKey() {
        return refLinkKey;
    }

    /**
     *
     * @param refLinkKeyIn the key for the reference link
     */
    public void setReflinkkey(String refLinkKeyIn) {
        this.refLinkKey = refLinkKeyIn;
    }

    /**
     *
     * @return the optional argument that may be included in the reference link
     */
    public String getRefLinkKeyArg0() {
        return refLinkKeyArg0;
    }

    /**
     *
     * @param refLinkKeyArg0In the optional argument that may be included in the
     * reference link
     */
    public void setReflinkkeyarg0(String refLinkKeyArg0In) {
        this.refLinkKeyArg0 = refLinkKeyArg0In;
    }
}
