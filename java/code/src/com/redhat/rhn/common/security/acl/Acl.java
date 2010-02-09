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

package com.redhat.rhn.common.security.acl;

import com.redhat.rhn.common.IllegalRegexException;
import com.redhat.rhn.common.MethodInvocationException;
import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.log4j.Logger;
import org.apache.oro.text.regex.MalformedPatternException;
import org.apache.oro.text.regex.MatchResult;
import org.apache.oro.text.regex.Pattern;
import org.apache.oro.text.regex.PatternCompiler;
import org.apache.oro.text.regex.PatternMatcher;
import org.apache.oro.text.regex.Perl5Compiler;
import org.apache.oro.text.regex.Perl5Matcher;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.MethodDescriptor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeSet;

/**
 * Class for handling ACLs.
 * Register {@link AclHandler AclHandlers} with this class with
 * {@link #Acl(String[])} and/or {@link #registerHandler(String)}.
 * AclHandler implementations must have a no-arg constructor.
 * AclHandler methods  that begin with the prefix "acl" and have a signature
 * like the following are registered as ACL handler methods that can
 * be referenced in ACL strings.
 * <pre>
 *     public boolean aclXXXX(Object context, String params[]);
 * </pre>
 * or
 * <pre>
 *     public static boolean aclXXXX(Object context, String params[]);
 * </pre>
 * The handlers can then be referred to
 * in ACL strings when {@link #evalAcl} is called.
 *<p>
 *  ACL strings take the form:
 *  <pre>
 *  ACL         := EXPRESSION [; EXPRESSION; ]+
 *  EXPRESSION  := STATEMENT [ OR STATEMENT ]+
 *  </pre>
 *  A semicolon separating expressions implies an AND operation.
 *  <p>
 *  An expression uses AclHandlers registered through
 *  {@link #Acl(String[])} and/or {@link #registerHandler(String)}.
 *  ACL method names are changed to ACL handler names referenceable in
 *  expression using the following translation algorithm:
 *  <ul>
 *      <li>all letters are converted to lower case
 *      <li>words in the method name defined by mixedCase are separated
 *      by underscores (Example: aclCheckSomething()
 *      is referenced as check_something)
 *      <li>words can have all caps (Example: aclCheckURL() is referenced
 *      in an ACL expression as check_url)
 *  </ul>
 *  More examples:
 * <table>
 * <tr>
 *   <td>Method Name</td>     <td>ACL Handler Name</td>
 * </tr>
 * <tr>
 *   <td>aclFooBar</td>       <td>foo_bar</td>
 * </tr>
 * <tr>
 *   <td>aclTestSomeValue</td><td>test_some_value</td>
 * </tr>
 * <tr>
 *   <td>aclCheckXML</td>     <td>check_xml</td>
 * </tr>
 * <tr>
 *   <td>aclCheckXMLFile</td><td>check_xml_file</td>
 * </tr>
 * <tr>
 *   <td>aclXMLCheck</td><td>xml_check</td>
 * </tr>
 * </table>
 *
 *  The following demonstrates the use of the Acl class:
 *  <pre>
 *  Map context = new HashMap();
 *  context.put("thingamajig", "foo");
 *  context.put("doodad", "bar");
 *  context.put("widget", "baz");
 *
 *  ...
 *
 *  // we can register a default handler with the constructor that takes
 *  // an array of fully-qualified AclHandler implementations
 *  Acl acl = new Acl(
 *    new String[]{"com.redhat.rhn.security.acl.handlers.DefaultHandler"});
 *
 *  // and later register additional handlers
 *  acl.registerHandler("com.redhat.rhn.security.acl.handlers.MyHandler");
 *
 *  // all will return true
 *  boolean result = acl.evalAcl(context, "has_thingamajig(foo)");
 *  result = acl.evalAcl(context, "has_doodad(bar)");
 *  result = acl.evalAcl(context, "has_widget(baz)");
 *
 *  </pre>
 *  DefaultHandler:
 *  <pre>
 *  package com.redhat.rhn.security.acl.handlers;
 *
 *  import com.rhn.redhat.security.acl.AclHandler;
 *
 *  public class DefaultHandler implements AclHandler {
 *      // return true if the context has the specified thingamajig
 *      public boolean aclHasThingmajig(Object context, String[] params) {
 *          Map map = (Map)context;
 *          String thingamajig = (String)map.get("thingamajig");
 *          return thingamajig.equals(params[0]);
 *      }
 *  }
 *  </pre>
 *  MyHandler:
 *  <pre>
 *  package com.redhat.rhn.security.acl.handlers;
 *
 *  import com.rhn.redhat.security.acl.AclHandler;
 *
 *  public class MyHandler implements AclHandler {
 *      // return true if the context has the specified doodad
 *      public boolean aclHasDooDad(Object context, String[] params) {
 *          Map map = (Map)context;
 *          String doodad = (String)map.get("doodad");
 *          return doodad.equals(params[0]);
 *      }
 *      // return true if the context has the specified widget
 *      public boolean aclHasWidget(Object context, String[] params) {
 *          Map map = (Map)context;
 *          String widget = (String)map.get("widget");
 *          return widget.equals(params[0]);
 *      }
 *  }
 *  </pre>
 * @version $Rev$
 */
