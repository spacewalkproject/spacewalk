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

package com.redhat.rhn.frontend.xmlrpc.test;

import com.redhat.rhn.common.util.manifestfactory.ManifestFactoryLookupException;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.HandlerFactory;
import com.redhat.rhn.frontend.xmlrpc.channel.ChannelHandler;
import com.redhat.rhn.frontend.xmlrpc.channel.software.ChannelSoftwareHandler;
import com.redhat.rhn.testing.RhnBaseTestCase;

public class HandlerFactoryTest extends RhnBaseTestCase {
    private HandlerFactory factory = null;
    
    public void setUp() {
        factory = new HandlerFactory();
    }
    
    public void testHandlerFactoryNotFound() {
        try {
            factory.getHandler("NoHandler");
            fail("Should have received an exception.");
        }
        catch (ManifestFactoryLookupException e) {
            // Expected exception, NoHandler doesn't exist.
        }
    }

    public void testHandlerFactory() {
        BaseHandler handler = factory.getHandler("channel");
        assertEquals(ChannelHandler.class, handler.getClass());
    }
    
    public void testDescendingClass() {
        BaseHandler handler = factory.getHandler("channel.software");
        assertNotNull(handler);
        assertEquals(ChannelSoftwareHandler.class, handler.getClass());
    }
}
