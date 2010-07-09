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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.ServletUtils;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.commons.lang.StringUtils;

import java.io.IOException;
import java.util.Map;
import java.util.TreeMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.Tag;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * The ColumnTag represents a column of data in a ListView.  It must be used
 * within a
 * {@link com.redhat.rhn.frontend.taglibs.ListDisplayTag ListDisplayTag}.
 * It will setup the title of the column using the header attribute, and
 * display the body after it has setup the header.
 * The column has six main attributes:
 * <code>header</code>, <code>style</code>, <code>cssClass</code>,
 * <code>url</code>, <code>width</code> and <code>renderUrl</code>.
 * <p>
 * The <code>header</code> is a <strong>REQUIRED</strong> attribute.
 * All other attributes are optional.
 * <p>
 * You can specify html formatting with the <code>style</code>,
 * <code>cssClass</code>, <code>nowrap</code> and <code>width</code> attributes.
 * <p>
 * Example usage of the ColumnTag:
 * <pre>
 * &lt;rhn:column header="l10n.jsp.message"
 *                "text-align: center;
 *                nowrap="true"
 *                url="someurl?id=${current.id}"&gt;
 *     ${current.name}
 * &lt;/rhn:column&gt;
 * </pre>
 * The <code>renderUrl</code> is a boolean which allows you to turn off the url
 * rendering based on some calculated value.  This is useful when you want
 * the column to show a url for all content except a particular condition.
 * Below is an example usage of this boolean and the sample output.
 * Assuming ${current.id} is equal to zero (0) the url will render.
 * <pre>
 * &lt;rhn:column header="l10n.jsp.message"
 *                url="http://www.somesite.com"
 *                renderUrl="${current.id == 0}" &gt;
 *     sometext
 * &lt;/rhn:column&gt;
 * </pre>
 * Sample output:
 * <pre>
 * ...
 * &lt;a href="http://www.somesite.com"&gt;sometext&lt;/a&gt;
 * ...
 * </pre>
 * Otherwise, you simply get sometext.
 * @version $Rev$
 * @see com.redhat.rhn.frontend.taglibs.ListTag
 * @see com.redhat.rhn.frontend.taglibs.ListDisplayTag
 * @see com.redhat.rhn.frontend.taglibs.SetTag
 */
public class ColumnTag extends TagSupport {

    public static final String DYNAMIC_HEADER = "dynamic";

    /** Localization key for header name */
    private String header;
    /** Localization param for header name */
    private String arg0;
    /** width of column */
    private String width;
    /** URL with which to surround the body */
    private String url;
    /** CSS class used for the column */
    private String cssClass;
    /** True-false String attribute indicating if or not to wrap the column value */
    private String nowrap;
    /** The TD tag which surrounds the column */
    private HtmlTag td;
    /** The a href tag which surrounds the column data when a url is supplied */
    private HtmlTag href;
    /** Property to sort the list based on */
    private String sortProperty;
    /** style **/
    private String style = "text-align: left;";
    /** header colspan attribute **/
    private String headerStyle;
    /**
     *  TODO: Eliminate this attribute. This is a dirty dirty
     *  hack to allow the ColumnTag to know whether to use
     *  UnpagedListDisplayTag as its parent or ListDisplayTag
     *  as its parent. When ListDisplayTag is refactored
     *  this attribute will no longer be needed**/
    private boolean usesRefactoredList = false;

    /**
     * Optional boolean which determines whether the URL should be rendered.
     * I know this seems odd, but sometimes we want the URL to be suppressed.
     */
    private boolean renderUrl;
    /** Set colspan attribute for this column,row */
    private String colspan;

    /**
     * Default constructor
     */
    public ColumnTag() {
        renderUrl = true;
    }

    /**
     * Copy constructor.
     * @param c ColumnTag to copy.
     */
    public ColumnTag(ColumnTag c) {
        header = c.getHeader();
        width = c.getWidth();
        style = c.getStyle();
        url = c.getUrl();
        cssClass = c.getCssClass();
        nowrap = c.getNowrap();
        renderUrl = c.isRenderUrl();
        arg0 = c.getArg0();
        style = c.getStyle();
        colspan = c.getColspan();
        usesRefactoredList = c.isUsesRefactoredList();
    }

