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
package com.redhat.rhn.frontend.struts;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.token.TokenFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegate;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegateFactory;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.session.SessionManager;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;

/**
 * Utility methods for accessing various objects in the scope
 * of a request. The objects are created by looking at request
 * parameters for their ID's and then retrieving them from the
 * appropriate manager.
 * 
 * @version $Rev$
 */
public class RequestContext {
    
    private static final Logger LOG = Logger.getLogger(RequestContext.class);
    
    
    // Request IDs go here.
    public static final String LABEL = "label";
    public static final String USER_ID = "uid";
    public static final String ORG_ID = "oid";
    public static final String PROBEID = "probe_id"; 
    public static final String SUITE_ID = "suite_id";
    public static final String FILTER_ID = "filter_id";
    public static final String ERRATA_ID = "eid";
    public static final String SID = "sid";
    public static final String SID1 = "sid_1";
    public static final String CID = "cid";
    public static final String PRID = "prid";
    public static final String COBBLER_ID = "cobbler_id";
    public static final String FILTER_STRING = "filter_string";
    public static final String PREVIOUS_FILTER_STRING = "prev_filter_value";
    public static final String LIST_DISPLAY_EXPORT = "lde";
    public static final String TOKEN_ID = "tid";
    
    public static final String LIST_SORT = "sort";
    public static final String SORT_ORDER = "order";
    public static final String SORT_ASC = "asc";
    public static final String SORT_DESC = "desc";
    
    public static final String METHOD_ID = "cmid";
    public static final String KICKSTART_ID = "ksid";
    public static final String KSTREE_ID = "kstid";
    public static final String KEY_ID = "key_id";
    public static final String FILE_LIST_ID = "file_list_id";
    public static final String KICKSTART_SCRIPT_ID = "kssid";
    public static final String CONFIG_FILE_ID = "cfid";
    public static final String SERVER_GROUP_ID = "sgid";
    public static final String NAME = "name";
    // Request Attributes go here:
    public static final String ACTIVATION_KEY = "activationkey";
    public static final String KICKSTART = "ksdata";
    public static final String SYSTEM = "system";
    public static final String SERVER_GROUP = "systemgroup";
    public static final String KICKSTART_SESSION = "ksession";
    public static final String REQUESTED_URI = "requestedUri";
    public static final String KSTREE = "kstree";
    public static final String KICKSTART_STATE_DESC = "statedescription";
    public static final String PAGE_LIST = "pageList";
    public static final String DISPATCH = "dispatch";
    public static final String CONFIRM = "confirm";
    public static final String FILTER_KEY = "Go";
    public static final String NO_SCRIPT = "noscript";
    /** the name of the Red Hat session cookie */
    public static final String WEB_SESSION_COOKIE_NAME = "pxt-session-cookie";
    public static final String POST = "POST";
    
    
    private HttpServletRequest request;
    private User               currentUser;
        
    /**
     * Create a new context object that looks up objects
     * from the request <code>req0</code>
     * 
     * @param req0 the request from which to look up objects
     */
    public RequestContext(HttpServletRequest req0) {
        request = req0;        
    }

    /**
     * Return the request that is used by the context for
     * object lookup
     * @return the current request
     */
    public HttpServletRequest getRequest() {
        return request;
    }
    
    /**
     * Return the currently LOGged in user that is making the
     * request.
     * 
     * @return the currently LOGged in user that is making the
     * request.
     */
    public User getCurrentUser() {
        if (currentUser == null) {
            currentUser = getLoggedInUser();
        }
        return currentUser;
    }
    
    /**
     * Get the currently LOGged in User from the pxt session.
     * 
     * @return Currently LOGged in User.
     */
    public User getLoggedInUser() {
        /*
         * XMLRPC calls handle authentication on their own. We return null
         * because findUserSession is never going to correctly find an XMLRPC
         * user's sessions.
         */
        if (request.getRequestURI().startsWith("/rhn/rpc/api")) {
            return null;
        }

        WebSession pxtSession = getWebSession();
        
        if (pxtSession == null) {
            return null;
        }
        
        return pxtSession.getUser();
    }
    
