/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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

package com.redhat.rhn.frontend.xmlrpc;

import java.io.IOException;
import java.io.StringReader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;
import org.xml.sax.SAXException;
import org.hibernate.HibernateException;

import redstone.xmlrpc.XmlRpcFault;
import redstone.xmlrpc.XmlRpcInvocationHandler;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.client.ClientCertificate;
import com.redhat.rhn.common.client.ClientCertificateDigester;
import com.redhat.rhn.common.client.InvalidCertificateException;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.translation.Translator;
import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.session.SessionManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * A basic xmlrpc handler class.  Uses reflection + an arbitrary algorithm
 * to call the appropriate method on a subclass.  So, an xmlrpc call to
 * 'registration.privacy_message' might call
 * RegistrationHandler.privacyMessage
 */
public class BaseHandler implements XmlRpcInvocationHandler {
    public static final int VALID = 1;

    private static Logger log = Logger.getLogger(BaseHandler.class);

    private static final String RO_REGEX = "^(list|get|is|find).*$";
    private static final String KEY_REGEX = "^[1-9][0-9]*x[a-f0-9]{64}$";

    protected boolean providesAuthentication() {
        return false;
    }

    /**
     * called by BaseHandler.doPost, contains the code that determines what
     * method to call of a subclassed-object
     *
     * @param methodCalled the xmlrpc function called, like
     *                     'registration.privacy_statement'
     * @param params a Vector of the parameters to methodCalled
     * @return the results of the method of the subclass
     * @exception XmlRpcFault if some error occurs
     */
    public Object invoke(String methodCalled, List params) throws XmlRpcFault {
        Class myClass = this.getClass();
        Method[] methods;
        try {
            methods = myClass.getMethods();
        }
        catch (SecurityException e) {
            // This should _never_ happen, because the Handler classes must
            // have public classes if they're expected to work.
            throw new XmlRpcFault(-1, "no public methods in class " + myClass);
        }

        String[] byNamespace = methodCalled.split("\\.");
        String beanifiedMethod = StringUtil.beanify(byNamespace[byNamespace.length - 1]);
        WebSession session = null;

        if (params.size() > 0 && params.get(0) instanceof String &&
                isSessionKey((String)params.get(0))) {
            if (!myClass.getName().endsWith("AuthHandler") &&
                !myClass.getName().endsWith("SearchHandler")) {
                session = SessionManager.loadSession((String)params.get(0));
                params.set(0, getLoggedInUser((String)params.get(0)));
                if (((User)params.get(0)).isReadOnly()) {
                    if (!beanifiedMethod.matches(RO_REGEX)) {
                        throw new SecurityException("The " + beanifiedMethod +
                                " API is not available to read-only API users");
                    }
                }
            }
        }

        //we've found all the methods that have the same number of parameters
        List<Method> matchedMethods = findMethods(methods, params, beanifiedMethod);

        //Attempt to find a perfect match
        Method foundMethod = findPerfectMethod(params, matchedMethods);

        Object[] converted = params.toArray();


        //If we were not able to find the exact method match, let's just use the first one
        //      This isn't the best method, but if you can figure out a better way
        //      that is easy feel free to change.
        //Since it is not an exact match, we have to translate the params.
        if (foundMethod == null) {
            foundMethod = matchedMethods.get(0);
            Class[] types = foundMethod.getParameterTypes();

            Iterator iter = params.iterator();
            for (int i = 0; i < types.length; i++) {
                Object curr = iter.next();
                if (!types[i].equals(curr.getClass())) {
                    converted[i] = Translator.convert(curr, types[i]);
                }
            }
        }

        try {
            return foundMethod.invoke(this, converted);
        }
        catch (IllegalAccessException e) {
            throw new XmlRpcFault(-1, "unhandled internal exception");
        }
        catch (InvocationTargetException e) {
            Throwable t = e.getCause();
            log.error("Error calling method: ", e);
            log.error("Caused by: ", t);

            /*
             * HACK: this should really be handled by SessionFilter.doFilter,
             * but unfortunately Redstone XMLRPC swallows our exceptions (see
             * XmlRpcDispatcher.dispatch()). Thus doFilter will never be reached
             * with exceptions, and will always COMMIT the transaction. To avoid
             * committing changes after an Exception, roll back here.
             */
            try {
                log.error("Rolling back transaction");
                HibernateFactory.rollbackTransaction();
            }
            catch (HibernateException he) {
                log.error("Additional error during rollback", he);
            }

            // This works because FaultException extends XmlRpcFault, so
            // we are telling the XMLRPC library to send a fault to the client.
            if (t instanceof FaultException) {
                FaultException fe = (FaultException)t;
                throw new XmlRpcFault(fe.getErrorCode(), fe.getMessage());
            }
            // If it isn't a FaultException that caused this, we still need to
            // send something to the client.
            Throwable cause = e.getCause();
            // If we can get the cause of the exception, then display the message
            if (cause != null) {
                throw new XmlRpcFault(-1, "unhandled internal exception: " +
                      cause.getLocalizedMessage());
            }
            // Otherwise, throw the generic unhandled internal exception
            throw new XmlRpcFault(-1, "unhandled internal exception");
        }
        finally {
            if (session != null) {
                SessionManager.extendSessionLifetime(session);
            }
        }
    }

