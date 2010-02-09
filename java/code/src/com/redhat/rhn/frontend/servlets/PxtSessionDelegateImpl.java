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

import com.redhat.rhn.common.util.TimeUtils;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.session.WebSessionFactory;
import com.redhat.rhn.manager.session.SessionManager;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PxtSessionDelegateImpl is an implementation of PxtSessionDelegate that wraps a
 * RequestContext object.
 * 
 * @see PxtSessionDelegate
 * @see com.redhat.rhn.frontend.struts.RequestContext
 * @version $Rev$
 */
public class PxtSessionDelegateImpl implements PxtSessionDelegate {
    
    private PxtCookieManager pxtCookieManager;
    
    protected PxtSessionDelegateImpl() {
        pxtCookieManager = new PxtCookieManager();
    }
    
    /**
     * {@inheritDoc}
     */
    public WebSession getPxtSession(HttpServletRequest request) {
        loadPxtSession(request);
        return (WebSession)request.getAttribute("session");
    }
    
    /**
     * {@inheritDoc}
     */
    public Long getWebUserId(HttpServletRequest request) {
        return getPxtSession(request).getWebUserId();
    }
    
    /**
     * {@inheritDoc}
     */
    public void updateWebUserId(HttpServletRequest request, HttpServletResponse response,
            Long id) {
        
        getPxtSession(request).setWebUserId(id);
        refreshPxtSession(request, response);
    }

    /**
     * {@inheritDoc}
     */
    public boolean isPxtSessionExpired(HttpServletRequest request) {
        return getPxtSession(request).isExpired();
    }

    /**
     * {@inheritDoc}
     */
    public boolean isPxtSessionKeyValid(HttpServletRequest request) {
        Cookie pxtCookie = pxtCookieManager.getPxtCookie(request);
        
        return pxtCookie != null && 
            SessionManager.isPxtSessionKeyValid(pxtCookie.getValue()); 
    }
    
    /**
     * Loads the pxt session and stores it in the request as an attribute named 
     * <code>session</code>. If the pxt session is not already present in the request,
     * it is fetched from the database if the pxt cookie is available. If the pxt cookie
     * is not available, a new pxt session is created.
     * 
     * @param request The current request.
     */
    protected void loadPxtSession(HttpServletRequest request) {
        Object sessionAttribute = request.getAttribute("session");
        
        if (!(sessionAttribute instanceof WebSession)) {
            Long pxtSessionId = getPxtSessionId(request);
            
            if (pxtSessionId != null) {
                sessionAttribute = findPxtSessionById(pxtSessionId);
            }
            
            // There is a scenario in which the pxt session will not be found above even
            // though the request contains a session id. If a logged in user sends a request
            // over HTTP, EnvironmentFilter intercepts the request, invalidates the pxt
            // session, and redirects the request over HTTPS. When this occurs, the pxt
            // cookie still exists, but the session id that it carries is now invalid.
            // Consequently, a new pxt session will need to be created.
            
            if (sessionAttribute == null) {
                sessionAttribute = createPxtSession();
            }
            
            request.setAttribute("session", sessionAttribute);
        }
    }
    
    /**
     * Parses the pxt session id out of the pxt cookie if it included in the request.
     * 
     * @param request The current request.
     * 
     * @return The pxt session id parsed out of the pxt cookie, if the cookie is included in
     * the request. Return <code>null</code> if the pxt cookie is not found or if the key
     * is invalid.
     */
    protected Long getPxtSessionId(HttpServletRequest request) {
        Cookie pxtCookie = pxtCookieManager.getPxtCookie(request);
        
        if (pxtCookie == null) {
            return null;
        }
        
        if (!SessionManager.isPxtSessionKeyValid(pxtCookie.getValue())) {
            return null;
        }
        
        String[] tokens = pxtCookie.getValue().split("x");
        
        return Long.valueOf(tokens[0]);
    }
    
    /**
     * Retrieves the pxt session with the given ID. This method simply wraps a call to
     * <code>WebSessionFactory</code>. This makes it easier to write tests that can avoid
     * calls to <code>WebSessionFactory</code>, which would result in database calls.
     * 
     * @param id The session ID to search by.
     * @return The pxt session or <code>null</code> if no session is found.
     * @see WebSessionFactory#lookupById(Long)
     */
    protected WebSession findPxtSessionById(Long id) {
        return WebSessionFactory.lookupById(id);
    }
    
    /**
     * Creates a new pxt session. This method simply wraps a call to <code>SessionManager
     * </code>. This makes it easier to write tests that can avoid calls to
     * <code>SessionManager</code>, which would result in database calls.
     * 
     * @return A new pxt session.
     * @see SessionManager#makeSession(Long, long)
     */
    protected WebSession createPxtSession() {
        return SessionManager.makeSession(null, SessionManager.lifetimeValue());
    }

    /**
     * {@inheritDoc}
     */
    public void refreshPxtSession(HttpServletRequest request,
            HttpServletResponse response) {
        
        refreshPxtSession(request, response, (int)SessionManager.lifetimeValue());
    }
    
    private void refreshPxtSession(HttpServletRequest request, 
            HttpServletResponse response, int pxtCookieExpiration) {
        
        WebSession pxtSession = getPxtSession(request);
        
        Cookie pxtCookie = pxtCookieManager.createPxtCookie(pxtSession.getId(), request, 
                pxtCookieExpiration);
        
        pxtSession.setExpires(TimeUtils.currentTimeSeconds() + 
                SessionManager.lifetimeValue());
        savePxtSession(pxtSession);
        
        response.addCookie(pxtCookie);
    }
    
    /**
     * This method is a hook for testing.
     * 
     * @param pxtSession The session to be saved
     */
    protected void savePxtSession(WebSession pxtSession) {
        WebSessionFactory.save(pxtSession);
    }

    /**
     * {@inheritDoc}
     */
    public void invalidatePxtSession(HttpServletRequest request,  
            HttpServletResponse response) {
        
        //updateWebUserId(request, response, null);
        WebSession pxtSession = getPxtSession(request);
        pxtSession.setWebUserId(null);
        
        refreshPxtSession(request, response, 0);
    }
    
}
