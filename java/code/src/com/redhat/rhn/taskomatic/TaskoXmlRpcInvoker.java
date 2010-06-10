/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.taskomatic;

import org.apache.log4j.Logger;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.StringWriter;
import java.net.InetAddress;

import redstone.xmlrpc.XmlRpcServer;
import simple.http.ProtocolHandler;
import simple.http.Request;
import simple.http.Response;


/**
 * TaskoXmlRpcInvoker
 * @version $Rev$
 */
public class TaskoXmlRpcInvoker implements ProtocolHandler {

    private static Logger log = Logger.getLogger(TaskoXmlRpcInvoker.class);
    private XmlRpcServer server;

    /**
     * Constructor
     *
     * @param xmlrpcServer
     *            handles actual XML-RPC calls
     */
    public TaskoXmlRpcInvoker(XmlRpcServer xmlrpcServer) {
        server = xmlrpcServer;
    }

    public void handle(Request request, Response response) {
        String uri = request.getURI();
        InetAddress ip = request.getInetAddress();

        try {
            if (!uri.startsWith("/RPC2")) {
                log.info(uri);
                response.setCode(404);
                response.setText(uri);
                PrintStream out = response.getPrintStream();
                out.println("<html><body><title>Page not found</title>");
                out.println("<b>" + uri + " not found</b>");
                out.println("</body></html>");
                response.set("Content-Type", "text/html");
                out.flush();
                out.close();
            }
            else {
                InputStream in = request.getInputStream();
                StringWriter writer = new StringWriter();
                server.execute(in, writer);
                OutputStream out = response.getOutputStream();
                response.set("Content-Type", "text/xml");
                writer.flush();
                out.write(writer.getBuffer().toString().getBytes());
                out.flush();
                out.close();
            }
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        finally {
            try {
                response.commit();
            }
            catch (IOException e) {
                e.printStackTrace();
            }
        }



    }

}
