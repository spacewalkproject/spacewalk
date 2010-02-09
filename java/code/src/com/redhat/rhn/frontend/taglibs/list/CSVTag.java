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
import com.redhat.rhn.frontend.action.CSVDownloadAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyTagSupport;

/**
 * Exports a List of data to a comma separated value string
 * 
 * @version $Rev $
 */
public class CSVTag extends BodyTagSupport {

    public static final String CSV_DOWNLOAD_URI = "/rhn/CSVDownloadAction.do";

    private static final long serialVersionUID = -1104734460994073343L;

    private String name = ListHelper.LIST;
    private String dataSetName = ListHelper.DATA_SET;
    
    private String uniqueName;

    private String exportColumns;
    
    private String header = null;

    private List pageData;

    /**
     * Stores the "name" of the list. This is the "salt" used to build the
     * uniqueName used by the ListTag and ColumnTag.
     * 
     * @param nameIn
     *            list name
     */
    public void setName(String nameIn) {
        name = nameIn;
    }

    /**
     * Build the list's unique name Algorithm for the unique name is: Take the
     * CRC value of the following string: request url + ";" + name
     * 
     * @return unique name
     */
    public synchronized String getUniqueName() {
        if (uniqueName == null) {
            uniqueName = TagHelper.generateUniqueName(name);
        }
        return uniqueName;
    }

    /**
     * Header is a string to go on the top of a CSV exported file,
     * can be used to provide extra info to a user.
     *
     * @param headerIn
     *      optional text to be printed as first line of exported CSV file
     */
    public void setHeader(String headerIn) {
        header = headerIn;
    }
    
    /**
     * @return optional header text for CSV file 
     */
    public String getHeader() {
        return header;
    }
    
    /**
     * Sets the name of the dataset to use Tries to locate the list in the
     * following order: page context, request attribute, session attribute
     * 
     * @param nameIn
     *            name of dataset
     * @throws JspException
     *             indicates something went wrong
     */
    public void setDataset(String nameIn) throws JspException {
        dataSetName = nameIn;
    }

    /**
     * @throws JspException exception raised if datasetname is not
     *                  defined
     */
    public void setupPageData() throws JspException {
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
    }
    
    /**
     * @return Returns the exportColumns.
     */
    public String getExportColumns() {
        return exportColumns;
    }

    /**
     * @param exportIn
     *            The export to set.
     */
    public void setExportColumns(String exportIn) {
        this.exportColumns = exportIn;
    }


    /**
     * ${@inheritDoc}
     */
    public int doEndTag() throws JspException {
        setupPageData();
        if ((null != exportColumns) && (null != pageData)) {
            renderExport(); 
        }
        release();
        return BodyTagSupport.EVAL_PAGE;
    }

    /**
     * ${@inheritDoc}
     */
    public int doStartTag() throws JspException {

        verifyEnvironment();
        return BodyTagSupport.EVAL_BODY_INCLUDE;
    }

    /**
     * ${@inheritDoc}
     */
    public void release() {
        name = ListHelper.LIST;
        dataSetName = ListHelper.DATA_SET;
        uniqueName = null;
        pageData = null;
        exportColumns = null;
        super.release();
    }

    /**
     * Adds a link pointing to an Action to deliver the CSV contents.
     * Depends on the need data being stored in the session context, 
     * while the attribute names are passed as request parameters.
     * 
     * @throws JspException
     */
    private void renderExport() throws JspException {
        StringBuffer page = new StringBuffer(CSV_DOWNLOAD_URI);
        page.append("?" + makeCSVRequestParams());
        String exportLink = new String("<div class=\"csv-download\"><a href=\"" +
                page + "\"><img src=\"/img/csv-16.png\" alt=\"\"/>" +
                LocalizationService.getInstance().getMessage(
                        "listdisplay.csv") + "</a></div>");
        ListTagUtil.write(pageContext, exportLink);
    }

    private void verifyEnvironment() throws JspException {
        if (BodyTagSupport.findAncestorWithClass(this, ListSetTag.class) == null) {
            throw new JspException("List must be enclosed by a ListSetTag");
        }
    }

    /**
     * Creates the request parameter string needed to pass info to the action
     * handling the CSV exporting.
     * 
     * @return String with request parameters for CSVDownloadAction
     */
    public String makeCSVRequestParams() {
        String paramExportColumns = "exportColumns_" + getUniqueName();
        String paramPageList = "pageList_" + getUniqueName();
        String paramHeader = "header_" + getUniqueName();
        HttpServletRequest request = (HttpServletRequest) pageContext
                .getRequest();
        HttpSession session = request.getSession(true);
        // exportColumns and pageData __must__ be in session context
        // so CSVDownloadAction is able to retreive them.
        session.setAttribute(paramExportColumns, exportColumns);
        session.setAttribute(paramPageList, pageData);
        
        String csvKey = 
            CSVDownloadAction.EXPORT_COLUMNS + "=" + paramExportColumns +
                "&" + CSVDownloadAction.PAGE_LIST_DATA + "=" + paramPageList + 
                "&" + CSVDownloadAction.UNIQUE_NAME + "=" + getUniqueName();
        
        if (header != null) {
            session.setAttribute(paramHeader, header);
            csvKey += "&" + CSVDownloadAction.HEADER_NAME + "=" + paramHeader;
        }
        
        return csvKey;
    }

}