    /**
     * {@inheritDoc}
     */
    public int doStartTag() throws JspException {
        td = new HtmlTag("td");
        href = new HtmlTag("a");

        try {
            JspWriter out = pageContext.getOut();

            if (usesRefactoredList) {
               UnpagedListDisplayTag parent = findUnpagedListDisplay();
               if (showHeader()) {
                   parent.incrNumberOfColumns();
                   renderHeader(out, header, arg0);
                   return SKIP_BODY;
               }
               renderData(out, parent);
            }
            else {
                ListDisplayTag parent = findListDisplay();
                if (showHeader()) {
                    parent.incrNumberOfColumns();
                    renderHeader(out, header, arg0);
                    return SKIP_BODY;
                }
                renderData(out, parent);
            }

            return EVAL_BODY_INCLUDE;
        }
        catch (IOException ioe) {
            throw new JspException("IO error writing to JSP file:", ioe);
        }
    }

    /**
     * Simple utility method to add an attribute to an HtmlTag.
     * If value is null, the attribute is removed from the HtmlTag.
     * @param tag HtmlTag to be affected.
     * @param name Attribute name.
     * @param value Attribute value.
     */
    private void setupAttribute(HtmlTag tag, String name, String value) {
        if (value != null) {
            tag.setAttribute(name, value);
        }
        else {
            tag.removeAttribute(name);
        }
    }

    /**
     * Displays the opening of the TD tag and prepares it for
     * displaying the body contents.
     * @param out JspWriter to write to.
     * @param parent Containing JspTag.
     * @throws IOException if an error occurs writing to the JspWriter.
     */
    protected void renderData(JspWriter out, ListDisplayTag parent)
        throws IOException {
        setupAttribute(td, "width", getWidth());

        if (getNowrap() != null && getNowrap().equals("true")) {
            setupAttribute(td, "nowrap", "nowrap");
        }

        setupAttribute(td, "style", getStyle());
        setupAttribute(td, "colspan", getColspan());

        if (getColspan() != null) {
            parent.setColumnCount(parent.getColumnCount() +
                                  Integer.parseInt(getColspan()) - 1);
        }

        // Only one column
        if (parent.getNumberOfColumns() == 1) {
            setupAttribute(td, "class", "first-column last-column");
        }
        // Are we the first column?
        else if (parent.getColumnCount() == 0) {
            setupAttribute(td, "class", "first-column");
        }
        // Are we the last column?
        else if (parent.getColumnCount() == parent.getNumberOfColumns() - 1) {
            setupAttribute(td, "class", "last-column");
        }
        // Are we a middle column?
        else {
            setupAttribute(td, "class", getCssClass());
        }

        parent.incrColumnCount();

        out.print(td.renderOpenTag());

        if (showUrl()) {
            setupAttribute(href, "href", getUrl());
            out.print(href.renderOpenTag());
        }
    }

