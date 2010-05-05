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
import com.redhat.rhn.frontend.struts.Expandable;
import com.redhat.rhn.frontend.taglibs.RhnListTagFunctions;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;

import org.apache.commons.lang.StringUtils;

import java.util.Map;

import javax.servlet.ServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.BodyTagSupport;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * Implements a simple selected checkbox like those used with RhnSets
 * 
 * @version $Rev $
 */
public class SelectableColumnTag extends TagSupport {
    
    private static final long serialVersionUID = 2749189931275777440L;
    private static final String CHECKBOX_CLICKED_SCRIPT = 
                    "%s(%s,'%s', document.getElementById('%s'), %s, %s, '%s', %s);";
    private static final String CLICKED_COMPLETE = "process_checkbox_clicked";
    private static final String CLICKED_CLIENT_SIDE = 
                                        "process_checkbox_clicked_client_side";
    
    private static final String CHECK_ALL_SCRIPT = "process_check_all('%s', %s, %s, %s);";
    private String valueExpr;
    private String selectExpr;
    private String disabledExpr;
    private String styleClass;
    private String width;
    private String headerStyle;
    private String headerKey;
    private String listName;
    private String rhnSet;

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
     * Expression to determine if a checkbox is selected
     * @param expr selected expression 
     */
    public void setSelected(String expr) {
        selectExpr = expr;
    }
    
    /**
     * Expression to determine if checkbox is disabled
     * @param expr disabled expression
     */
    public void setDisabled(String expr) {
        disabledExpr = expr;
    }
    
    /**
     * {@inheritDoc}
     */
    public int doStartTag() throws JspException {
        
        ListCommand command = (ListCommand) 
            ListTagUtil.getCurrentCommand(this, pageContext);
        ListTag parent = (ListTag) BodyTagSupport.findAncestorWithClass(this, 
                ListTag.class);
        listName = parent.getUniqueName();
        int retval = BodyTagSupport.SKIP_BODY;
        setupRhnSet();
        if (command.equals(ListCommand.ENUMERATE)) {
            parent.addColumn();
            retval = BodyTagSupport.EVAL_PAGE;
        }
        else if (command.equals(ListCommand.COL_HEADER)) {
            renderHeader(parent);
            retval = BodyTagSupport.EVAL_PAGE;
        }
        else if (command.equals(ListCommand.RENDER)) {
            renderCheckbox();
        }
        return retval;
    }    

    /**
     * {@inheritDoc}
     */
    public int doEndTag() throws JspException {
        ListCommand command = (ListCommand) ListTagUtil.
                                            getCurrentCommand(this, pageContext);
        if (command.equals(ListCommand.RENDER)) {
            ListTagUtil.write(pageContext, "</td>");    
        }
        release();
        return BodyTagSupport.EVAL_PAGE;
    }
    