public class Acl {

    /** RegEx to split ACL into multiple expressions */
    private static final String ACL_SPLIT_REGEX = "\\s*;\\s*";

    /** RegEx to split expressions into multiple statements */
    private static final String EXPR_SPLIT_REGEX = "\\s+or\\s+";

    /** RegEx to parse statement to grab negation, function call, params */
    private static final String STMT_PARSE_REGEX = "^(not +)?(.*)\\((.*)\\)$";

    /** RegEx to split params */
    private static final String PARAM_SPLIT_REGEX = "\\s*,\\s*";

    /** constant used to identify negation regex group within statement */
    private static final int NEGATION_GROUP = 1;
    /** constant used to identify handler name regex group within statement */
    private static final int HANDLERNAME_GROUP = 2;
    /** constant used to identify param regex group within statement */
    private static final int PARAM_GROUP = 3;
    /** total number of regex groups expected in statement */
    private static final int EXPECTED_GROUPS = 4;

    /** prefix of acl handler method names */
    private static final String ACL_PREFIX = "acl";

    /** The log instance for this class */
    private static Logger log = Logger.getLogger(Acl.class);

    /** Store acl handlers against keys referenced in acl statements */
    private Map handlers = new HashMap();

    /** store the compiled regex that will be re-used for evalAcl invocations */
    private static Pattern parsePattern = null;

    // initialize the parse pattern
    static {
        PatternCompiler compiler = new Perl5Compiler();
        try {
            parsePattern = compiler.compile(STMT_PARSE_REGEX);
        }
        catch (MalformedPatternException e) {
            // we assume our regex is sane and tested
            // and that we don't get here
            throw new IllegalRegexException("Invalid when constructing parse " +
                                            "pattern for acls.", e);
        }
    }

    /** Constructor for a new Acl instance without any default ACL handlers. */
    public Acl() {
        // default constructor with no acl handlers
    }

    /** Creates a new Acl instance with the specified default ACL handler
     * classes.
     * @param defaultHandlerClasses an array of handler classes. Each entry
     * must be a fully-qualified name of an implementation of
     * {@link AclHandler}
     * @see #registerHandler(String)
     * @see #registerHandler(Class)
     * @see #registerHandler(AclHandler)
     * */
    public Acl(String[] defaultHandlerClasses) {
        for (int i = 0; i < defaultHandlerClasses.length; ++i) {
            registerHandler(defaultHandlerClasses[i]);
        }
    }

    /** Register an AclHandler class.
     * @param aclClassname fully-qualified classname of an {@link AclHandler}
     * implementation
     * @see #registerHandler(AclHandler)
     */
    public void registerHandler(String aclClassname) {
        try {
            Class clazz = Class.forName(aclClassname);
            registerHandler(clazz);
        }
        catch (ClassNotFoundException e) {
            IllegalArgumentException exc =
                new IllegalArgumentException("class not found: " + aclClassname);
            exc.initCause(e);
            throw exc;
        }
    }

