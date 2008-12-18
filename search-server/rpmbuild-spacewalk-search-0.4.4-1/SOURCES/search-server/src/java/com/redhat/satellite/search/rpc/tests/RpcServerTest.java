package com.redhat.satellite.search.rpc.tests;

import com.redhat.satellite.search.rpc.RpcServer;
import com.redhat.satellite.search.tests.BaseTestCase;
import com.redhat.satellite.search.tests.TestUtil;

public class RpcServerTest extends BaseTestCase {
    @SuppressWarnings("unchecked")
    @Override
    protected Class[] getComponentClasses() {
        return TestUtil.buildComponentsList(RpcServer.class);
    }
    
    public void testStopServer() {
        RpcServer server = (RpcServer)
            container.getComponentInstanceOfType(RpcServer.class);
        server.stop();
    }
}
