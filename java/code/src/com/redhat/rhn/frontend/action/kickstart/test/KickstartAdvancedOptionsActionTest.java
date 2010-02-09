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
package com.redhat.rhn.frontend.action.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.frontend.action.kickstart.KickstartAdvancedOptionsAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * KickstartAdvancedOptionsTest
 * @version $Rev: 1 $
 */
public class KickstartAdvancedOptionsActionTest extends RhnMockStrutsTestCase {
    
    protected KickstartData ksdata;
    protected KickstartData ksdataOptions;
    
    public void setUp() throws Exception {
        super.setUp();
        this.ksdata = KickstartDataTest.createKickstartWithChannel(user.getOrg());
        this.ksdataOptions = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        
        TestUtils.saveAndFlush(ksdata);
        TestUtils.saveAndFlush(ksdataOptions);
        
        addRequestParameter(RequestContext.KICKSTART_ID, this.ksdata.getId().toString());
    }
    
    public void testExecute() throws Exception {
        setRequestPathInfo("/kickstart/KickstartOptionsEdit");        
        actionPerform();
        assertNotNull(request.getAttribute(KickstartAdvancedOptionsAction.OPTIONS));
    }  
    
    public void testSubmit() throws Exception {                        
        setRequestPathInfo("/kickstart/KickstartOptionsEdit");
        addRequestParameter(KickstartAdvancedOptionsAction.SUBMITTED, 
                Boolean.TRUE.toString());        
        
        // setup some required fields
        addRequestParameter("keyboard", "keyboard");
        addRequestParameter("keyboard_txt", "US");
        addRequestParameter("lang", "lang");
        addRequestParameter("lang_txt", "en_US");
        addRequestParameter("langsupport", "langsupport");
        addRequestParameter("langsupport_txt", "--default en_US");
        addRequestParameter("mouse", "mouse");
        addRequestParameter("mouse_txt", "none");
        addRequestParameter("bootloader", "bootloader");
        addRequestParameter("bootloader_txt", "--location mbr");
        addRequestParameter("timezone", "timezone");
        addRequestParameter("timezone_txt", "America/New_York");
        addRequestParameter("auth", "auth");
        addRequestParameter("auth_txt", "--enablemd5 --enableshadow");        
        addRequestParameter("rootpw", "rootpw");
        addRequestParameter("rootpw_txt", "$1$nCCVpGg");
        addRequestParameter("customOptions", "repo blah");
        
        // setup a non required field
        addRequestParameter("skipx", "skipx");
        
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
        assertNotNull(request.getParameter("rootpw"));
        assertNotNull(request.getParameter("keyboard"));
        assertNotNull(request.getParameter("lang"));
        assertNotNull(request.getParameter("langsupport"));
        assertNotNull(request.getParameter("mouse"));
        assertNotNull(request.getParameter("bootloader"));
        assertNotNull(request.getParameter("timezone"));
        assertNotNull(request.getParameter("auth"));
        assertNotNull(request.getParameter("skipx"));

        String[] keys = {"kickstart.options.success"};        
        verifyActionMessages(keys);

        // Verify we can submit twice
        actionPerform();
        verifyActionMessages(keys);
    }
    
    /*
     * need to test how hibernate handles cascading orphans from the 
     * parent set. Page is loaded that has a ksdata with options already
     * set. The reqeste params will replace the existing option set     
     */
    public void testReplaceSubmit() throws Exception {        
        setRequestPathInfo("/kickstart/KickstartOptionsEdit");
        addRequestParameter(KickstartAdvancedOptionsAction.SUBMITTED, 
                Boolean.TRUE.toString());        
        
        // setup some required fields
        addRequestParameter("keyboard", "keyboard");
        addRequestParameter("keyboard_txt", "US");
        addRequestParameter("lang", "lang");
        addRequestParameter("lang_txt", "en_US");
        addRequestParameter("langsupport", "langsupport");
        addRequestParameter("langsupport_txt", "--default en_US");
        addRequestParameter("mouse", "mouse");
        addRequestParameter("mouse_txt", "");
        addRequestParameter("bootloader", "bootloader");
        addRequestParameter("bootloader_txt", "--location mbr");
        addRequestParameter("timezone", "timezone");
        addRequestParameter("timezone_txt", "America/New_York");
        addRequestParameter("auth", "auth");
        addRequestParameter("auth_txt", "--enablemd5 --enableshadow");        
        addRequestParameter("rootpw", "rootpw");
        addRequestParameter("rootpw_txt", "badpassword");
        addRequestParameter("customOptions", "repo blah");
        
        // setup a non required field
        addRequestParameter("skipx", "skipx");
        addRequestParameter(RequestContext.KICKSTART_ID, 
                this.ksdataOptions.getId().toString());
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));

        String[] keys = {"kickstart.options.success"};        
        verifyActionMessages(keys);
    }
    
    
}
