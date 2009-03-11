/**
 * Copyright (c) 2009 Red Hat, Inc.
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

package org.cobbler;

import org.apache.log4j.Logger;

import java.net.MalformedURLException;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcFault;

/**
 * 
 * XMLRPCHelper - class that contains wraps calls to Redstone's XMLRPC client.
 * Intentionally implements the XMLRPCInvoker interface so we can also provide
 * a mock implementation to our unit tests so they don't require an actual cobbler
 * server.
 * @author paji
 * @version $Rev$
 */
public class CobblerConnection {
    private static final double COBBLER_VERSION = 1.6;
    private XmlRpcClient client;
    private String actualUrl;
    private static Logger log = Logger.getLogger(CobblerConnection.class);
    
    private String token;
    
    protected CobblerConnection() {
    }

    /**
     * Constructor to just connect the client to the server
     * NO token is setup.. Client has to call token
     * @param url  cobbler base url, example http://localhost 
     * @throws XmlRpcException if there some communication issue..
     */
    
    public CobblerConnection(String url) {
        try {
            actualUrl = adjustUrl(url);
            client = new XmlRpcClient(actualUrl, false);
        }
        catch (MalformedURLException e) {
            throw new XmlRpcException(e);
        }
    }    
    
    /**
     * Constructor to setup the client based on 
     * user name and password.. Connects to cobbler
     * and logs in the user right here to obtain the
     * token 
     * @param url  cobbler base url, example http://localhost 
     * @param user the username
     * @param pass the password
     * @throws XmlRpcException if there some communication issue..
     */
    public CobblerConnection(String url, String user, String pass) {
        this(url);
        login(user, pass);
    }

    /**
     * Constructor to setup the client based on 
     * the token itself.. Connects to cobbler. Idea here
     * is that if you have the xmlrpc token by logging in previously
     * you could use that here..
     * @param url cobbler base url, example http://localhost
     * @param tokenIn the token
     * @throws XmlRpcException if there some communication issue..
     */    
    public CobblerConnection(String url, String tokenIn) {
        this(url);
         token = tokenIn; 
    }    
    
    /**
     * Simple method to login in to cobbler with the given 
     * user name and password.. The returned token 
     * is stored in the connection itself so that it
     * could be used for futre operations.. It
     * is also returned if so needed. 
     * @param login user name
     * @param password password
     * @return the login token
     */
    public String login(String login, String password) {
        token = (String) invokeMethod("login", login, password);
        return token;
    }
    

    /**
     * Invoke an XMLRPC method.
     * @param procedureName to invoke
     * @param args to pass to method
     * @return Object returned.
     */
    private Object invokeMethod(String procedureName, List args) {
        log.debug("procedure: " + procedureName + " Orig ags: " + args);
        Object retval;
        try {
            log.debug("args array: " + args);
            retval = client.invoke(procedureName, args);
        } 
        catch (Exception e) {
            throw new XmlRpcException("XmlRpcException calling cobbler.", e);
        } 
        if (retval instanceof String) {
            retval = retval + "\n";
        }
        return retval;
    }

    /**
     * Invoke an XMLRPC method.
     * @param procedureName to invoke
     * @param args to pass to method
     * @return Object returned.
     */
    public Object invokeMethod(String procedureName, Object... args) {
        return invokeMethod(procedureName, Arrays.asList(args));
    }
    
    /**
     * Invoke an XMLRPC method, 
     * but this one appends the cobbler xmlrpc
     * token at the end of the args. Basically this
     * serves the majority of calls to cobbler
     *  where token is exxpected as the last param..
     * @param procedureName to invoke
     * @param args to pass to method
     * @return Object returned.
     * @throws XmlRpcException if any unexpected error occurs
     */
    public Object invokeTokenMethod(String procedureName, 
                                    Object... args) {
        List<Object> params = new LinkedList<Object>(Arrays.asList(args));
        params.add(token);
        return invokeMethod(procedureName, params);
    }
    
    /**
     * updates the token
     * @param tokenIn the cobbler auth token
     */
    public void setToken(String tokenIn) {
        token = tokenIn;
    }

    /**
     * Returns the actual cobbler server url including the suffix
     * @return the server URL
     */
    public String getUrl() {
        return actualUrl;
    }
    
    /**
     * Gets the cobbler version
     * @return the cobbler version.
     */
    public double getVersion() {
        return (Double)invokeMethod("version");
    }

    private String adjustUrl(String urlIn) {
        String url = urlIn + "/cobbler_api";
        try {
            XmlRpcClient baseClient = new XmlRpcClient(url, false);
            Double result = (Double)baseClient.invoke("version", Collections.EMPTY_LIST);
            if (result >= COBBLER_VERSION) {
                return url;
            }
            return url + "_rw";
        }
        catch (MalformedURLException e) {
            throw new XmlRpcException(e);
        }
        catch (redstone.xmlrpc.XmlRpcException e) {
            throw new XmlRpcException(e);
        }
        catch (XmlRpcFault e) {
            throw new XmlRpcException(e); 
        }        
    }
}