    /**
     * Get the user on the request based on the "uid" paramter.  Used 
     * when editing Users other than the LOGged in user.
     * 
     * @return User found. 
     */
    // TODO Write unit tests for getUserFromUIDParameter()
    public User getUserFromUIDParameter() {
        Long uid = getParamAsLong(USER_ID);
        User user = UserManager.lookupUser(getCurrentUser(), uid);
        return user;
    }
    
    /**
     * Return the probe suite with the ID given by the request's
     * {@link #SUITE_ID}parameter
     * @return the probe suite with the ID given by the request's
     * {@link #SUITE_ID}parameter
     * @throws com.redhat.rhn.frontend.action.common.BadParameterException if the request 
     * does not contain the required parameter, or if the parameter can not be converted 
     * to a <code>Long</code>
     * @throws IllegalArgumentException if no probe suite with the ID given in
     * the request can be found
     */
    // TODO Write unit tests for lookupProbeSuite()
    public ProbeSuite lookupProbeSuite()
        throws BadParameterException, IllegalArgumentException {
        Long suiteId = getRequiredParam(SUITE_ID);
        ProbeSuite retval = MonitoringManager.getInstance().lookupProbeSuite(
                suiteId, getCurrentUser());
        assertObjectFound(retval, suiteId, SUITE_ID, "probe suite");
        return retval;
    }
    
    /**
     * Return the erratum with the ID given by the request's
     * {@link #ERRATA_ID}parameter
     * @return the erratum with the ID given by the request's
     * {@link #ERRATA_ID}parameter
     * @throws com.redhat.rhn.frontend.action.common.BadParameterException if the request 
     * does not contain the required parameter, or if the parameter can not be converted 
     * to a <code>Long</code>
     * @throws IllegalArgumentException if no probe suite with the ID given in
     * the request can be found
     */
    public Errata lookupErratum()
        throws BadParameterException, IllegalArgumentException {
        Long errataId = getRequiredParam(ERRATA_ID);
        Errata retval = ErrataManager.lookupErrata(errataId, getCurrentUser());
        assertObjectFound(retval, errataId, ERRATA_ID, "erratum");
        return retval;
    }
    
    /**
     * Return the server with the ID given by the request's {@link #SID}
     * parameter
     * @return the server with the ID given by the request's {@link #SID}
     * parameter
     * @throws com.redhat.rhn.frontend.action.common.BadParameterException if the request 
     * does not contain the required parameter, or if the parameter can not be converted 
     * to a <code>Long</code>
     * @throws IllegalArgumentException if no server with the ID given in the
     * request can be found
     */
    // TODO Write unit tests for lookupServer()
    public Server lookupServer()
        throws BadParameterException, IllegalArgumentException {
        Long serverId = getRequiredParam(SID);
        Server retval = SystemManager.lookupByIdAndUser(serverId,
                getCurrentUser());
        assertObjectFound(retval, serverId, SID, "server");

        return retval;
    }
    
    /**
     * Return the server with the ID given by the request's {@link #SID}
     * parameter. Puts the server in the request attributes.
     * @return the server with the ID given by the request's {@link #SID}
     * parameter
     * @throws com.redhat.rhn.frontend.action.common.BadParameterException if the request 
     * does not contain the required parameter, or if the parameter can not be converted 
     * to a <code>Long</code>
     * @throws IllegalArgumentException if no server with the ID given in the
     * request can be found
     */
    // TODO Write unit tests for lookupServer()
    public Server lookupAndBindServer()
        throws BadParameterException, IllegalArgumentException {
        if (request.getAttribute(SYSTEM) == null) {
            request.setAttribute(SYSTEM, lookupServer());
        }

        return (Server) request.getAttribute(SYSTEM);
    }
    
