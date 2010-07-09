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

package com.redhat.rhn.common.util;

import com.redhat.rhn.common.RhnRuntimeException;

import org.apache.commons.lang.StringUtils;

import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;

/**
 * A simple class that assists with Servlet-related activities
 * @version $Rev$
 */
public class ServletUtils {
    /** utility class */
    private ServletUtils() { }

    /** util function to take a servlet request and compute the path
     * relative to the server (not relative to the webapp).  needed
     * when getPath() is relative to the webapp instead of the server
     * @param req The request to inspect
     * @return The path requested.
     */
    public static String getRequestPath(HttpServletRequest req) {
        try {
            String requestUri =
                (String)req.getAttribute("javax.servlet.forward.request_uri");
            if (StringUtils.isBlank(requestUri)) {
                requestUri = new URL(req.getRequestURL().toString()).getPath();
            }
            return requestUri;
        }
        catch (Exception e) {
            throw new IllegalArgumentException("Unable to parse url: " +
                                               req.getRequestURL());
        }
    }

    /**
     * Create a URL with parameters tacked on.  Used in redirects and
     * programmatic URL creation with parameters.  Handles URL encoding of
     * incoming keys and values as well.
     *
     * @param base baseUrl to compute path from
     * @param params params to fillout on the URL
     * @return String path
     */
    public static String pathWithParams(String base, Map params) {
        StringBuffer ret = new StringBuffer(base);
        boolean firstPass = true;

        // let's bail if there's no params
        if (params == null) {
            return ret.toString();
        }

        Iterator i = params.entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry me = (Map.Entry)i.next();
            Object[] values;

            // No guarantee of receiving strings here, use toString() instead of casts:
            if (me.getValue() == null) {
                values = new Object[] { me.getValue() };
            }
            else if (me.getValue() instanceof Object[]) {
                Object[] paramValues = (Object[]) me.getValue();
                String[] encodedValues = new String[paramValues.length];
                for (int x = 0; x < paramValues.length; x++) {
                    encodedValues[x] = StringUtil.urlEncode(paramValues[x].toString());
                }

                values = encodedValues;
            }
            else if (me.getValue() instanceof List) {
                List paramValues = (List) me.getValue();
                String[] encodedValues = new String[paramValues.size()];
                int x = 0;
                for (Object o : paramValues) {
                    encodedValues[x] = StringUtil.urlEncode(String.valueOf(o));
                    x++;
                }

                values = encodedValues;
            }
            else {
                String paramValue = me.getValue().toString();
                paramValue = StringUtil.urlEncode(paramValue);
                values = new Object[] { paramValue };
            }

            for (int idx = 0; idx < values.length; idx++) {
                if (values[idx] != null) {
                    if (firstPass) {
                        ret.append("?");
                    }
                    else {
                        ret.append("&");
                    }
                    firstPass = false;

                    String key = (String)me.getKey();
                    key = StringUtil.urlEncode(key);

                    ret.append(key);
                    ret.append("=");
                    ret.append(values[idx].toString());
                } //if
            } //for
        } //while

        return ret.toString();
    }

    /**
     * Creates a encoded URL query string with the parameters from the given request. If the
     * request is a GET, then the returned query string will simply consist of the query
     * string from the request. If the request is a POST, the returned query string will
     * consist of the form variables.
     *
     * <br/><br/>
     *
     * <strong>Note</strong>: This method does not support multi-value parameters.
     *
     * @param request The request for which the query string will be generated.
     *
     * @return An encoded URL query string with the parameters from the given request.
     */
    public static String requestParamsToQueryString(ServletRequest request) {

        StringBuffer queryString = new StringBuffer();

        String paramName = null;
        String paramValue = null;

        Enumeration paramNames = request.getParameterNames();

        while (paramNames.hasMoreElements()) {
            paramName = (String)paramNames.nextElement();
            paramValue = request.getParameter(paramName);

            queryString.append(encode(paramName)).append("=").append(encode(paramValue))
                    .append("&");
        }

        if (endsWith(queryString, '&')) {
            queryString.deleteCharAt(queryString.length() - 1);
        }

        return queryString.toString();
    }

    /**
     * Encodes the specified string with a UTF-8 encoding.
     *
     * @param string The String to encode.
     *
     * @return The encoded String.
     */
    public static String encode(String string) {
        try {
            return URLEncoder.encode(string, "UTF-8");
        }
        catch (UnsupportedEncodingException e) {
            throw new RhnRuntimeException(e);
        }
    }

    private static boolean endsWith(StringBuffer buffer, char c) {
        if (buffer.length() == 0) {
            return false;
        }

        return buffer.charAt(buffer.length() - 1) == c;
    }
}