    /**
     * Finds the perfect match for a method based upon type
     * @param params The parameters to find the match for.
     * @param matchedMethods the list of methods to check for a perfect match
     * @return null if no perfect match was found, otherwise the matched method.
     */
    private Method findPerfectMethod(List params, List<Method> matchedMethods) {
        //now lets try to find one that matches parameters exactly
        for (Method currMethod : matchedMethods) {
            Class[] types = currMethod.getParameterTypes();
            for (int i = 0; i < types.length; i++) {
                //if we find a param that doesn't match, go to the next method
                if (!types[i].isAssignableFrom(params.get(i).getClass())) {
                    break;
                }
                //if we have gone through all of the params, and are here it is a
                //      perfect match.
                if (i == types.length - 1) {
                    return currMethod;
                }
            }
        }
        return null;
    }

    /**
     * Private method to find the method in the java class that is being called
     * via xml-rpc
     * @param methods The methods contained in the class
     * @param params The parameters sent to us via xml-rpc
     * @param beanifiedMethod The method name we are looking for
     * @return The matching method we're looking for
     * @throws XmlRpcFault Thrown if we can't find the method asked for
     */
    /*
     * TODO: Make this method even smarterer.
     *      Currently this finds methods that match the number of parameters and returns
     *          those.
     */
    private List<Method> findMethods(Method[] methods, Collection params,
            String beanifiedMethod) throws XmlRpcFault {

        List<Method> toReturn = new ArrayList<Method>();

        //Loop through the methods array and find the one we are trying to call.
        for (int i = 0; i < methods.length; i++) {
            if (methods[i].getName().equals(beanifiedMethod)) {
                // We found a method with the right name, but does the parameter count
                // match?
                int numberOfParams = methods[i].getParameterTypes().length;
                if (numberOfParams == params.size()) {
                    //Method name and number of parameters match.
                    toReturn.add(methods[i]);
                }
            }
        }
        if (toReturn.isEmpty()) {
            //The caller didn't get the method name or number of parameters right
            String message = "Could not find method: " + beanifiedMethod +
            " in class: " + this.getClass().getName() + " with params: [";
            for (Iterator iter = params.iterator(); iter.hasNext();) {
                Object param = iter.next();
                message += (param.getClass().getName());
                    if (iter.hasNext()) {
                        message = message + ", ";
                    }
            }
            message = message + "]";
            throw new XmlRpcFault(-1, message);
        }
        return toReturn;
    }

    /**
     * Gets the currently logged in user. This is all done through the sessionkey we send
     * the user in AuthHandler.login.
     * @param sessionKey The key containing the session id that we can use to load the
     * session.
     * @return Returns the user logged into the session corresponding to the given
     * sessionkey.
     */
    public static User getLoggedInUser(String sessionKey) {
        //Load the session
        WebSession session = SessionManager.loadSession(sessionKey);
        User user = session.getUser();

        //Make sure there was a valid user in the session. If not, the session is invalid.
        if (user == null) {
            throw new LookupException("Could not find a valid user for session with key: " +
                                      sessionKey);
        }

        //Return the logged in user
        return user;
    }

    /**
     * Private helper method to make sure a user has org admin role. If not, this will
     * throw a generic Permission exception.
     * @param user The user to check
     * @throws PermissionCheckFailureException if user is not an org admin
     */
    public static void ensureOrgAdmin(User user) throws PermissionCheckFailureException {
        ensureUserRole(user, RoleFactory.ORG_ADMIN);
    }

    /**
     * Private helper method to make sure a user has sat admin role. If not, this will
     * throw a generic Permission exception.
     * @param user The user to check
     * @throws PermissionCheckFailureException if user is not an sat admin
     */
    public static void ensureSatAdmin(User user) throws PermissionCheckFailureException {
        ensureUserRole(user, RoleFactory.SAT_ADMIN);
    }

    /**
     * Private helper method to make sure a user has system group admin role.
     * If not, this will throw a generic Permission exception.
     * @param user The user to check
     * @throws PermissionCheckFailureException if user is not a system group admin
     */
    public static void ensureSystemGroupAdmin(User user)
        throws PermissionCheckFailureException {
        ensureUserRole(user, RoleFactory.SYSTEM_GROUP_ADMIN);
    }

