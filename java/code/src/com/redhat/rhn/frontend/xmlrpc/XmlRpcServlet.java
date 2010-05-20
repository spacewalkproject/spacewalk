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

package com.redhat.rhn.frontend.xmlrpc;

import com.redhat.rhn.frontend.xmlrpc.serializer.SerializerFactory;

import org.apache.log4j.Logger;

import java.io.IOException;
import java.util.Iterator;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import redstone.xmlrpc.XmlRpcCustomSerializer;

/**
 * A basic servlet class that registers handlers for xmlrpc calls
 *
 * @version $Rev$
 * @todo pull in namespace + classes for handlers from, say, a properties file
 * @todo perhaps override doGet ??
 */
public class XmlRpcServlet extends HttpServlet {

    /** Comment for <code>serialVersionUID</code> */
    private static final long serialVersionUID = -9173485623604749521L;

    private static Logger log = Logger.getLogger(XmlRpcServlet.class);

    private RhnXmlRpcServer server;
    private HandlerFactory handlers;
    private SerializerFactory serializers;
    
    /**
     * Constructor which takes in HandlerFactory and SerializerFactory. The
     * HandlerFactory determines what methods are exposed and which handlers
     * "handle" those calls.  The SerializerFactory adds custom serializers
     * to the mix, extending the capabilities of the XMLRPC library.  
     * @param hf HandlerFactory to use.
     * @param sf SerializerFactory to use.
     */
    public XmlRpcServlet(HandlerFactory hf, SerializerFactory sf) {
        setup(hf, sf);
    }

    /**
     * default constructor
     */
    public XmlRpcServlet() {
    }

    private void setup(HandlerFactory hf, SerializerFactory sf) {
        handlers = hf;
        serializers = sf;
    }
    
    private void passControl(HttpServletRequest request,
                            HttpServletResponse response)
        throws ServletException, IOException {
        response.sendRedirect("/rhn/apidoc/index.jsp");
    }

    /**
     * initialize the servlet
     */
    public void init() {
        if (handlers == null) {
            HandlerFactory.setDefaultHandlerManifest(getServletConfig().
                                getInitParameter(HandlerFactory.HANDLER_MANIFEST));
            setup(new HandlerFactory(), new SerializerFactory());            
        }

        server = new RhnXmlRpcServer();
        
        registerInvocationHandlers(server);
        registerCustomSerializers(server);
        
        // enhancement: if we ever need more than one InvocationProcessor
        // we should use the ManifestFactory like we did above for the
        // handlers.
        server.addInvocationInterceptor(new LoggingInvocationProcessor());
    }
    
    private void registerCustomSerializers(RhnXmlRpcServer srvr) {
        if (serializers == null) {
            serializers = new SerializerFactory();
        }
        // find the configured serializers...
        for (Iterator i = serializers.getSerializers().iterator(); i.hasNext();) {
            srvr.getSerializer().addCustomSerializer(
                    (XmlRpcCustomSerializer) i.next());
        }       
    }

    private void registerInvocationHandlers(RhnXmlRpcServer srvr) {
        if (handlers == null) {
            handlers = new HandlerFactory();
        }

        // find the configured handlers...
        Iterator i = handlers.getKeys().iterator();
        while (i.hasNext()) {
            String namespace = (String)i.next();
            
            if (log.isDebugEnabled()) {
                log.debug("registerInvocationHandler: namespace [" + namespace +
                          "] handler [" + handlers.getHandler(namespace) + "]");
            }
            srvr.addInvocationHandler(namespace, handlers.getHandler(namespace));
        }
    }
    
    /**
     * executed when a get request happens
     *
     * @param request the request object
     * @param response the response object
     * @throws ServletException if an error occurs
     * @throws IOException if an error occurs
     */
    public void doGet(HttpServletRequest request,
                       HttpServletResponse response)
        throws ServletException, IOException {

        passControl(request, response);
    }

    /**
     * executed when a post request happens
     *
     * @param request the request object
     * @param response the response object
     * @throws ServletException if a read error occurs
     * @throws IOException if a read error occurs
     */
    public void doPost(HttpServletRequest request,
                       HttpServletResponse response)
        throws ServletException, IOException {

        if (log.isDebugEnabled()) {
            log.debug("Entered doPost");
        }
        
        if (request.getHeader("SOAPAction") != null) {
            passControl(request, response);
            return;
        }
        
        response.setContentType("text/xml");
        try {
            if (log.isDebugEnabled()) {
                log.debug("Passing control to XmlRpcServer.execute");
            }
            
            server.execute(request.getInputStream(),
                           response.getWriter(),
                           request.getRemoteAddr(), 
                           request.getLocalName(),
                           request.getProtocol());
            
            /*
             * jesusr - 2007.09.14
             * this is still the case
             * 
             * mbowman - 2005.10.06
             * Like we were raised in a barn, we are going to leave here without
             * flushing ;)
             * -- The current thinking is that Tocmat handles the outputStream
             * -- flushing and closing for us. This make sense since after this
             * -- method runs, the response still needs to go back up through
             * -- the filters and out. If things start breaking in the future,
             * -- this is a  good place to start looking.
             */
        }
        // As bad as this is, we have no choice, Marquee-xmlrpc throws
        // Throwable, so we have to catch it.
        catch (Throwable t) {
            // By the time we get here, it can't be a FaultException, so just
            // wrap it in a ServletException and toss.
            ServletException e = new ServletException("Throwable from XmlRpc", t);
            e.initCause(t);
            throw e;
        }
    }
}
