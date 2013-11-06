/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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
import java.util.Iterator;

import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyTagSupport;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.CSVWriter;
import com.redhat.rhn.common.util.ExportWriter;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.struts.RequestContext;

/**
 * Base class for ListDisplayTag implementation.
 *
 * @author bo
 */
public class ListDisplayTagBase extends BodyTagSupport {
    public static final String FILTER_DISPATCH = "filter.dispatch";

    /** iterates through the page list */
    private Iterator iterator;
    /** list of data to show on page */
    private DataResult pageList;
    /** How many columns are there? */
    private int numberOfColumns = 0;
    /** Which column are we rendering now? */
    private int columnCount = 0;
    private String filterBy;
    /** type of table we are using. default is list" */
    private String type = "list";
    /** determines whether we should show the disabled CSS */
    private boolean renderDisabled;
    /** comma separated list of columns to be exported */
    private String exportColumns;
    /** optional title attribute for displaying a titled list */
    private String title;
    private String hiddenvars;

    /** Public constructor */
    public ListDisplayTagBase() {

    }

    /**
     * @return returns the iterator of the data for this list
     */
    protected Iterator getIterator() {
        return iterator;
    }

    /**
     * @return returns the page list
     */
    protected DataResult getPageList() {
        return pageList;
    }

    /**
     * @return Returns the disabled.
     */
    public boolean renderDisabled() {
        return renderDisabled;
    }

    /**
     * @param disabled
     *            The disabled to set.
     */
    public void setRenderDisabled(String disabled) {
        renderDisabled = disabled.equals("true");
    }

    /**
     * Returns the title message key.
     *
     * @return Returns the title.
     */
    public String getTitle() {
        return title;
    }

    /**
     * Sets the title message key.
     *
     * @param titleIn
     *            The title to set.
     */
    public void setTitle(String titleIn) {
        title = titleIn;
    }

    /**
     * Sets the type of the list
     *
     * @param stringIn
     *            desired alignment for the list
     */
    public void setType(String stringIn) {
        type = stringIn;
    }

    /**
     * Gets the type of the list
     *
     * @return String alignment of the list
     */
    public String getType() {
        return type;
    }

    /**
     * Set the header of the filter on which to filter
     *
     * @param filterByIn
     *            The filterBy to set.
     */
    public void setFilterBy(String filterByIn) {
        this.filterBy = filterByIn;
    }

    /**
     * @return Returns the hiddenvars.
     */
    public String getHiddenvars() {
        return hiddenvars;
    }

    /**
     * @param hv
     *            The hiddenvars to set.
     */
    public void setHiddenvars(String hv) {
        this.hiddenvars = hv;
    }

    /**
     * Method to fetch a new ExportWriter instance. Override if desired to use
     * different instance. Currently creates a new CSVWriter instance.
     *
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
     * Get the number of the column that is being rendered at this moment. (0 ==
     * The first column)
     *
     * @return int the column number
     **/
    public int getColumnCount() {
        return this.columnCount;
    }

    /**
     * Get the number of columns in the list.
     *
     * @return int the number of columns
     **/
    public int getNumberOfColumns() {
        return this.numberOfColumns;
    }

    /**
     * Set the number of columns in the list.
     *
     * @param num
     *            number of columns i nthe list
     **/
    public void setNumberOfColumns(int num) {
        this.numberOfColumns = num;
    }