    /**
     * Return the Activation Key with the ID given by the request's {@link #TOKEN_ID}
     * parameter. Puts the activation key in the request attributes.
     * @return the  Activation Key with the ID given by the request's {@link #TOKEN_ID}
     * parameter
     * @throws com.redhat.rhn.frontend.action.common.BadParameterException if the request 
     * does not contain the required parameter, or if the parameter can not be converted 
     * to a <code>Long</code>
     * @throws IllegalArgumentException if no  Activation Key with the ID given in the
     * request can be found
     */
    public ActivationKey lookupAndBindActivationKey() {
        if (request.getAttribute(ACTIVATION_KEY) == null) {
            Long id = getRequiredParam(TOKEN_ID);
            ActivationKey key = ActivationKeyFactory.lookupByToken(
                                                        TokenFactory.lookup(id, 
                                                        getLoggedInUser().getOrg()));
            request.setAttribute(ACTIVATION_KEY, key);
        }
        return (ActivationKey) request.getAttribute(ACTIVATION_KEY);
    }

    /**
     * Return the KickstartData with the ID given by the request's {@link #KICKSTART_ID}
     * parameter. Puts the activation key in the request attributes.
     * @return the  KickstartDatay with the ID given by the request's {@link #KICKSTART_ID}
     * parameter
     * @throws com.redhat.rhn.frontend.action.common.BadParameterException if the request 
     * does not contain the required parameter, or if the parameter can not be converted 
     * to a <code>Long</code>
     * @throws IllegalArgumentException if no Kickstart Data with the ID given in the
     * request can be found
     */
    public KickstartData lookupAndBindKickstartData() {
        if (request.getAttribute(KICKSTART) == null) {
            Long id = getRequiredParam(KICKSTART_ID);
            KickstartData data = KickstartFactory.
                            lookupKickstartDataByIdAndOrg(getLoggedInUser().getOrg(),
                                                        id);
            assertObjectFound(data, id, KICKSTART_ID, "Kickstart Data");
            request.setAttribute(KICKSTART, data);
        }
        return (KickstartData) request.getAttribute(KICKSTART);
    }    

    /**
     * Return the ServerGroup with the ID given by the request's {@link #SERVER_GROUP_ID}
     * parameter. Puts the ServerGroupin the request attributes.
     * @return the  ServerGroup with the ID given by the request's {@link #SERVER_GROUP_ID}
     * @throws IllegalArgumentException if no ServerGroup with the ID given in the
     * request can be found
     */
    public ManagedServerGroup lookupAndBindServerGroup() {
        if (request.getAttribute(SERVER_GROUP) == null) {
            Long id = getRequiredParam(SERVER_GROUP_ID);
            ServerGroupManager manager = ServerGroupManager.getInstance();
            User user = getLoggedInUser();
            ManagedServerGroup sg = manager.lookup(id, user);
            if (sg == null) {
                String msg = "No server group with id = [%s] found.";
                throw new IllegalArgumentException(String.format(msg, id));
            }
            request.setAttribute(SERVER_GROUP, sg);
        }
        return (ManagedServerGroup) request.getAttribute(SERVER_GROUP);
    }
    
    /**
     * Return the probe with the ID given by the request's {@link #PROBEID}
     * parameter
     * @return the probe with the ID given by the request's {@link #PROBEID}
     * parameter
     * @throws com.redhat.rhn.frontend.action.common.BadParameterException if the request 
     * does not contain the required parameter, or if the parameter can not be converted 
     * to a <code>Long</code>   
     * @throws IllegalArgumentException if no probe with the ID given in the
     * request can be found
     */
    // TODO Write unit tests for lookupProbe()
    public Probe lookupProbe() {
        Long probeid = getRequiredParam(PROBEID);
        Probe retval = MonitoringManager.getInstance().lookupProbe(getCurrentUser(),
                probeid);
        assertObjectFound(retval, probeid, PROBEID, "probe");
        return retval;
    }
    
    private void assertObjectFound(Object obj, Long id, String paramName, String objName) {
        if (obj == null) {
            throw new IllegalArgumentException(
                    "Could not find " + objName + " with ID " + paramName + "=" + id);
        }
    }
    
