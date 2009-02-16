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
package com.redhat.rhn.frontend.struts.test;

import com.redhat.rhn.frontend.struts.StrutsDelegateImpl;
import com.redhat.rhn.testing.RhnMockDynaActionForm;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.DynaActionForm;

import junit.framework.TestCase;

/**
 * StrutsDelegateImplTest
 * @version $Rev$
 */
public class StrutsDelegateImplTest extends TestCase {
    
    private class StrutsDelegateImplStub extends StrutsDelegateImpl {
    }

    /**
     * @param name The name of the TestCase
     */
    public StrutsDelegateImplTest(String name) {
        super(name);
    }
    
    /**
     * 
     */
    public final void testForwardParams() {
        ActionForward success = new ActionForward("default", "path", false);
        
        StrutsDelegateImpl strutsDelegate = new StrutsDelegateImplStub();
        
        ActionForward fwdWithParams = strutsDelegate.forwardParam(success, "foo", "bar");
        assertEquals(success.getName(), fwdWithParams.getName());
        assertEquals(fwdWithParams.getPath(), "path?foo=bar");
    }
    
    /**
     * 
     */
    public void testGetTextAreaValue() {
        String value = "asdf\r\nasdfwerwer\rasdf\n\radsfhjhhasdf";
        DynaActionForm form = new RhnMockDynaActionForm();
        form.set("somevalue", value);
        
        StrutsDelegateImpl strutsDelegate = new StrutsDelegateImplStub();
        
        String stripped = strutsDelegate.getTextAreaValue(form, "somevalue");
        assertNotNull(stripped);
        assertTrue(stripped.indexOf('\r') == -1);
    }

}