    /**
     * Set the column # that is being rendered at this moment
     *
     * Used when 'colspan' is used for an element to skip over the intervening
     * columns.
     *
     * @param columnCountIn
     *            The column count to set.
     **/
    public void setColumnCount(int columnCountIn) {
        this.columnCount = columnCountIn;
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

    protected void setupPageList() throws JspTagException {
        ListTag listTag = (ListTag) findAncestorWithClass(this, ListTag.class);
        if (listTag == null) {
            throw new JspTagException("Tag nesting error: " +
                    "listDisplay must be nested in a list tag");
        }
        pageList = listTag.getPageList();
        iterator = pageList.iterator();
    }

    protected void renderHeadExtraAddons(Writer out) throws IOException {
        // noop
    }

    protected void renderPanelHeading(JspWriter out) throws IOException {

        StringWriter headFilterContent = new StringWriter();
        StringWriter titleContent = new StringWriter();
        StringWriter headAddons = new StringWriter();

        renderTitle(titleContent);
        if (getPageList().hasFilter()) {
            headFilterContent.append("<div class=\"spacewalk-list-filter\">");
            renderFilterBox(headFilterContent);
            headFilterContent.append("</div>");
        }
        renderHeadExtraAddons(headAddons);

        int headContentLength = headFilterContent.getBuffer().length() +
                                titleContent.getBuffer().length() +
                                headAddons.getBuffer().length();

        if (headContentLength > 0) {
            out.println("<div class=\"panel-heading\">");
            out.println(titleContent.toString());
            out.println("<div class=\"spacewalk-list-head-addons\">");
            out.println(headFilterContent.toString());
            out.println("<div class=\"spacewalk-list-head-addons-extra\">");
            out.println(headAddons.toString());
            out.println("</div>");
            out.println("</div>");
            out.println("</div>");
        }
    }

    /**
     * Renders the title header if set.
     * @param out JspWriter
     * @throws IOException thrown if there's a problem writing to the JSP
     */
    protected void renderTitle(Writer out) throws IOException {
        if (!StringUtils.isEmpty(title)) {
            HtmlTag h4 = new HtmlTag("h4");
            h4.setAttribute("class", "panel-title");
            h4.addBody(LocalizationService.getInstance().getMessage(title));
            out.append(h4.render());
        }
    }

    protected void renderFilterBox(Writer out) throws IOException {
        LocalizationService ls = LocalizationService.getInstance();

        HtmlTag tag = new HtmlTag("div");
        tag.setAttribute("class", "spacewalk-filter-input input-group");

        StringBuffer buf = new StringBuffer();

        HtmlTag input = new HtmlTag("input");
        input.setAttribute("type", "text");
        input.setAttribute("class", "form-control");
        input.setAttribute("name", RequestContext.FILTER_STRING);
        input.setAttribute("value", pageList.getFilterData());
        String placeHolder = StringEscapeUtils.escapeHtml(
                ls.getMessage("message.filterby", ls.getMessage(filterBy)));
        input.setAttribute("placeholder", placeHolder);

        buf.append(input.render());

        input = new HtmlTag("input");
        input.setAttribute("type", "hidden");
        input.setAttribute("name", RequestContext.PREVIOUS_FILTER_STRING);
        input.setAttribute("value", pageList.getFilterData());
        buf.append(input.render());

        HtmlTag btnSpan = new HtmlTag("span");
        btnSpan.setAttribute("class", "input-group-btn");

        HtmlTag btn = new HtmlTag("button");
        btn.setAttribute("class", "btn btn-default");
        btn.setAttribute("type", "submit");
        btn.setAttribute("name", FILTER_DISPATCH);
        btn.setAttribute("value", ls.getMessage(RequestContext.FILTER_KEY));

        HtmlTag icon = new HtmlTag("i");
        icon.setAttribute("class", "fa fa-eye");
        icon.addBody(" ");
        btn.addBody(icon);

        btnSpan.addBody(btn);

        buf.append(btnSpan.render());

        tag.addBody(buf.toString());
        out.append(tag.render());
    }

    /** {@inheritDoc} */
    public void release() {
        iterator = null;
        filterBy = null;
        renderDisabled = false;
        exportColumns = null;
        title = null;
        columnCount = 0;
        numberOfColumns = 0;
        hiddenvars = null;
        pageList = null;
        type = "list";
        // now release our super classes
        super.release();
    }

}
