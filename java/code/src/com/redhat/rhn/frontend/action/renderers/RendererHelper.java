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

package com.redhat.rhn.frontend.action.renderers;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.action.renderers.io.CachingResponseWrapper;
import com.redhat.rhn.frontend.dto.SystemOverviewComparator;

import java.io.IOException;
import java.util.Arrays;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * General helper for fragment rendering
 *
 * @version $Rev$
 */
public class RendererHelper {

    private static final String FULL_TABLE_HEADER =
            "<div style=\"clear:both; padding-top: 30px;\">" +
             "<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" class=\"list\">" +
             "<thead><tr><th style=\"text-align:left;\">";

    private static final String FULL_TABLE_FOOTER = "</td></tr></thead></table></div>";

    private static final String HALF_TABLE_HEADER =
            "<table cellspacing=\"0\" cellpadding=\"0\" class=\"half-table\">" +
            "<thead><tr><th style=\"text-align:left;\">";

    private static final String HALF_TABLE_FOOTER = "</td></tr></thead></table>";

    private static final String TABLE_BODY =
        "</th></tr><tr class=\"list-row-odd\">" +
        "<td style=\"padding-bottom: 24px;\" class=\"first-column last-column\">";

    private RendererHelper() {

    }

    /**
     * Sort overview DTOs
     * @param dr data result to sort
     * @return sorted data result
     */
    public static DataResult sortOverviews(DataResult dr) {
        Object[] overviews = dr.toArray();
        if (overviews != null && overviews.length > 0) {
            Arrays.sort(overviews, new SystemOverviewComparator());
            return new DataResult(Arrays.asList(overviews));
        }
        else {
            return dr;
        }
    }

    /**
     * Creates an empty YourRhn table
     * @param isHalfTable is it a half table?
     * @param tableHeaderKey resource bundle token
     * @param tableMessageKey resource bundle token
     * @return markup for empty table
     */
    public static String makeEmptyTable(boolean isHalfTable,
            String tableHeaderKey, String tableMessageKey) {
        String header = null;
        String footer = null;
        String headerText = LocalizationService.getInstance().getMessage(
                tableHeaderKey);
        String messageText = LocalizationService.getInstance().getMessage(
                tableMessageKey);
        if (isHalfTable) {
            header = HALF_TABLE_HEADER;
            footer = HALF_TABLE_FOOTER;
        }
        else {
            header = FULL_TABLE_HEADER;
            footer = FULL_TABLE_FOOTER;
        }
        return header + headerText + TABLE_BODY + messageText + footer;
    }

    /**
     * Sets table style
     * @param request incoming request
     * @param name style name
     */
    public static void setTableStyle(HttpServletRequest request, String name) {
        String style = (String) request.getAttribute(FragmentRenderer.NEXT_TABLE_STYLE);
        if (style != null && name != null) {
            request.setAttribute(name, style);
        }
        toggleNextTableStyle(request);
    }

    /**
     * Renders a URL and returns the content generated as a string
     * @param url content to generate
     * @param req incoming request
     * @param resp current respnose
     * @return rendered content
     * @throws ServletException something goes wrong
     * @throws IOException something goes wrong
     */
    public static String renderRequest(String url, HttpServletRequest req,
            HttpServletResponse resp) throws ServletException, IOException {
        String retval = null;
        RequestDispatcher dispatcher = req.getRequestDispatcher(url);
        if (dispatcher != null) {
            CachingResponseWrapper wrapper =
                new CachingResponseWrapper(resp);
            dispatcher.include(req, wrapper);
            retval = wrapper.getCachedContent();
            if (retval != null) {
                retval = retval.trim();
            }
        }
        return retval;
    }

    private static void toggleNextTableStyle(HttpServletRequest request) {
        String tableStyle = (String)
            request.getAttribute(FragmentRenderer.NEXT_TABLE_STYLE);
        if (tableStyle == null ||
                tableStyle.equals("half-table half-table-left")) {
            request.setAttribute(FragmentRenderer.NEXT_TABLE_STYLE,
                    "half-table half-table-right");
        }
        else {
            request.setAttribute(FragmentRenderer.NEXT_TABLE_STYLE,
                    "half-table half-table-left");
        }
    }
}
