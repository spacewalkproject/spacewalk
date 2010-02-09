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
package com.redhat.rhn.testing;

import com.mockobjects.servlet.MockHttpServletResponse;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.Cookie;

/**
 * RhnMockHttpServletResponse is a mock implementation of the
 * HttpServletResponse which fixes deficiencies in the MockObjects'
 * implementation of MockHttpServletResponse.
 * @version $Rev$
 */
public class RhnMockHttpServletResponse extends MockHttpServletResponse {
    private Map cookies = new HashMap();
    private Map header = new HashMap();
    private String redirect;
    private String encoding;
    
    /** {@inheritDoc} */
    public void addCookie(Cookie cookie) {
        cookies.put(cookie.getName(), cookie);
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public void addHeader(String key, String value) {
        header.put(key, value);
    }
    
    /**
     * Returns the String value matching the given key 
     * @param key the header name
     * @return header value or null...
     */
    public String getHeader(String key) {
        return (String) header.get(key);
    }
    
    /**
     * Returns a Cookie matching the given name, null otherwise.
     * @param name cookie name
     * @return a Cookie matching the given name, null otherwise.
     */
    public Cookie getCookie(String name) {
        return (Cookie) cookies.get(name);
    }
    
    /**
     * Saves the url sent through a redirect so we can test it.
     * @param aURL The URL for this redirect
     * @throws java.io.IOException will never throw 
     */
    public void sendRedirect(String aURL) throws java.io.IOException {
        redirect = aURL;
    }
    
    /**
     * Gets the redirect instance variable
     * @return the redirect instance variable
     */
    public String getRedirect() {
        return redirect;
    }
    
    /**
     * Sets the redirect to null.
     */
    public void clearRedirect() {
        redirect = null;
    }
    
    /**
     * {@inheritDoc}
     */
    public void setCharacterEncoding(String encodingIn) {
        this.encoding = encodingIn;
    }
    
    /**
     * {@inheritDoc}
     */
    public String getCharacterEncoding() {
        return this.encoding;
    }
}
