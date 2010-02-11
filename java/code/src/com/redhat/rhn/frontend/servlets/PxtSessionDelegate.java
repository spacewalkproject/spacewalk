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

import com.redhat.rhn.domain.session.WebSession;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PxtSessionDelegate provides an API with operations for retrieving, creating, and
 * updating the pxt session and pxt cookie.
 * 
 * <br/><br/>
 * 
 * Similiar operations can be found in RequestContext. Even though a similiar API already
 * exists in RequestContext, this API is provided to server those client who need only these
 * operations and not the full API of RequestContext. Therefore, it is reccomended that you
 * use PxtSessionDelegate instead of RequestContext if this API provides all of the 
 * operations that you need.
 * 
 * <br/><br/>
 * 
 * You obtain instances of PxtSessionDelegate from PxtSessionDelegateFactory. Below is an
 * example of how you might retrieve a PxtSessionDelegate:
 * 
 * <pre>
 *  HttpServletRequest request = // Get the current request...
 *  PxtSessionDelegateFactory factory = PxtSessionDelegateFactory.getInstance();
 *  PxtSessionDelegate pxtDelegate = factory.newPxtSessionDelegate(request);
 * </pre>
 * 
 * @see PxtSessionDelegateFactory
 * @see com.redhat.rhn.frontend.struts.RequestContext
 * @version $Rev$
 */
public interface PxtSessionDelegate {
        
    /**
     * Returns the <code>webUserId</code> property of the pxt session bound to the specified
     * request.
     * 
     * @param request The current request
     * 
     * @return The <code>webUserId</code> property of the pxt session.
     */
    Long getWebUserId(HttpServletRequest request);
    
    /**
     * Retrieve the pxt session. If the session does not exist, one will be created. The
     * session will be bound to a request attribute named <code>session</code>.
     * 
     * @param request The current request
     * 
     * @return The pxt session to which the request is bound.
     */
    WebSession getPxtSession(HttpServletRequest request);
    
    /**
     * Sets the <code>webUserId</code> property of the pxt session bound to the specified
     * request. Note that this operation triggers a session refresh.
     * 
     * @param request The current request
     * 
     * @param response The current response
     * 
     * @param id The ID to be assigned to the <code>webUserId</code> property.
     * 
     * @see #refreshPxtSession(HttpServletRequest, HttpServletResponse)
     */
    void updateWebUserId(HttpServletRequest request, HttpServletResponse response, Long id);
    
    /**
     * Return <code>true</code> if the pxt session for the current request has expired.
     * 
     * @param request The current request
     * 
     * @return <code>true</code> if the pxt session for the current request has expired,
     * <code>false</code> otherwise
     */
    boolean isPxtSessionExpired(HttpServletRequest request);
    
    /**
     * Validates the pxt session ID that is stored in the pxt cookie with a secret key in
     * the pxt session. Return <code>true</code> if the encoded session ID matches the
     * secret key.
     * 
     * @param request The current request
     * 
     * @return <code>true</code> if the encoded session ID matches the secret key,
     * <code>false</code> otherwise.
     */
    boolean isPxtSessionKeyValid(HttpServletRequest request);
        
    /**
     * Refreshes the pxt session, effectively reseting the timeout of the session. 
     * Specifically, implementations of PxtSessionDelegate are responsible for the 
     * following:
     * 
     * <ul>
     *   <li>
     *      Set the <code>expires</code> property of the session to an appropriate value.
     *   </li>
     *   <li>Save the session.</li>
     *   <li>Store a pxt cookie in the response with an appropriate timeout.</li>
     * </ul>
     * 
     * @param request The current request
     * @param response The current response
     */
    void refreshPxtSession(HttpServletRequest request, HttpServletResponse response);
    
    /**
     * Invalidates the pxt session for the given request.
     * 
     * @param request The current request
     * @param response The current response
     */
    void invalidatePxtSession(HttpServletRequest request, HttpServletResponse response);
    
}