    /** Register an AclHandler class.
     * @param aclClazz an {@link AclHandler} implementation
     * @see #registerHandler(AclHandler)
     */
    public void registerHandler(Class aclClazz) {
        try {
            if (!AclHandler.class.isAssignableFrom(aclClazz)) {
                throw new IllegalArgumentException(
                    LocalizationService.getInstance().getMessage("bad-class",
                        aclClazz.getName()));
            }
            AclHandler instance = (AclHandler)aclClazz.newInstance();
            registerHandler(instance);
        }
        catch (InstantiationException e) {
            IllegalArgumentException exc = new IllegalArgumentException();
            exc.initCause(e);
            throw exc;
        }
        catch (IllegalAccessException e) {
            IllegalArgumentException exc = new IllegalArgumentException();
            exc.initCause(e);
            throw exc;
        }
    }

    /** Register an AclHandler.
     * All methods with the valid signature will be registered.
     * <pre>
     *     public boolean aclXXX(Object, String[])
     * </pre>
     * or
     * <pre>
     *     public static boolean aclXXX(Object, String[])
     * </pre>
     * Methods without the "acl" prefix are ignored. If a method begins
     * with the "acl" prefix but the method signature is invalid, a
     * warning is logged and the method is ignored.
     *
     * @param aclHandler AclHandler
     */
    public void registerHandler(AclHandler aclHandler) {

        try {
            Class clazz = aclHandler.getClass();
            // find all the acl* methods. and store them
            BeanInfo info = Introspector.getBeanInfo(clazz);
            MethodDescriptor[] methodDescriptors = info.getMethodDescriptors();

            for (int i = 0; i < methodDescriptors.length; ++i) {

                MethodDescriptor methodDescriptor = methodDescriptors[i];
                String methodName = methodDescriptor.getName();

                // we only care about methods with signatures:
                // public boolean aclXXX(Object obj, String[] params);
                if (!methodName.startsWith(ACL_PREFIX)) {
                    continue;
                }
                Method method = methodDescriptor.getMethod();
                Class[] params = method.getParameterTypes();
                if (!method.getReturnType().equals(Boolean.TYPE) ||
                   method.getExceptionTypes().length > 0 ||
                   params.length != 2 ||
                   !params[0].equals(Object.class) ||
                   !params[1].equals(String[].class)) {
                   log.warn(LocalizationService.getInstance().getMessage(
                                "bad-signature", method.toString()));

                   continue;

                }

                String aclName = methodNameToAclName(methodName);
                handlers.put(aclName,
                        new InstanceMethodPair(aclHandler, method));
            }
        }
        // from reading the javadocs for IntrospectionException,
        // dont' really expect to get this one
        catch (IntrospectionException e) {
            IllegalArgumentException exc = new IllegalArgumentException();
            exc.initCause(e);
            throw exc;
        }

    }

    /** 
     * Creates an ACL handler name from an ACL method name.
     * See class description for sample conversions.
     * @param name The ACL name to convert
     * @return The corresponding method name.
     */
    private String methodNameToAclName(String name) {

        StringBuffer ret = new StringBuffer();
        boolean lastWasLower = false;

        ret.append(Character.toLowerCase(name.charAt(ACL_PREFIX.length())));
        for (int i = ACL_PREFIX.length() + 1; i < name.length(); ++i) {
            char ch = name.charAt(i);
            boolean nextIsLower = false;
            if (i + 1 < name.length()) {
                nextIsLower = Character.isLowerCase(name.charAt(i + 1));
            }
            if (Character.isUpperCase(ch)) {
                if (lastWasLower || nextIsLower) {
                    ret.append('_');
                }
                ret.append(Character.toLowerCase(ch));
                lastWasLower = false;
            }
            else {
                lastWasLower = true;
                ret.append(ch);
            }
        }
        return ret.toString();
    }

    /** Returns the set of registered ACL handler names.
     *  @return set of handler names usable in an ACL string
     * */
    public TreeSet getAclHandlerNames() {
        return new TreeSet(handlers.keySet());
    }

