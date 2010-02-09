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

import com.mockobjects.servlet.MockHttpServletRequest;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.Cookie;

/**
 * RhnMockHttpServletRequest is a mock implementation of the
 * HttpServletRequest which fixes deficiencies in the MockObjects'
 * implementation of MockHttpServletRequest.
 * @version $Rev$
 */
public class RhnMockHttpServletRequest extends MockHttpServletRequest {

    /** Context Path */
    private String requestURL;
    private Map attributes;
    private Map headers;
    private Map parameterMap;
    private List locales;
    private int port;
    private boolean secure;
    private List cookies;
    private String encoding;
    private String method;
    private Enumeration headerNames;
    
    /**
     * default constructor
     */
    public RhnMockHttpServletRequest() {
        super();
        attributes = new HashMap();
        headers = new HashMap();
        locales = new ArrayList();
        parameterMap = new HashMap();
        cookies = new ArrayList();
        setupServerName("somehost.rhn.redhat.com");
        setupGetRequestURI("/rhn/network/somepage.do");
        setLocale(Locale.getDefault());
        setSession(new RhnMockHttpSession());
        setMethod("POST");
    }
    
    /**
     * Overrides the MockHttpServletRequest to actually return a value.
     * The Mock version returns null
     * @return StringBuffer Context Path
     */
    public java.lang.StringBuffer getRequestURL() {
        return new StringBuffer(requestURL);
    }
    
    /**
     * Added the ability to specify a context path for testing.
     * @param pathIn Request url path.
     */
    public void setRequestURL(String pathIn) {
        this.requestURL = pathIn;
    }
    
    /**
     * Returns the attribute bound to the given name.
     * @param name Name of attribute whose value is sought.
     * @return Object value of attribute with given name.
     */
    public Object getAttribute(String name) {
        return attributes.get(name);
    }
    
    /**
     * Adds a new attribute the Request.
     * @param name attribute name
     * @param value attribute value
     */
    public void addAttribute(String name, Object value) {
        attributes.put(name, value);
    }

    /**
     * Sets an attribute the Request.
     * @param name attribute name
     * @param value attribute value
     */
    public void setAttribute(String name, Object value) {
        attributes.put(name, value);
    }
    

    /** {@inheritDoc} */
    public String getHeader(String name) {
        return (String)headers.get(name);
    }
    
    /** {@inheritDoc} */
    public Enumeration getHeaderNames() {
        return this.headerNames;
    }
    
    /**
     * Header Names
     * @param headerNamesIn attribute headerNames
     */
    public void setupGetHeaderNames(Enumeration headerNamesIn) {
        this.headerNames = headerNamesIn;
    }

    /** {@inheritDoc} */
    public Map getParameterMap() {
        return parameterMap;
    }
    
    /**
     * {@inheritDoc}
     */
    public void setupGetParameterMap(Map map) {
        parameterMap = map;
    }

    /** {@inheritDoc} */
    public Locale getLocale() {
        return (Locale) this.locales.get(0);
    }
    
    /**
     * Set the primary locale of this Request.
     * @param lcl The primary Local of this Request.
     */ 
    public void setLocale(Locale lcl) { 
        this.locales.add(0, lcl);
    }
    
    /** 
     * Set the list of Locales.
     * @param lcls List of Locales.
     */
    public void setLocales(List lcls) {
        this.locales = lcls;
    }
    
    /** {@inheritDoc} */
    public Enumeration getLocales() {
        return java.util.Collections.enumeration(this.locales);
    }
    
    /**
     * Allows you to add a Cookie to the request to simulate receiving
     * a cookie from the browser.
     * @param cookie Cookie to added.
     */
    public void addCookie(Cookie cookie) {
        cookies.add(cookie);
    }

    /** {@inheritDoc} */
    public Cookie[] getCookies() {
        return (Cookie[]) cookies.toArray(new Cookie[0]);
    }

    /** {@inheritDoc} */
    public int getServerPort() {
        return port;
    }
    
    /**
     * Sets the server port for this request.
     * @param p Port
     */
    public void setupGetServerPort(int p) {
        port = p;
    }

    /**
     * Add a GET header to the request.
     * @param headerName name of header to be added
     * @param value value of header to be added.
     */
    public void setupGetHeader(String headerName, String value) {
        headers.put(headerName, value);
    }
    
    /**
     * Configures whether this request is secure.
     * @param s Flag indicating whether request is secure.
     */
    public void setupIsSecure(boolean s) {
        secure = s;
    }

    /** {@inheritDoc} */
    public boolean isSecure() {
        return secure;
    }

    /** {@inheritDoc} */
    public String getCharacterEncoding() {
        return encoding;
    }

    /** {@inheritDoc} */
    public void setCharacterEncoding(String encodingIn) {
        this.encoding = encodingIn; 
    }


    /**
     * @return Returns the method.
     */
    public String getMethod() {
        return method;
    }


    /**
     * @param methodIn The method to set.
     */
    public void setMethod(String methodIn) {
        this.method = methodIn;
    }
}