    /**
     * Private helper method to make sure a user has config admin role.
     * If not, this will throw a generic Permission exception.
     * @param user The user to check
     * @throws PermissionCheckFailureException if user is not a config admin.
     */
    public static void ensureConfigAdmin(User user)
        throws PermissionCheckFailureException {
        ensureUserRole(user, RoleFactory.CONFIG_ADMIN);
    }

    /**
     * Public helper method to make sure a user has either
     * an org admin or a config admin role
     * If not, this will throw a generic Permission exception.
     * @param user The user to check
     * @throws PermissionCheckFailureException if user is neither org nor config admin.
     */
    public static void ensureOrgOrConfigAdmin(User user)
        throws PermissionCheckFailureException {
        if (!user.hasRole(RoleFactory.ORG_ADMIN) &&
                !user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionCheckFailureException(RoleFactory.ORG_ADMIN,
                    RoleFactory.CONFIG_ADMIN);
        }
    }

    /**
     * Private helper method to make sure a user  the given role..
     * If not, this will throw a generic Permission exception.
     * @param user The user to check
     * @param role the role to check
     * @throws PermissionCheckFailureException if user does not
     *                      have the given role
     */
    public static void ensureUserRole(User user, Role role)
        throws PermissionCheckFailureException {
        if (!user.hasRole(role)) {
            throw new PermissionCheckFailureException(role);
        }
    }

    /**
     * Ensure the org exists
     * @param orgId the org id to check
     * @return the org
     */
    protected Org verifyOrgExists(Number orgId) {
        if (orgId == null) {
            throw new NoSuchOrgException("null Id");
        }
        Org org = OrgFactory.lookupById(orgId.longValue());
        if (org == null) {
            throw new NoSuchOrgException(orgId.toString());
        }
        return org;
    }

    /**
     * Validate the requested entitlements. At this juncture only the add-on entitlements
     * are to be set via the API.
     *
     * @param entitlements List of string entitlement labels to be validated.
     */
    protected void validateEntitlements(List<String> entitlements) {

        for (String e : entitlements) {
            Entitlement ent = EntitlementManager.getByName(e);
            if ((ent == null) || (!ent.isSatelliteEntitlement())) {
                throw new InvalidEntitlementException();
            }
        }
    }

    /**
     * Validate that the keys provided in the map provided
     * by the user are valid.
     * @param validKeys Set of keys that are valid for this request
     * @param map The map to validate
     */
    protected void validateMap(Set<String> validKeys, Map map) {
        String errors = null;
        for (Iterator it = map.keySet().iterator(); it.hasNext();) {
            String key = (String) it.next();

            if (!validKeys.contains(key)) {
                // user passed an invalid key...
                if (errors == null) {
                    errors = new String(key);
                }
                else {
                    errors += ", " + key;
                }
            }
        }
        if (errors != null) {
            // at least one invalid key was found...
            throw new InvalidArgsException(errors);
        }
    }

    /**
     * Take an attributeName and value, and apply them to an Object.
     * Takes advantage of introspection and bean-stds to decide what call to make
     * @param attrName Attribute to set - assumes entity.set<Attrname>(value) exists
     * @param entity The Object we are updating
     * @param value The new value to pass to set<AttrName>
     */
    protected void setEntityAttribute(String attrName, Object entity, Object value) {
        String methodName = StringUtil.beanify("set_" + attrName);
        Object[] params = {
            value
        };
        MethodUtil.callMethod(entity, methodName, params);
    }


    protected Server validateClientCertificate(String clientCert) {
        StringReader rdr = new StringReader(clientCert);
        Server server = null;

        ClientCertificate cert;
        try {
            cert = ClientCertificateDigester.buildCertificate(rdr);
            server = SystemManager.lookupByCert(cert);
        }
        catch (IOException ioe) {
            log.error("IOException - Trying to access a system with an " +
                    "invalid certificate", ioe);
            throw new MethodInvalidParamException();
        }
        catch (SAXException se) {
            log.error("SAXException - Trying to access a " +
                    "system with an invalid certificate", se);
            throw new MethodInvalidParamException();
        }
        catch (InvalidCertificateException e) {
            log.error("InvalidCertificateException - Trying to access a " +
                    "system with an invalid certificate", e);
            throw new MethodInvalidParamException();
        }
        if (server == null) {
            throw new NoSuchSystemException();
        }

        return server;
    }

    private boolean isSessionKey(String string) {
        return string.matches(KEY_REGEX);
    }

}
