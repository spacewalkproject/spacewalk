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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.html.HtmlTag;

import org.apache.commons.lang.StringUtils;

import javax.servlet.ServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyTagSupport;
import javax.servlet.jsp.tagext.TagSupport;


/**
 * RadioTag
 * Implements a simple radio button collection useful with 
 * rl list tag.
 *  <%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
 *   <rl:radiocolumn value="${current.selectionKey}" styleclass="first-column"/>
 * @version $Rev$
 */
public class RadioColumnTag extends TagSupport {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -6357217946091510289L;
    private String styleClass;
    private String width;
    private String listName;
    private String valueExpr;
    private String headerStyle;
    private String headerKey;
    private boolean useDefault = true;

    /**
     * Sets the column width
     * @param widthIn column width
     */
    public void setWidth(String widthIn) {
        width = widthIn;
    }

    /**
     * Sets the header CSS style class
     * @param style CSS style class
     */
    public void setHeaderclass(String style) {
        headerStyle = style;
    }

    /**
     * Sets the header key
     * @param key the header key
     */
    public void setHeaderkey(String key) {
        headerKey = key;
    }
    
    /**
     * Sets the individual cells' CSS style class
     * @param style CSS style class
     */
    public void setStyleclass(String style) {
        styleClass = style;
    }
    
    /**
     * Sets the value for the cell
     * Should probably reference the ${current} variable in some way
     * @param valueIn  value for checkbox
     */
    public void setValue(String valueIn) {
        valueExpr = valueIn;
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public int doStartTag() throws JspException {
        
        ListCommand command = (ListCommand) 
            ListTagUtil.getCurrentCommand(this, pageContext);
        ListTag parent = (ListTag) BodyTagSupport.findAncestorWithClass(this, 
                ListTag.class);
        listName = parent.getUniqueName();
        int retval = BodyTagSupport.SKIP_BODY;

        if (command.equals(ListCommand.ENUMERATE)) {
            parent.addColumn();
            renderHiddenField();
            retval = BodyTagSupport.EVAL_PAGE;
        }
        else if (command.equals(ListCommand.COL_HEADER)) {
            renderHeader(parent);
            retval = BodyTagSupport.EVAL_PAGE;
        }        
        else if (command.equals(ListCommand.RENDER)) {
            render(valueExpr);
        }
        return retval;
    } 

    /**
     * {@inheritDoc}
     */
    @Override
    public int doEndTag() throws JspException {
        ListCommand command = (ListCommand) ListTagUtil.
                                            getCurrentCommand(this, pageContext);
        if (command.equals(ListCommand.RENDER)) {
            ListTagUtil.write(pageContext, "</td>");    
        }
        release();
        return BodyTagSupport.EVAL_PAGE;
    }
    
    private void render(String value) throws JspException {
        writeStartingTd();
        HtmlTag radio = new HtmlTag("input");
        radio.setAttribute("type", "radio");
        radio.setAttribute("name", getRadioName(listName));
        radio.setAttribute("value", value);
        if (StringUtils.isBlank(getRadioValue()) && useDefault) {
            pageContext.getRequest().setAttribute(getRadioName(listName), value);
        }
        if (isSelected()) {
            radio.setAttribute("checked", "checked");
        }
        ListTagUtil.write(pageContext, radio.render());
    }

    protected void writeStartingTd() throws JspException {
        SelectableColumnTag.writeStartingTd(pageContext, styleClass, width);
    }
    
    private boolean isSelected() {
        String value = getRadioValue();
        return valueExpr.equals(value);
    }
    
    private void renderHiddenField() throws JspException {
        HtmlTag hidden = new HtmlTag("input");
        hidden.setAttribute("type", "hidden");
        hidden.setAttribute("name", getRadioHidden(listName));
        hidden.setAttribute("value", getRadioValue());
        ListTagUtil.write(pageContext, hidden.render());
    }
  
    private void renderHeader(ListTag parent) throws JspException {
        if (!parent.isEmpty()) {
            ListTagUtil.write(pageContext, "<th");
            if (headerStyle != null) {
                ListTagUtil.write(pageContext, " class=\"");
                ListTagUtil.write(pageContext, headerStyle);
                ListTagUtil.write(pageContext, "\"");
            }
            ListTagUtil.write(pageContext, ">");
            if (!StringUtils.isBlank(headerKey)) {
                LocalizationService ls = LocalizationService.getInstance();
                ListTagUtil.write(pageContext, ls.getMessage(headerKey));
            }
            ListTagUtil.write(pageContext, "</th>");
        }
    }
    
    private static String getRadioName(String listName) {
        return String.format("list_%s_radio", listName);  
    }    
    
    private static String getRadioHidden(String listName) {
        return String.format("list_%s_hidden", listName);  
    }

    private static String getDefaultValueName(String listName) {
        return String.format("list_%s_default", listName);  
    }
    
    private String getRadioValue() {
        return getRadioValue(pageContext.getRequest(), listName);
    }
    
    static void bindDefaultValue(ServletRequest request, 
                                    String listName, String value) {
        request.setAttribute(getDefaultValueName(listName), value);
    }
    
    static String getRadioValue(ServletRequest request, String listName) {
        String value = (String)request.getAttribute(getRadioName(listName));
        if (StringUtils.isBlank(value)) {
            value = request.getParameter(getRadioName(listName));
            if (StringUtils.isBlank(value)) {
                value = request.getParameter(getRadioHidden(listName));
                if (StringUtils.isBlank(value)) {
                    value = (String)request.getAttribute(
                                                getDefaultValueName(listName));    
                }
            }            
        }
        request.setAttribute(getRadioName(listName), value);
        return value;
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public void release() {
        if (listName != null) {
            ListTagUtil.clearPersistentCounter(pageContext, listName);
        }
        listName = null;
        valueExpr = null;
        styleClass = null;
        width = "20px";
        headerStyle = null;
    }


    /**
     * @return Returns the setDefault.
     */
    public boolean isUseDefault() {
        return useDefault;
    }


    /**
     * @param setDefaultIn The setDefault to set.
     */
    public void setUseDefault(boolean setDefaultIn) {
        this.useDefault = setDefaultIn;
    }
}
