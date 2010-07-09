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
package com.redhat.rhn.frontend.action;

import com.redhat.rhn.common.db.datasource.Elaborator;
import com.redhat.rhn.common.util.CSVWriter;
import com.redhat.rhn.common.util.download.ByteArrayStreamInfo;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DownloadAction;

import java.io.StringWriter;
import java.util.Arrays;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Expects that the following parameters are available from the request object:
 *  EXPORT_COLUMNS set to the value of the session attribute containing the
 *      exportColumns
 *  PAGE_LIST_DATA set to the value of the session attribute containg the List
 *      of items to export
 *  UNIQUE_NAME set to the value of the uniqueName associated with this list
 *      from the CSVTag
 *
 * @author jmatthews
 * @version $Rev: $
 */
public class CSVDownloadAction extends DownloadAction {
    public static final String EXPORT_COLUMNS = "__CSV__exportColumnsParam";
    public static final String PAGE_LIST_DATA = "___CSV_pageListData";
    public static final String UNIQUE_NAME = "__CSV_uniqueName";
    public static final String HEADER_NAME = "__CSV_headerName";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try {
            super.execute(mapping, form, request, response);
        }
        catch (Exception e) {
            /**
             * Overridden to redirect for case of errors while processing CSV Export,
             * example: Session timeout.
             */
            return mapping.findForward("error");
        }
        return null;
    }

    /**
     * Returns String containing a comma separated list of names to represent the
     * header values of the List or throws Exception if request attribute
     * EXPORT_COLUMNN is missing or session attribute is null.
     *
     * @param request HTTP request
     * @param session HTTP session
     * @return exported columns
     * @throws Exception thrown if request attribute EXPORT_COLUMN is missing.
     */
    protected String getExportColumns(HttpServletRequest request,
            HttpSession session)
        throws Exception {
        String paramExportColumns = request.getParameter(EXPORT_COLUMNS);
        if (null == paramExportColumns) {
            throw new Exception("Missing request parameter, " + EXPORT_COLUMNS);
        }
        String exportColumns = (String) session.getAttribute(paramExportColumns);
        if (null == exportColumns) {
            throw new Exception("Missing value for session attribute, " +
                    paramExportColumns);
        }
        return exportColumns;
    }

    /**
     * Returns List of data referred to by session attribute with the name
     * PAGE_LIST_DATA. Throws Exception if request attribute PAGE_LIST_DATA is
     * missing or session attribute is null.
     *
     * @param request HTTP Request
     * @param session HTTP session
     * @return page data
     * @throws Exception thrown if column missing.
     */
    protected List getPageData(HttpServletRequest request, HttpSession session)
        throws Exception {
        String paramPageData = request.getParameter(PAGE_LIST_DATA);
        if (null == paramPageData) {
            throw new Exception("Missing request parameter, " + EXPORT_COLUMNS);
        }
        List pageData = (List) session.getAttribute(paramPageData);
        if (null == pageData) {
            throw new Exception("Missing value for session attribute, " +
                    paramPageData);
        }
        return pageData;
    }

    /**
     * Returns the value of the UNIQUE_NAME attribute or exception if value
     * is null.
     * @param request HTTP request containing UNIQUE_NAME parameter
     * @return unique name
     * @throws Exception thrown if UNIQUE_NAME value is null.
     */
    protected String getUniqueName(HttpServletRequest request) throws Exception {
        String uniqueName = request.getParameter(UNIQUE_NAME);
        if (uniqueName == null) {
            throw new Exception("Missing request parameter, " + UNIQUE_NAME);
        }
        return uniqueName;
    }

    /**
     * Returns the header name
     * @param request
     * @return the header name
     * @throws Exception
     */
    protected String getHeaderText(HttpServletRequest request, HttpSession session)
        throws Exception {
        String paramHeader = request.getParameter(HEADER_NAME);
        if (null == paramHeader) {
            // this is an optional parameter, return null if it's not there.
            return null;

        }
        String header = (String) session.getAttribute(paramHeader);
        if (null == header) {
            throw new Exception("Missing value for session attribute, " +
                    paramHeader);
        }
        return header;
    }


    /**
     * {@inheritDoc}
     */
    protected StreamInfo getStreamInfo(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response)
    throws Exception {
        HttpSession session = request.getSession(false);
        if (null == session) {
            throw new Exception("Missing session");
        }
        String exportColumns = getExportColumns(request, session);
        List pageData = getPageData(request, session);

        CSVWriter expW = new CSVWriter(new StringWriter());
        String[] columns  = exportColumns.split("\\s*,\\s*");
        expW.setColumns(Arrays.asList(columns));

        String header = getHeaderText(request, session);
        if (header != null) {
            expW.setHeaderText(header);
        }
        Elaborator elab = TagHelper.lookupElaboratorFor(
                getUniqueName(request), request);
        if (elab != null) {
            elab.elaborate(pageData);
        }

        String contentType = expW.getMimeType() + ";charset=" +
            response.getCharacterEncoding();
        response.setHeader("Content-Disposition",
                "attachment; filename=download." + expW.getFileExtension());
        expW.write(pageData);

        return new ByteArrayStreamInfo(contentType, expW.getContents().getBytes());
    }

}