    /**
     * Get the parameter <code>paramName</code> from the request. If
     * <code>required</code> is <code>true</code>, this method will never 
     * return <code>null</code>; instead, it will throw a
     * <code>BadParameterException</code> if the parameter is not in the
     * request. If <code>required</code> is <code>false</code>, the return
     * value can be <code>null</code>.
     * @param paramName the name of the parameter
     * @param required whether this parameter must be present
     * @return the parameter value or null if not required.
     */
    // TODO Refactor getParam(String, boolean)
    // This method is awkward in that if the required flag is set, an exception may be
    // throw. No exception will be thrown though if the flag is not set. Refactor the
    // method by removing the boolean argument, and adding a new method,
    // getRequiredParam(String) which throws the exception
    public String getParam(String paramName, boolean required) {
        String param = request.getParameter(paramName);
        if (required && param == null) {
            throw new BadParameterException("Required parameter [" +
                paramName + "] is null");
        }
        
        return param;
    }
    
    /**
     * Get whether a parameter is present in the request.
     * @param name The parameter name.
     * @return True if the named parameter is in the request.
     */
    public boolean hasParam(String name) {
        return (request.getParameter(name) != null);
    }
    
    /**
     * Returns the value of the parameter named param of the request as a Long.
     * 
     * This method will trim the String as well to check for "" and " ". If the
     * String is "1234 " it will return a Long with value: 1234. If the String
     * is "" and required is true it will treat it like a null value and throw
     * BadParameterException.
     * 
     * @param param Name of request parameter to be converted.
     * 
     * @throws BadParameterException if the parameter <code>param</code> can
     * not be converted to a Long
     * 
     * @return the value of the parameter named param of the request as a Long.
     *         <code>null</code> if the parameter is blank.
     */
    public Long getParamAsLong(String param) {
        String p = request.getParameter(param);
        Long result = null;

        // Make sure we catch empty strings as well
        if (!StringUtils.isBlank(p)) {
            try {
                result = Long.valueOf(p.trim());
            }
            catch (NumberFormatException e) {
                BadParameterException bad = new BadParameterException(
                        "The parameter " + param + " must be a Long, but was '" + 
                        p + "'", e);
                bad.setStackTrace(e.getStackTrace());
                throw bad;
            }
        }
        return result;
    }
    
    /**
     * Get the parameter <code>paramName</code> from the request and convert
     * it to a <code>Long</code>. A BadParameterException is thrown if the
     * parameter is not present in the request or can not be converted.
     * @param paramName the name of the parameter
     * @return the parameter value converted to a <code>Long</code>
     */
    public Long getRequiredParam(String paramName) {
        Long result = getParamAsLong(paramName);
        if (result == null) {
            // TODO: One day, BadParameterException wil take a message and we
            // can do
            // throw new BadParameterException("The parameter " + param +
            // " is required and must be a Long, but was '" + p +"'");
            // That one day has finally arrived! And the coders rejoiced.
            throw new BadParameterException("The parameter " + paramName + 
                    " is required.");
        }
        return result;
    }
    
    /**
     * If this current Request includes a parameter to indicate the User is attempting
     * to produce an export of viewable data then return true.
     * 
     * Only for use with the Old list tag's exporter.  The new list tag doesn't use 
     *      "lde" as a parameter, it uses   lde_unique(listName).
     * 
     * @return if this request includes an export param
     */
    // TODO Write unit tests for isRequestedExport()
    public boolean isRequestedExport() {
        String lde = request.getParameter(LIST_DISPLAY_EXPORT);
        return (lde != null && lde.equals("1")); 
    }

    /**
     * Retrieves the currently Logged in user's pxt session. If it doesn't exist, a new
     * session is created.
     * 
     * @return The currently Logged in user's pxt session. If it doesn't exist, a new
     * session is created.
     */
    public WebSession getWebSession() {
        PxtSessionDelegateFactory factory = PxtSessionDelegateFactory.getInstance();
        PxtSessionDelegate pxtDelegate = factory.newPxtSessionDelegate();
        
        return pxtDelegate.getPxtSession(request);
    }
        
