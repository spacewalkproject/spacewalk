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
package com.redhat.rhn.frontend.servlets;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

/**
 * RhnHttpServletResponse
 * @version $Rev$
 */
public class RhnHttpServletResponse extends HttpServletResponseWrapper {

    private HttpServletRequest req;
    /* as per the spec, we default to ISO-8859-1 unless set otherwise */
    private String charset = "ISO-8859-1";

    /**
     * Constructs a new HttpServletResponse based on the given paremeters.
     * @param resp The HttpServletResponse we are wrapping.
     * @param request The HttpServletRequest which initiated this response.
     */
    public RhnHttpServletResponse(HttpServletResponse resp,
            HttpServletRequest request) {
        super(resp);
        req = request;

    }

    /**
     * {@inheritDoc}
     */
    public void sendRedirect(java.lang.String location) throws IOException {

        if (location == null) {
            super.sendRedirect(location);
            return;
        }

        // Construct a new absolute URL if possible (cribbed from
        // the DefaultErrorPage servlet)
        URL url = null;
        try {
            url = new URL(location);

            if (url.getAuthority() == null) {
                super.sendRedirect(location);
                return;
            }

        }
        catch (MalformedURLException e1) {
            String requrl = req.getRequestURL().toString();
            try {
                url = new URL(new URL(requrl), location);
            }
            catch (MalformedURLException e2) {
                throw new IllegalArgumentException(location);
            }
        }
        location = url.toExternalForm();
        super.sendRedirect(location);
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return "TESTING!!!!!";

    }

    /**
     * {@inheritDoc}
     */
    public String encodeRedirectUrl(String arg0) {
        String rc = super.encodeRedirectUrl(arg0);
        return rc;
    }

    /**
     * {@inheritDoc}
     */
    public String encodeRedirectURL(String arg0) {
        String rc = super.encodeRedirectURL(arg0);
        return rc;
    }

    /**
     * {@inheritDoc}
     */
    public void setCharacterEncoding(String charsetIn) {
        charset = charsetIn;
    }

    /**
     * {@inheritDoc}
     */
    public String getCharacterEncoding() {
        return charset;
    }
}
