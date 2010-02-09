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
package com.redhat.rhn.frontend.taglibs.test;

import com.redhat.rhn.domain.rhnset.RhnSetImpl;
import com.redhat.rhn.frontend.taglibs.ListDisplayTag;
import com.redhat.rhn.frontend.taglibs.SetTag;
import com.redhat.rhn.testing.RhnBaseTestCase;

import com.mockobjects.helpers.TagTestHelper;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * SetTagTest
 * @version $Rev: 1743 $
 */
public class SetTagTest extends RhnBaseTestCase {
    
    public void testCopyConstructor() {
        SetTag ct = new SetTag();
        ct.setHeader("header");
        ct.setStyle("10");
        ct.setCssClass("first-column");
        ct.setUrl("http://www.hostname.com");
        ct.setWidth("10%");
        ct.setValue("42");
       
        SetTag copy = new SetTag(ct);
        assertEquals(ct, copy);
    }
    
    public void testEquals() {
        SetTag ct = new SetTag();
        ct.setHeader("header");
        ct.setStyle("10");
        ct.setCssClass("first-column");
        ct.setUrl("http://www.hostname.com");
        ct.setWidth("10%");
        ct.setValue("42");      
        
        SetTag ct1 = new SetTag();
        ct1.setHeader("header");
        ct1.setStyle("10");
        ct1.setCssClass("first-column");
        ct1.setUrl("http://www.hostname.com");
        ct1.setWidth("10%");
        ct1.setValue("42");
        
        assertTrue(ct.equals(ct1));
        assertTrue(ct1.equals(ct));
        
        ct1.setUrl(null);
        assertTrue(ct.equals(ct1));
        assertTrue(ct1.equals(ct));
    }
    
    public void testSettersGetters() {
        SetTag ct = new SetTag();
        ct.setValue("42");     
        
        assertEquals("42", ct.getValue());        
        assertNull(ct.getParent());
    }

    public void testTagContents() throws JspException {
        ListDisplayTag ldt = new ListDisplayTag();
        ldt.setSet(new RhnSetImpl());
        SetTag t = new SetTag();
        t.setParent(ldt);
        TagTestHelper tth = new TagTestHelper(t);
        tth.assertDoStartTag(TagSupport.SKIP_BODY);
        
    }
}
