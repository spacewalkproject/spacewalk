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
package com.redhat.rhn.frontend.taglibs.list.decorators;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.html.HtmlTag;
import com.redhat.rhn.frontend.taglibs.list.ListTagUtil;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import javax.servlet.ServletRequest;
import javax.servlet.jsp.JspException;

/**
 * PageSizeDecorator
 * @version $Rev$
 */
public class PageSizeDecorator extends BaseListDecorator {

    private static Logger logger = Logger.getLogger(PageSizeDecorator.class);
    private static final int DEFAULT_PAGE_SIZE = 25;
    private static final List<Integer> PAGE_SIZE = new LinkedList<Integer>();
    /** static value for max results per page. */
    public static final int MAX_PER_PAGE = 500;
    private static final String PAGE_SIZE_LABEL = "PAGE_SIZE_LABEL";
    private static final String PAGE_SELECTION_LABEL = "PAGE_SIZE_LABEL_SELECTED";
    
    private static final String SELECTED = "selected";
    private static final String ON_CHANGE = "document.getElementById('%s').value='%s';" +
                                                    "this.form.submit(); return true";    
    
    static {
        PAGE_SIZE.add(5);
        PAGE_SIZE.add(10);
        PAGE_SIZE.add(25);
        PAGE_SIZE.add(50);
        PAGE_SIZE.add(100);
        PAGE_SIZE.add(250);
        PAGE_SIZE.add(500);
    }
    
    private static  String makePageSizeLabel(String listName) {
        return listName + "_" + PAGE_SIZE_LABEL;
    }
    
    /**
     * Gets the page size decorator form widget label
     * @param listName name of the list (already uniquified)
     * @return the string that makes the page widget label
     */
    public static  String makeSelectionLabel(String listName) {
        return listName + "_" + PAGE_SELECTION_LABEL;
    }    
    
    /**
     * Returns true if the page size widget was selected
     * @param request the http  servlet request
     * @param listName the name of the list
     * @return true if the page size widget was selected
     */
    public static boolean pageWidgetSelected(ServletRequest request, String listName) {
        return SELECTED.equals(request.getParameter
                        (makeSelectionLabel(listName)));
    }
    
    /**
     * returns the page size 
     * @param request the http  servlet request
     * @param listName the name of the list
     * @return selected page size or -1 if none was selected.
     */
    public static int getSelectedPageSize(ServletRequest request, String listName) {
        if (pageWidgetSelected(request, listName)) {
            return Integer.valueOf(request.getParameter(makePageSizeLabel(listName)));
        }
        return -1;
    }
    
    private static String makeSelectionId(String listName) {
        return makeSelectionLabel(listName) + "_id";
    }
    
    
    private String makeOnChangeScript() {
        return String.format(ON_CHANGE, 
                makeSelectionId(listName), SELECTED);
    }
    /**
     * {@inheritDoc}
     */
    public void beforeTopPagination() throws JspException {
        if (!getCurrentList().isEmpty()) {
            StringBuilder stringBuild = new StringBuilder();
            
            stringBuild.append("<td class=\"list-sizeselector\">");
            HtmlTag select = new HtmlTag("Select");
            select.setAttribute("name", makePageSizeLabel(listName));
            select.setAttribute("onChange", makeOnChangeScript());
            
            for (int size : PAGE_SIZE) {
                HtmlTag option = new HtmlTag("option");
                option.setAttribute("value", String.valueOf(size));
                if (currentList.getPageSize() == size) {
                    option.setAttribute("selected", "selected");
                 }
                option.addBody(String.valueOf(size));
                select.addBody(option);
            }
            
            LocalizationService ls = LocalizationService.getInstance();
            stringBuild.append(ls.getMessage("message.items.per.page", 
                                                    select.render()));
            stringBuild.append("</td>");
            HtmlTag input = new HtmlTag("input");
            input.setAttribute("type", "hidden");
            input.setAttribute("id", makeSelectionId(listName));
            input.setAttribute("name", makeSelectionLabel(listName));
            input.setAttribute("value", pageContext.getRequest().getParameter
                                            (makeSelectionLabel(listName)));
            stringBuild.append(input.render());
            ListTagUtil.write(pageContext, stringBuild.toString());
        }
    }

    /**
     * Returns the default page size that can be used
     * by the app. This is basically used at the user creation time.
     * When a new user is created, the default page size is set 
     * using the value returned by this method..
     * @return the defaut page size.
     */
    public static int getDefaultPageSize() {
        String sizeStr = ConfigDefaults.get().getDefaultPageSize();
        int size = DEFAULT_PAGE_SIZE;
        try {
            if (!StringUtils.isBlank(sizeStr)) {
                size = Integer.valueOf(sizeStr);                
            }
        }
        catch (NumberFormatException nfe) {
            logger.warn("Number format exception encountered while parsing " +
                    ConfigDefaults.DEFAULT_PAGE_SIZE + "=" + sizeStr);
            size = DEFAULT_PAGE_SIZE;
        }
        
        int prev = 0;
        for (int sz : getPageSizes()) {
            if (sz == size) {
                return size;
            }
            if (sz > size) {
                if (prev == 0) {
                    return sz;
                }
                else {
                    return prev;
                }
            }
            prev = sz;
        }
        
        return prev;
    }
    
    /**
     * Returns the list of available page sizes.
     * This is used mainly in the PageSize selection 
     * drop down when rendering lists...
     * This is also used in the Your Preferences page to check
     * the list of page sizes..
     * @return the list of page sizes..
     */
    public static List<Integer> getPageSizes() {
        String pageSizes = ConfigDefaults.get().getPageSizes();
        String [] sizes = pageSizes.split("\\,");
        if (StringUtils.isBlank(pageSizes) || sizes == null || sizes.length == 0) {
            return PAGE_SIZE;
        }
        
        try {
            List<Integer> ret = new LinkedList<Integer>();
            for (String size : sizes) {
                ret.add(Integer.valueOf(size.trim()));
            }
            return ret;
        }
        catch (NumberFormatException nfe) {
            logger.warn("Number format exception encountered while parsing " + 
                    ConfigDefaults.PAGE_SIZES + "=" + pageSizes);
            return Collections.EMPTY_LIST;
        }
    }
}