    /**
     * Displays the opening of the TD tag and prepares it for
     * displaying the body contents.
     * @param out JspWriter to write to.
     * @param parent Containing JspTag.
     * @throws IOException if an error occurs writing to the JspWriter.
     */
    protected void renderData(JspWriter out, UnpagedListDisplayTag parent)
        throws IOException {
        String nodeIdString = parent.getNodeIdString();

        // Deal with structural markup before we get to this <td>
        if (parent.getColumnCount() == 0 && parent.getCurrRow() == 0) {
            out.println("</thead><tbody>");

        }
        setupAttribute(td, "width", getWidth());
        setupAttribute(td, "colspan", getColspan());
        if (getNowrap() != null && getNowrap().equals("true")) {
            setupAttribute(td, "nowrap", "nowrap");
        }

        // Only one column
        if (parent.getNumberOfColumns() == 1) {
            setupAttribute(td, "class", "first-column last-column");
        }
        // Are we the first column?
        else if (parent.getColumnCount() == 0) {
            setupAttribute(td, "class", "first-column");
        }
        // Are we the last column?
        else if (parent.getColumnCount() == parent.getNumberOfColumns() - 1) {
            setupAttribute(td, "class", "last-column");
        }
        // Are we a middle column?
        else {
            setupAttribute(td, "class", getCssClass());
        }

        parent.incrColumnCount();

        if (parent.getType().equals("treeview") && parent.isChild(nodeIdString)) {
            setupAttribute(td, "style", getStyle() + "display: none;");
        }
        else {
            setupAttribute(td, "style", getStyle());
        }

        out.print(td.renderOpenTag());

        if (parent.getType().equals("treeview") &&
                parent.isParent(nodeIdString) &&
                parent.getColumnCount() == 1) {
            out.print("<a onclick=\"toggleRowVisibility('" +
                      parent.createIdString(nodeIdString) +
                      "');\" " + "style=\"cursor: pointer;\">" +
                      "<img name=\"" +
                      parent.createIdString(nodeIdString) +
                      "-image\" src=\"/img/list-expand.gif\" alt=\"" +
                      LocalizationService.getInstance().
                      getMessage("channels.parentchannel.alt") +
                      "\"/></a>");
            parent.setCurrRow(parent.getCurrRow() + 1);
        }

        if (showUrl()) {
            setupAttribute(href, "href", getUrl());
            out.print(href.renderOpenTag());
        }
    }

    /**
     * Renders the header element of the table.
     * @param out JspWriter to write to.
     * @param hdr Header to display.
     * @param arg Single argument for header l10n.
     * @throws IOException
     */
    private void renderHeader(JspWriter out, String hdr, String arg) throws IOException {
        HtmlTag th = new HtmlTag("th");

        if (usesRefactoredList) {
            if (!StringUtils.isEmpty(findUnpagedListDisplay().getTitle())) {
                setupAttribute(th, "class", "row-2");
            }

            if (headerStyle != null) {
                setupAttribute(th, "style", headerStyle);
            }
            else {
               setupAttribute(th, "style", getStyle());
            }
        }
        else {
            if (!StringUtils.isEmpty(findListDisplay().getTitle())) {
                setupAttribute(th, "class", "row-2");

                if (headerStyle != null) {
                    setupAttribute(th, "style", headerStyle);
                }
                else {
                  setupAttribute(th, "style", getStyle());
                }
            }
        }

        th.addBody(renderHeaderData(hdr, arg));
        out.print(th.render());
    }

    protected String renderHeaderData(String hdr, String arg) {
        if (DYNAMIC_HEADER.equals(hdr)) {
            return arg;
        }

        String contents = null;
        if (arg != null) {
            contents = LocalizationService.getInstance().getMessage(hdr, arg);
        }
        else {
            contents = LocalizationService.getInstance().getMessage(hdr);
        }

        String retval = null;
        if (this.sortProperty != null) {
            HttpServletRequest request = (HttpServletRequest) pageContext.getRequest();
            String pageUrl;
            Map params = new TreeMap(request.getParameterMap());
            String sortOrder = request.getParameter(RequestContext.SORT_ORDER);

            if (RequestContext.SORT_ASC.equals(sortOrder)) {
                params.put(RequestContext.SORT_ORDER, RequestContext.SORT_DESC);
            }
            else {
                params.put(RequestContext.SORT_ORDER, RequestContext.SORT_ASC);
            }
            params.put(RequestContext.LIST_SORT, sortProperty);
            pageUrl = ServletUtils.pathWithParams("",
                    params);

            String title = LocalizationService.getInstance().
                getMessage("listdisplay.sortyby");
            retval = "<a title=\"" + title + "\" href=\"" + pageUrl + "\">" +
                contents + "</a>";
        }
        else {
            retval = contents;
        }

        return retval;
    }

    /**
     * Returns true if the header needs to be displayed.
     * @return true if the header needs to be displayed.
     */
    private boolean showHeader() {
        return (pageContext.getAttribute("current") == null);
    }

    /**
     * @return Returns the style
     */
    public String getStyle() {
        return style;
    }