    /**
     * Returns the pxt session cookie name, handles allow_pxt_personalities. This
     * should be removed once completely Java and stick to the HttpSession.
     * 
     * @return The WebSession (pxt session) name taking into consideration the
     * allow_pxt_personalities.
     */
    // TODO Write unit tests for getWebSessionCookieName()
    public String getWebSessionCookieName() {
        Config c = Config.get();
        int personality = c.getInt(ConfigDefaults.WEB_ALLOW_PXT_PERSONALITIES);
        if (personality > 0) {
            String[] name = StringUtils.split(request.getServerName(), '.');

            return name[0] + "-" + WEB_SESSION_COOKIE_NAME;
        }

        return WEB_SESSION_COOKIE_NAME;
    }
    
    /**
     * Creates the WebSession (pxt session) cookie with the given id.
     * 
     * @param sessionId WebSession (pxt session) id.
     * @param timeout lifespan of cookie in seconds.
     * @return The WebSession (pxt session) cookie.
     */
    // TODO Write unit tests for createWebSessionCookie(Long, int)
    public Cookie createWebSessionCookie(Long sessionId, int timeout) {
        Cookie cookie = new Cookie(getWebSessionCookieName(), "");
        String sId = sessionId.toString();
        cookie.setValue(sId + "x" + SessionManager.generateSessionKey(sId));
        // Do NOT set the domain for the cookie. The default is to set
        // the _Host_ for the cookie from the request.getHost() method.
        // If we override this with setDomain, then cookie.setDomain will
        // add a "." to the start of the specified value (if it doesn't
        // exist), which means the cookie is good for the whole domain,
        // which isn't what the perl code does, so the LOGout doesn't work
        // properly.
        cookie.setDomain(request.getServerName());
        cookie.setPath("/");
        cookie.setMaxAge(timeout);
        cookie.setSecure(ConfigDefaults.get().isSSLAvailable());

        return cookie;
    }
        
    /**
     * Returns the value for the given named cookie, the value is cached in the
     * Request as an attribute.
     *
     * @param name of cookie
     * @return Value of cookie, or null if cookie is not found.
     */
    // TODO Write unit tests for getCookieValue(String)
    public String getCookieValue(String name) {
        String value = null;
        Cookie[] cookies = request.getCookies();
        if (cookies == null) {
            return null;
        }

        for (int i = 0; i < cookies.length; i++) {
            Cookie c = cookies[i];
            if (c.getName().equals(name)) {
                value = c.getValue();
                break;
            }
        }

        LOG.debug("Returning [" + value + "] for cookie named [" + name + "]");
        return value;
    }
    
    /**
     * Get the value for the lowest part of the list to display. This is
     * protected so that the setup actions can get this value for redirecting
     * the request.
     * @return the lowest value to display.
     */
    public String processPagination() {
        String lower;
        if (request.getParameter("First") != null || 
                request.getParameter("First.x") != null) {
            lower = request.getParameter("first_lower");
        }
        else if (request.getParameter("Prev") != null || 
                request.getParameter("Prev.x") != null) {
            lower = request.getParameter("prev_lower");
        }
        else if (request.getParameter("Next") != null ||
                request.getParameter("Next.x") != null) {
            lower = request.getParameter("next_lower");
        }
        else if (request.getParameter("Last") != null || 
                request.getParameter("Last.x") != null) {
            lower = request.getParameter("last_lower");
        }
        else {
            lower = request.getParameter("lower");
        }
        return lower;
    }
    
    /**
     * Creates a hashmap with pagination vars added.
     * @return Returns a new hashmap containing the parameters
     */
    // TODO Write unit tests for makeParamMapWithPagination()
    public Map makeParamMapWithPagination() {
        Map params = new HashMap();
        String lower = processPagination();

        if (lower != null && lower.length() > 0 && StringUtils.isNumeric(lower)) {
            params.put("lower", lower);
        }

        return params;
    }
    
