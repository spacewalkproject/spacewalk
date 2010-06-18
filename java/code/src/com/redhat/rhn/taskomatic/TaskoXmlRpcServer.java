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

import com.redhat.rhn.common.conf.Config;
import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.SocketAddress;
import java.net.UnknownHostException;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcServer;
import simple.http.connect.Connection;
import simple.http.connect.ConnectionFactory;


/**
 * TaskoXmlRpcServer
 * @version $Rev$
 */
public class TaskoXmlRpcServer {

    private int listenPort;
    private InetAddress listenAddress;
    private XmlRpcServer xmlrpcServer;
    private ServerSocket socket;

    /**
     * Constructor
     *
     * @param config
     *            dependency
     * @throws UnknownHostException
     *             if config contains bad rpc_address
     */
    public TaskoXmlRpcServer(Config config) throws UnknownHostException {
        listenPort = config.getInt("tasko_server.port", 2829);
        String addr = config.getString("tasko_server.host", "localhost");
        if (addr != null) {
            listenAddress = InetAddress.getByName(addr);
        }
    }

    /**
     * Starts the server
     * @throws RuntimeException something bad happened
     */
    public void start() {
        xmlrpcServer = new XmlRpcServer();
        xmlrpcServer.addInvocationHandler("tasko", new TaskoXmlRpcHandler());
        addTaskoSerializers();

        TaskoXmlRpcInvoker invoker = new TaskoXmlRpcInvoker(xmlrpcServer);
        Connection connection = ConnectionFactory.getConnection(invoker);
        try {
            socket = new ServerSocket();
            SocketAddress sockAddr = null;
            if (listenAddress != null) {
                sockAddr = new InetSocketAddress(listenAddress, listenPort);
            }
            else {
                sockAddr = new InetSocketAddress(listenPort);
            }
            socket.bind(sockAddr);
            connection.connect(socket);
        }
        catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Stops the server
     *
     * @throws IOException
     */
    public void stop() {
        try {
            socket.close();
        }
        catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void addTaskoSerializers() {
        for (Class clazz : TaskoSerializerRegistry.getSerializationClasses()) {
            try {
                xmlrpcServer.getSerializer().addCustomSerializer((XmlRpcCustomSerializer)clazz.newInstance());
            }
            catch (InstantiationException e) {
                e.printStackTrace(System.out);
            }
            catch (IllegalAccessException e) {
                e.printStackTrace(System.out);
            }
        }
    }
}