    /** Evaluates an ACL string within a given context.
     *  See class description for sample usage.
     *  @param context context in which the acl string is evaluated
     *  @param acl the ACL string.
     *  @return true if the ACL string and given context allow access,
     *  false otherwise
     *  @see AclHandler
     */
    public boolean evalAcl(Object context, String acl) {

        if (log.isDebugEnabled()) {
            log.debug("acl: " + acl);
        }
        
        // protect against nulls.
        if (acl == null) {
            throw new IllegalArgumentException(
                          LocalizationService.getInstance().getMessage(
                             "bad-syntax", acl));
        }
        
        String[] expressions = acl.split(ACL_SPLIT_REGEX);
        int exprLen = expressions.length;

        boolean result = false;

        PatternMatcher matcher = new Perl5Matcher();

        for (int exprIdx = 0; exprIdx < exprLen; ++exprIdx) {

            String expression = expressions[exprIdx];

            if (log.isDebugEnabled()) {
                log.debug("expression[" + exprIdx + "]: " + expression);
            }

            String[] statements = expression.split(EXPR_SPLIT_REGEX);
            int statementLen = statements.length;

            for (int stmtIdx = 0; stmtIdx < statementLen; ++stmtIdx) {

                String statement = statements[stmtIdx];

                if (log.isDebugEnabled()) {
                    log.debug("statement[" + stmtIdx + "]: " + statement);
                }

                boolean itMatches = matcher.matches(statement, parsePattern);
                MatchResult matchResult = matcher.getMatch();
                if (!itMatches || matchResult == null || matchResult.groups() <
                        EXPECTED_GROUPS) {
                    throw new IllegalArgumentException(
                                  LocalizationService.getInstance().getMessage(
                                     "bad-syntax", statement));
                }

                if (log.isDebugEnabled()) {
                    log.debug("num groups: " + matchResult.groups());
                    log.debug("not: " + matchResult.group(NEGATION_GROUP));
                    log.debug("handler: " +
                            matchResult.group(HANDLERNAME_GROUP));
                    log.debug("params: " + matchResult.group(PARAM_GROUP));
                }

                boolean negated = matchResult.group(NEGATION_GROUP) != null;

                String func = matchResult.group(HANDLERNAME_GROUP);

                String params = matchResult.group(PARAM_GROUP);

                InstanceMethodPair pair =
                    (InstanceMethodPair)handlers.get(func);

                if (pair == null) {
                    Object[] args = new Object[3];
                    args[0] = func;
                    args[1] = statement;
                    args[2] = new TreeSet(handlers.keySet()).toString();
                    throw new IllegalArgumentException(
                        LocalizationService.getInstance().getMessage(
                            "bad-handler", args));
                }

                Method handler = pair.getMethod();

                String[] paramArray = params.split(PARAM_SPLIT_REGEX);

                // if no args were givien, make sure we pass a 0-length array
                if (paramArray.length == 1 && paramArray[0].trim().equals("")) {
                    paramArray = new String[0];
                }

                try {
                    result = ((Boolean)handler.invoke(pair.getInstance(),
                        new Object[] {context, paramArray })).booleanValue();
                }
                // we shouldn't hit any of these exceptions, because the
                // handler classes should have been adequately junit-tested
                catch (IllegalAccessException iae) {
                    Object[] args = new Object[3];
                    args[0] = handler.getName();
                    args[1] = statement;
                    args[2] = iae.getMessage();

                    throw new MethodInvocationException(
                        LocalizationService.getInstance().getMessage(
                        "illegal-access", args), iae);
                }
                catch (InvocationTargetException ite) {
                    Object[] args = new Object[3];
                    args[0] = handler.getName();
                    args[1] = statement;
                    args[2] = ite.getMessage();

                    throw new MethodInvocationException(
                        LocalizationService.getInstance().getMessage(
                        "invocation-target-exception", args), ite);
                }

                if (negated) {
                    result = !result;
                }

                // break if we hit true, since we're in an or's loop
                if (result) {
                    break;
                }
            }

            // if we got a false, then return that, because we're in an
            // and loop
            if (!result) {
                return result;
            }

        }

        // if we got this far, all acl's passed
        if (log.isDebugEnabled()) {
            log.debug("acl: " + acl + " returning true");
        }
        return true;

    }

    private static class InstanceMethodPair {
        private Method method;
        private Object instance;
        /**
         * Create a new InstanceMethodPair
         * @param obj The object on which to call the method
         * @param meth The method to call
         */
        public InstanceMethodPair(Object obj, Method meth) {
            instance = obj;
            method = meth;
        }
        /**
         * Get the object on which to invoke the method
         * @return the object on which to invoke the method
         */
        public Object getInstance() {
            return instance;
        }
        /**
         * Get the method
         * @return the Method to invoke
         */
        public Method getMethod() {
            return method;
        }
    }
}