    /**
     * Take a HttpServletRequest and build a self-link to the requested page and
     * include a name/value parameter. Won't re-append the parameter if adding
     * it is re-attempted.
     * 
     * @param name of parameter to add
     * @param value value of paramter
     * @return url that is built.
     */
    public String buildPageLink(String name, String value) {
        StringBuffer page = new StringBuffer((String)request
                .getAttribute("requestedUri"));

        if (request.getQueryString() != null) {
            int index = request.getQueryString().indexOf(name + "=");
            // if we already have this param in the query string we have to
            // reset it to the new value
            if (index >= 0) {
                Map parammap = new HashMap();
                String[] params = StringUtils.split(request.getQueryString(),
                        '&');
                // Convert the parameters into a map so we can
                // easily replace the value and reformat the query string.
                for (int i = 0; i < params.length; i++) {
                    String[] nameval = StringUtils.split(params[i], '=');
                    parammap.put(nameval[0], nameval[1]);
                }
                parammap.remove(name);
                parammap.put(name, value);
                page.append("?");
                Iterator i = parammap.keySet().iterator();
                while (i.hasNext()) {
                    String key = (String)i.next();
                    page.append(key + "=" + parammap.get(key));
                    if (i.hasNext()) {
                        page.append("&");
                    }
                }
            }
            else {
                page.append("?" + name + "=" + value + "&" + request.getQueryString());
                return page.toString();
            }
        }
        else {
            page.append("?" + name + "=" + value);
        }
        return page.toString();
    }
    
    /**
     * Copies an attached parameter to the attributes list
     * This is useful when we want to propagate a parameter 
     * that was passed to us, like sid   
     * @param paramId the param to copy
     */
    public void copyParamToAttributes(String paramId) {
        HttpServletRequest req = getRequest();
        String param = req.getParameter(paramId);
        
        if (param != null) {
            req.setAttribute(paramId, req.getParameter(paramId));
        }
    }
    
    /**
     * Examines a submit action of the name "dispatch" 
     * with the i18n'ed value of the key passed in.
     * This is useful for example in the following
     * scenario.. Lets say you have the following html input
     * <input type = "submit" name="dispatch" 
     *      value="rhn:localize('copy.to.local')"/>
     * Lets suppose 'copy.to.local' was the message key
     * you'd pass to localizationService if i18n'ing... 
     * Lets suppose the en_US value of copy.to.local = Copy To Local  
     * When the button is submitted, IE will submit
     *  "dispatch=Copy To Local"
     * This means in the submit action we need to i18n 
     * the button value again when doing a lookup...
     * This method is supposed to help there.. 
     * One can just do
     * if (requestContext.wasDispatched("copy.to.local"))
     * Alternatively one can also extend
     *  RhnLookupDispatchAction to achieve the same.   
     * @param messageKey the message key to be i18ned.
     * @return true if a "dispatch" parameter 
     *          was set and that equaled the i18ned
     *          value of the message key
     */
    public boolean wasDispatched(String messageKey) {
        HttpServletRequest req = getRequest();
        if (req.getParameter(DISPATCH) == null) {
            return false;
        }
        String action = req.getParameter(DISPATCH);
        LocalizationService ls = LocalizationService.getInstance();
        return ls.getMessage(messageKey).equals(action);
    }

    /**
     * Returns if javascript is enabled/not in this page.
     * This needs to be used in conjuction with rhn noscript 
     * taglib.. If you need to use this method add the following line
     * to your jsp after the form, so that it gets submitted
     * <rhn:noscript/> 
     * @return true if java script is enabled, false other wise.
     */
    public boolean isJavaScriptEnabled() {
        return !Boolean.TRUE.toString().equals(getParam(NO_SCRIPT, false));
    }
    
    /**
     * Simple util to check if the Form  on a page was submitted
     * This needs to be used in conjuction with rhn submitted 
     * taglib.. If you need to use this method add the following line
     * to your jsp after the form, so that it gets submitted
     * <rhn:submitted/> 
     * @return true if the form was submitted, false other wise
     */
    public boolean isSubmitted() {
        return Boolean.TRUE.toString().equals(getParam(RhnAction.SUBMITTED, false));
    }
    
    /**
     * verify that the request is a POST and throw an exception otherwise.
     */
    public void requirePost() {        
        if (!POST.equals(request.getMethod())) {
            throw new PermissionException(
                    LocalizationService.getInstance().getMessage("request.post.check"));
        }
    }
    
}