    /**
     * Sets the style
     * @param styleIn Style to set
     */
    public void setStyle(String styleIn) {
        this.style = styleIn;
    }

    /**
     * Returns the header column name.
     * @return Returns the header.
     */
    public String getHeader() {
        return header;
    }
    /**
     * Sets the header column name.  Should be a localization key.
     * Optionally, you can pass in a value of "dynamic" in conjunction
     * with the arg0 attribute which will allow you to set a dynamic
     * header.
     * @param hdr The header to set.
     */
    public void setHeader(String hdr) {
        this.header = hdr;
    }
    /**
     * Returns the url.
     * @return Returns the url.
     */
    public String getUrl() {
        return url;
    }

    /**
     * The URL to render around the body. The following example,
     * <pre>
     *   <rhn:column header="foo" url="http://www.hostname.com">
     *      Data to show.
     *   </rhn:column>
     * </pre>
     * would result in the following HTML being generated:
     * <pre>
     *   <td>
     *     <a href="http://www.hostname.com">Data to show.</a>
     *   </td>
     * </pre>
     * @param urlIn The url to set.
     */
    public void setUrl(String urlIn) {
        this.url = urlIn;
    }

    /**
     * @return Returns the nowrap.
     */
    public String getNowrap() {
        return nowrap;
    }

    /**
     * @param noWrapIn The nowrap to set.
     */
    public void setNowrap(String noWrapIn) {
        this.nowrap = noWrapIn;
    }

    /**
     * Sets the CSS class attribute.
     * @param css CSS class attribute.
     */
    public void setCssClass(String css) {
        cssClass = css;
    }

    /**
     * Returns the CSS class attribute.
     * @return the CSS class attribute.
     */
    public String getCssClass() {
        return cssClass;
    }

    /**
     * Returns the column width.
     * @return the column width.
     */
    public String getWidth() {
        return width;
    }

    /**
     * Sets the column width in terms of pixels or percentage.
     * @param w The column width.
     */
    public void setWidth(String w) {
        this.width = w;
    }

    /**
     * Returns flag indicating whether the URL should be rendered.
     * @return flag indicating whether the URL should be rendered.
     */
    public boolean isRenderUrl() {
        return renderUrl;
    }
    /**
     * The flag indicating whether the URL should be rendered.
     * @param render flag indicating whether the URL should be rendered.
     */
    public void setRenderUrl(boolean render) {
        this.renderUrl = render;
    }

    /**
     * @return Returns the arg0.
     */
    public String getArg0() {
        return arg0;
    }
    /**
     * @param arg0In The arg0 to set.
     */
    public void setArg0(String arg0In) {
        this.arg0 = arg0In;
    }

    /**
     * @return Returns the sortProperty.
     */
    public String getSortProperty() {
        return sortProperty;
    }

    /**
     * @param sortPropertyIn The sortProperty to set.
     */
    public void setSortProperty(String sortPropertyIn) {
        this.sortProperty = sortPropertyIn;
    }

    /**
     * @return Returns the usesRefactoredList.
     */
    public boolean isUsesRefactoredList() {
        return usesRefactoredList;
    }

