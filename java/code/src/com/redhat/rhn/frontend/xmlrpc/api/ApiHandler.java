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
package com.redhat.rhn.frontend.xmlrpc.api;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.HandlerFactory;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ApiHandler
 * Corresponds to API.pm in old perl code.
 * @version $Rev$
 * @xmlrpc.namespace api
 * @xmlrpc.doc Methods providing information about the API.
 */
public class ApiHandler extends BaseHandler {

    /**
     * Returns the server version.
     * @return Returns the server version.
     *
     * @xmlrpc.doc Returns the server version.
     * @xmlrpc.returntype string
     */
    public String systemVersion() {
        return Config.get().getString("web.version");
    }
    
    /**
     * Returns the api version. Called as: api.get_version
     * @return the api version.
     *
     * @xmlrpc.doc Returns the version of the API. Since Spacewalk 0.4
     * (Satellie 5.3) it is no more related to server version.
     * @xmlrpc.returntype string
     */
    public String getVersion() {
        return Config.get().getString("web.apiversion");
    }

    private Collection getNamespaces() {
        return new HandlerFactory().getKeys();
    }

    /** Lists available API namespaces
     * @param sessionKey session of the logged in user
     * @return map of API namespaces
     *
     * @xmlrpc.doc Lists available API namespaces
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     *   #array()
     *      #struct("namespace")
     *          #prop_desc("string", "namespace", "API namespace")
     *          #prop_desc("string", "handler", "API Handler")
     *     #struct_end()
     *   #array_end()
     */
    public Map getApiNamespaces(String sessionKey) {
        Map namespacesList = new HashMap();
        HandlerFactory hf = new HandlerFactory();

        Iterator i = getNamespaces().iterator();
        while (i.hasNext()) {
                String namespace = (String)i.next();
                namespacesList.put(namespace, StringUtil.getClassNameNoPackage(
                                                hf.getHandler(namespace).getClass()));
        }
        return namespacesList;
    }

    /**
     * Lists all available api calls grouped by namespace
     * @param sessionKey session of the logged in user
     * @return a map containing list of api calls for every namespace
     *
     * @xmlrpc.doc Lists all available api calls grouped by namespace
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     *   #array()
     *      #array()
     *          #struct("method_info")
     *              #prop_desc("string", "name", "method name")
     *              #prop_desc("string", "parameters", "method parameters")
     *              #prop_desc("string", "exceptions", "method exceptions")
     *              #prop_desc("string", "return", "method return type")
     *          #struct_end()
     *      #array_end()
     *   #array_end()
     */
    public Map getApiCallList(String sessionKey) {
        Map callList = new HashMap();
        HandlerFactory hf = new HandlerFactory();

        Iterator i = getNamespaces().iterator();
        while (i.hasNext()) {
                String namespace = (String)i.next();
            try {
                callList.put(namespace, getApiNamespaceCallList(sessionKey, namespace));
            }
            catch (ClassNotFoundException e) {
                callList.put(namespace, "notFound");
            }
        }
        return callList;
    }

    /**
     * Lists all available api calls for the specified namespace
     * @param sessionKey session of the logged in user
     * @param namespace namespace of interest
     * @return a map containing list of api calls for every namespace
     * @throws ClassNotFoundException if namespace isn't valid
     *
     * @xmlrpc.doc Lists all available api calls for the specified namespace
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "namespace")
     * @xmlrpc.returntype
     *   #array()
     *      #struct("method_info")
     *          #prop_desc("string", "name", "method name")
     *          #prop_desc("string", "parameters", "method parameters")
     *          #prop_desc("string", "exceptions", "method exceptions")
     *          #prop_desc("string", "return", "method return type")
     *     #struct_end()
     *   #array_end()
     */
    public Map getApiNamespaceCallList(String sessionKey, String namespace)
                                            throws ClassNotFoundException  {
        Class<? extends BaseHandler> handlerClass =
                                new HandlerFactory().getHandler(namespace).getClass();
        Map<String, Map<String, Object>> methods  =
                                new HashMap<String, Map<String, Object>>();

        for (Method method : handlerClass.getDeclaredMethods()) {

            if (0 != (method.getModifiers() & Modifier.PUBLIC)) {

                Map<String, Object> methodInfo = new HashMap<String, Object>();

                methodInfo.put("name", method.getName());

                List<String> paramList = new ArrayList<String>();
                String paramListString = "";
                for (Type paramType : method.getParameterTypes()) {
                    String paramTypeString = getType(paramType);
                    paramList.add(paramTypeString);
                    paramListString += "_" + paramTypeString;
                }
                methodInfo.put("parameters", paramList);

                Set<String> exceptList = new HashSet<String>();
                for (Class<?> exceptClass : method.getExceptionTypes()) {
                    exceptList.add(StringUtil.getClassNameNoPackage(exceptClass));
                }
                methodInfo.put("exceptions", exceptList);
                methodInfo.put("return", getType(method.getReturnType()));

                String methodName = namespace + "." +
                                    methodInfo.get("name") + paramListString;
                methods.put(methodName, methodInfo);
            }
        }
        return methods;
    }

    private String getType(Type classType) {
        if (classType.equals(String.class)) {
            return "string";
        }
        else if ((classType.equals(Integer.class)) ||
                 (classType.equals(int.class))) {
            return "int";
        }
        else if (classType.equals(Date.class)) {
            return "date";
        }
        else if (classType.equals(Boolean.class) ||
                 classType.equals(boolean.class)) {
            return "boolean";
        }
        else if (classType.equals(Map.class)) {
            return "struct";
        }
        else if ((classType.equals(List.class)) ||
                 (classType.equals(Set.class)) ||
                 (classType.toString().contains("class [L")) ||
                 (classType.toString().contains("class [I"))) {
            return "array";
        }
        else if (classType.toString().contains("class [B")) {
            return "base64";
        }
        else {
            return "struct";
        }
    }
}