    /**
     * {@inheritDoc}
     */    
    public void release() {
        if (listName != null) {
            ListTagUtil.clearPersistentCounter(pageContext, listName);
        }
        listName = null;
        valueExpr = null;
        selectExpr = null;
        disabledExpr = null;
        styleClass = null;
        width = "20px";
        headerStyle = null;
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
            if (StringUtils.isBlank(headerKey)) {
                renderOnClickForSelectAll();    
            }
            else {
                LocalizationService ls = LocalizationService.getInstance();
                ListTagUtil.write(pageContext, ls.getMessage(headerKey));
            }
            ListTagUtil.write(pageContext, "</th>");            
        }
    }

    private void setupRhnSet() {
        String decl = ListTagHelper.lookupSetDeclFor(listName, 
                                            pageContext.getRequest());
        if (!StringUtils.isBlank(decl)) {
            rhnSet =  decl;
        }
    }
    
    private void renderOnClickForSelectAll() throws JspException {
        ListTagUtil.write(pageContext, "<input type=\"checkbox\" ");
        ListTagUtil.write(pageContext, " name=\"");
        ListTagUtil.write(pageContext, makeSelectAllCheckboxName(listName));
        ListTagUtil.write(pageContext, "\" ");
        
        ListTagUtil.write(pageContext, " id=\"");
        ListTagUtil.write(pageContext, makeSelectAllCheckboxId(listName));
        ListTagUtil.write(pageContext, "\" ");        
        
        ListTagUtil.write(pageContext, "onclick=\"");
        String script =  String.format(CHECK_ALL_SCRIPT, 
                            StringUtils.defaultString(rhnSet), 
                            "this.form." +  ListTagUtil.
                                makeSelectedItemsName(listName), "this.checked",
                                getIgnorableParentIds());
        ListTagUtil.write(pageContext, script);
        ListTagUtil.write(pageContext, "\" />");
    }
    private void renderCheckbox() throws JspException {
        render(valueExpr);
    }
    
    private void render(String value) throws JspException {
        writeStartingTd();
        String id = ListTagHelper.getObjectId(getCurrent());
        String checkboxId = makeCheckboxId(listName, id);
        renderHiddenItem(id, value);
        ListTagUtil.write(pageContext, "<input type=\"checkbox\" ");
        boolean selected = isSelected(); 
        if (selected) {
            ListTagUtil.incrementPersistentCounter(pageContext, listName + "_selected");
            ListTagUtil.write(pageContext, "checked ");
        }
        if (isDisabled()) {
            ListTagUtil.write(pageContext, "disabled ");
        }
        ListTagUtil.write(pageContext, "id=\"");
        
        ListTagUtil.write(pageContext, checkboxId);
        
        
        String itemsName = ListTagUtil.makeSelectedItemsName(listName);
        ListTag parent = (ListTag)
                    BodyTagSupport.findAncestorWithClass(this, ListTag.class);
        if (!parent.isParentAnElement() &&
                    RhnListTagFunctions.isExpandable(getCurrent())) {
            itemsName = "parent_" + itemsName ;
        }   
        ListTagUtil.write(pageContext, "\" name=\"" + itemsName + "\" ");
        ListTagUtil.write(pageContext, "value=\"");
        ListTagUtil.write(pageContext, value);
        ListTagUtil.write(pageContext, "\" ");
        renderOnClick();

        ListTagUtil.write(pageContext, "/>");
        if (selected && !StringUtils.isBlank(rhnSet)) {
            String scriptId = "document.getElementById('" + checkboxId + "')";
            addPostScript(getOnClickScript(CLICKED_CLIENT_SIDE, scriptId), 
                                            listName, pageContext.getRequest());
        }
    }

    /**
     * Given list name returns the name of the select all box
     * @param listName the name of the list
     * @return the name of the select all check box
     */
    public static String makeSelectAllCheckboxName(String listName) {
        return "list_" + listName + "_sel_all";
    }    
    
    /**
     * Given list name returns the name of the select all box
     * @param listName the name of the list
     * @return the name of the select all check box
     */
    public static String makeSelectAllCheckboxId(String listName) {
        return "list_" + listName + "_sel_all_id";
    }
    /**
     * Given list name returns the name of a check box
     * @param listName the name of the id
     * @param id the object id of the check box value object
     * @return the checkbox id
     */
    public static String makeCheckboxId(String listName, String id) {
        return "list_" + listName + "_" + id;
    }    
    /**
     * renders
     * //onclick="checkbox_clicked(this, '$rhnSet')"
     *
     */
    private void renderOnClick() throws JspException {
        if (!StringUtils.isBlank(rhnSet)) {
            ListTagUtil.write(pageContext, " onclick=\"");
            ListTagUtil.write(pageContext, getOnClickScript(CLICKED_COMPLETE, "this"));
            ListTagUtil.write(pageContext, "\" ");
        }
    }

    /**
     * renders
     * //onclick="checkbox_clicked(this, '$rhnSet')"
     *
     */
    private String getOnClickScript(String funcName, String boxName) {
        Object current = getCurrent();
        Object parent = getParentObject();
        String childIds = "[]";
        String memberIds = "[]";
        String parentId = "";
        ListTag parentTag = (ListTag)
            BodyTagSupport.findAncestorWithClass(this, ListTag.class);
        
        if (RhnListTagFunctions.isExpandable(current)) {
            childIds = getChildIds(current);
        }
        else {
            parentId = getParentId(current, parent);
            memberIds = getMemberIds(current, parent);
        }

        return String.format(CHECKBOX_CLICKED_SCRIPT, funcName, boxName,
                            rhnSet,  makeSelectAllCheckboxId(listName), 
                            childIds, memberIds, parentId,
                            parentTag.isParentAnElement());

    }

    
    
    private String getParentId(Object current, Object parent) {
        if (parent != null && parent !=  current) {
            return makeCheckboxId(listName, ListTagHelper.getObjectId(parent));
        }
        return "";
    }

    private String getChildIds(Object parent) {
        if (RhnListTagFunctions.isExpandable(parent)) {
            StringBuilder buf = new StringBuilder();
            for (Object child : ((Expandable)parent).expand()) {
                if (buf.length() > 0) {
                    buf.append(",");
                }
                buf.append("'");
                buf.append(makeCheckboxId(listName, ListTagHelper.getObjectId(child)));
                buf.append("'");
            }
            
            buf.insert(0, "[");
            buf.append("]");
            
            return buf.toString();
        }
        return "[]";
        
    }

    private String getMemberIds(Object current, Object parent) {
        if (parent != null && parent != current) {
            return getChildIds(parent);
        }
        return "[]";
        
    }    
    
    
    private void renderHiddenItem(String listId, String value) throws JspException {
        ListTagUtil.write(pageContext, "<input type=\"hidden\" ");
        ListTagUtil.write(pageContext, "id=\"");
        ListTagUtil.write(pageContext, "list_items_" + listName + "_" + listId);
        String pageItems = ListTagUtil.makePageItemsName(listName);
        ListTag parent = (ListTag)
                    BodyTagSupport.findAncestorWithClass(this, ListTag.class);
        if (!parent.isParentAnElement() &&
                RhnListTagFunctions.isExpandable(getCurrent())) {
            pageItems = "parent_" + pageItems ;
        }
        ListTagUtil.write(pageContext, "\" name=\"" + pageItems + "\" ");
        ListTagUtil.write(pageContext, "value=\"");
        ListTagUtil.write(pageContext, value);
        ListTagUtil.write(pageContext, "\" />\n");        
    }
    
    private boolean isSelected() throws JspException {
        if (!StringUtils.isBlank(selectExpr)) {
            return selectExpr.equalsIgnoreCase("true");
        }     
        
        ListTag parent = (ListTag)BodyTagSupport.
                        findAncestorWithClass(this, ListTag.class);
        
        String selectionsKey = ListSessionSetHelper.makeSelectionsName(parent.getName());
        Map selections = (Map)pageContext.getRequest().getAttribute(selectionsKey);
         
        return selections != null && selections.containsKey(valueExpr);
    }
    
    private boolean isDisabled() throws JspException {
        if (disabledExpr != null && disabledExpr.equalsIgnoreCase("true")) {
            return true;
        }
        return false;
    }
    protected void writeStartingTd() throws JspException {
        writeStartingTd(pageContext, styleClass, width);
    }
    
    static void writeStartingTd(PageContext pageContext, 
                        String styleClass, String width) throws JspException {
        ListTagUtil.write(pageContext, "<td");
        if (!StringUtils.isBlank(styleClass)) {
            ListTagUtil.write(pageContext, " class=\"");
            ListTagUtil.write(pageContext, styleClass);
            ListTagUtil.write(pageContext, "\"");
        }
        if (!StringUtils.isBlank(width)) {
            ListTagUtil.write(pageContext, " width=\"");
            ListTagUtil.write(pageContext, width);
            ListTagUtil.write(pageContext, "\"");
        }
        else {
            ListTagUtil.write(pageContext, 
                    " class=\"thin-column list-checkbox-header\" ");

        }
        ListTagUtil.write(pageContext, ">");       
    }
    
    private Object getCurrent() {
        ListTag parent = (ListTag)
        BodyTagSupport.findAncestorWithClass(this, ListTag.class);
        return parent.getCurrentObject();
    }

    private Object getParentObject() {
        ListTag parent = (ListTag)
        BodyTagSupport.findAncestorWithClass(this, ListTag.class);
        return parent.getParentObject();
    }
    
    private String getIgnorableParentIds() {
        ListTag parent = (ListTag)
                BodyTagSupport.findAncestorWithClass(this, ListTag.class);
        if (!parent.isParentAnElement()) {
            StringBuilder buf = new StringBuilder();
            for (Object current : parent.getPageData()) {
                if (RhnListTagFunctions.isExpandable(current)) {
                    if (buf.length() > 0) {
                        buf.append(",");
                    }
                    buf.append("'");
                    buf.append(makeCheckboxId(listName,
                                        ListTagHelper.getObjectId(current)));
                    buf.append("'");
                }
            }
            buf.insert(0, "[");
            buf.append("]");            
            return buf.toString();
        }
        return "[]";
    }
    
    private static String makePostScriptKey(String listName) {
        return "list_" + listName + "_post_script";
    }
    
    private static void addPostScript(String script, String listName,
                                                ServletRequest request) {
        String key  = makePostScriptKey(listName);
        StringBuilder test = (StringBuilder)request.getAttribute(key);
        if (test == null) {
            test = new StringBuilder();
            request.setAttribute(key, test);
        }
        test.append(script);
    }
    
    /**
     * Returns any bound post java script
     * to be used by the selectable decorator
     * @param listName the name of the list
     * @param request the request param
     * @return the post script
     */
    public static String getPostScript(String listName,
                                                ServletRequest request) {
        String key  = makePostScriptKey(listName);
        StringBuilder test = (StringBuilder)request.getAttribute(key);
        if (test != null) {
            return test.toString(); 
        }
        return "";
    }    
}