    /**
     * @param usesRefactoredListIn The usesRefactoredList to set.
     */
    public void setUsesRefactoredList(boolean usesRefactoredListIn) {
        this.usesRefactoredList = usesRefactoredListIn;
    }

    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        JspWriter out = null;
        try {
            out = pageContext.getOut();

            if (!showHeader()) {
                if (showUrl()) {
                    out.print(href.renderCloseTag());
                }
                out.print(td.renderCloseTag());
            }

            return Tag.EVAL_BODY_INCLUDE;
        }
        catch (IOException ioe) {
            throw new JspException("IO error writing to JSP file:", ioe);
        }
    }

    private boolean showUrl() {
        return ((getUrl() != null) && isRenderUrl());
    }

    /**
     * Returns the ListDisplayTag that serves as the parent tag.
     * Returns null if no ListDisplayTag is found.
     * @return the parent ListDisplayTag
     */
    public UnpagedListDisplayTag findUnpagedListDisplay() {
        Tag tagParent = getParent();
        while (tagParent != null && !(tagParent instanceof UnpagedListDisplayTag)) {
            tagParent = tagParent.getParent();
        }
        return (UnpagedListDisplayTag) tagParent;
    }

    /**
     * Returns the ListDisplayTag that serves as the parent tag.
     * Returns null if no ListDisplayTag is found.
     * @return the parent ListDisplayTag
     */
    public ListDisplayTag findListDisplay() {
        Tag tagParent = getParent();
        while (tagParent != null && !(tagParent instanceof ListDisplayTag)) {
            tagParent = tagParent.getParent();
        }
        return (ListDisplayTag) tagParent;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        // This method specifically does _NOT_ compare the url portion of
        // the ColumnTag when checking for equality.  Doing so does not work.
        // The problem is that each instance of the ColumnTag can have a
        // different URL, because parts of the URL are evaluated by JSTL.
        // Take this tag:
        //      <rhn:column header="assignedgroups.jsp.group"
        //                  style="text-align: center;
        //                  url="SystemGroupDetails.do?sgid=${current.id}">
        // The instance used for the header will have the URL
        //     SystemGroupDetails.do?sgid=
        // But every other instance will include an id in the URL.  We can't
        // check for obj.getUrl().startsWith(this.getUrl()), because that
        // breaks the rules for equals, naming obj.equals(this) must ==
        // this.equals(obj).  So, just remove that test and all works well.
        if (obj == null || !(obj instanceof ColumnTag)) {
            return false;
        }

        ColumnTag c = (ColumnTag) obj;

        if (header != null) {
            if (!header.equals(c.getHeader())) {
                return false;
            }
        }
        else if (c.getHeader() != null) {
            return false;
        }

        if (width != null) {
            if (!width.equals(c.getWidth())) {
                return false;
            }
        }
        else if (c.getWidth() != null) {
            return false;
        }

        if (style != null) {
            if (!style.equals(c.getStyle())) {
                return false;
            }
        }
        else if (c.getStyle() != null) {
            return false;
        }


        if (nowrap != null) {
            if (!nowrap.equals(c.getNowrap())) {
                return false;
            }
        }
        else if (c.getNowrap() != null) {
            return false;
        }

        if (cssClass != null) {
            if (!cssClass.equals(c.getCssClass())) {
                return false;
            }
        }
        else if (c.getCssClass() != null) {
            return false;
        }

        if (arg0 != null) {
            if (!arg0.equals(c.getArg0())) {
                return false;
            }
        }
        else if (c.getArg0() != null) {
            return false;
        }

        if (renderUrl != c.isRenderUrl()) {
            return false;
        }

        return true;
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        int result = 17;
        result = 37 * (header == null ? 0 : header.hashCode());
        result += 37 * (width == null ? 0 : width.hashCode());
        result += 37 * (style == null ? 0 : style.hashCode());
        result += 37 * (nowrap == null ? 0 : nowrap.hashCode());
        result += 37 * (cssClass == null ? 0 : cssClass.hashCode());
        result += 37 * (arg0 == null ? 0 : arg0.hashCode());
        return result;
    }

    /**
     * {@inheritDoc}
     */
    public void release() {
        header = null;
        arg0 = null;
        width = null;
        url = null;
        cssClass = null;
        nowrap = null;
        td = null;
        href = null;
        sortProperty = null;
        style = null;
        headerStyle = null;
        usesRefactoredList = false;
        super.release();
    }

    /**
     * @return Returns the headerStyle.
     */
    public String getHeaderStyle() {
        return headerStyle;
    }

    /**
     * @param headerStyleIn The headerStyle to set.
     */
    public void setHeaderStyle(String headerStyleIn) {
        this.headerStyle = headerStyleIn;
    }

    /**
     * @return Returns the colspan.
     */
    public String getColspan() {
        return colspan;
    }

    /**
     * @param colspanIn The colspan to set.
     */
    public void setColspan(String colspanIn) {
        this.colspan = colspanIn;
    }

}
