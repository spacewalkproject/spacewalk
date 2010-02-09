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
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.frontend.action.kickstart.KickstartScriptCreateAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.TestUtils;

import org.apache.commons.lang.RandomStringUtils;

/**
 * KickstartScriptCreateActionTest
 * @version $Rev: 1 $
 */
public class KickstartScriptActionTest extends BaseKickstartEditTestCase {
    
    public void testExecute() throws Exception {
        // Lets zero out the scripts
        ksdata = clearScripts(ksdata);
        assertEquals(0, ksdata.getScripts().size());
        addRequestParameter(KickstartScriptCreateAction.SUBMITTED, 
                Boolean.FALSE.toString());
        setRequestPathInfo("/kickstart/KickstartScriptCreate");
        actionPerform();
        assertEquals(0, ksdata.getScripts().size());
        verifyFormValue(KickstartScriptCreateAction.TYPE, 
                KickstartScript.TYPE_PRE);
        assertNotNull(request.getAttribute(KickstartScriptCreateAction.TYPES));
    }

    public void testExecuteLargeValueSubmit() throws Exception {
        String contents = RandomStringUtils.randomAscii(400000);
        // Lets zero out the scripts
        ksdata = clearScripts(ksdata);
        String language = "/usr/bin/perl";
        addRequestParameter(KickstartScriptCreateAction.CONTENTS, 
                contents);
        addRequestParameter(KickstartScriptCreateAction.LANGUAGE, 
                language);
        addRequestParameter(KickstartScriptCreateAction.TYPE, 
                KickstartScript.TYPE_POST);
        addRequestParameter(KickstartScriptCreateAction.SUBMITTED, 
                Boolean.TRUE.toString());
        addRequestParameter(KickstartScriptCreateAction.TEMPLATE, 
                Boolean.TRUE.toString());
        setRequestPathInfo("/kickstart/KickstartScriptCreate");
        actionPerform();
        String[] keys = {"kickstart.script.toolarge"};
        verifyActionErrors(keys);
        
        contents = RandomStringUtils.randomAscii(50000);
        addRequestParameter(KickstartScriptCreateAction.CONTENTS, 
                contents);
        actionPerform();
        String[] successkeys = {"kickstart.script.success"};
        verifyActionMessages(successkeys);
    }
    
    public void testExecuteSubmit() throws Exception {
        // Lets zero out the scripts
        ksdata = clearScripts(ksdata);

        
        String contents = "some script value";
        String language = "/usr/bin/perl";
        addRequestParameter(KickstartScriptCreateAction.CONTENTS, 
                contents);
        addRequestParameter(KickstartScriptCreateAction.LANGUAGE, 
                language);
        addRequestParameter(KickstartScriptCreateAction.TYPE, 
                KickstartScript.TYPE_POST);
        addRequestParameter(KickstartScriptCreateAction.SUBMITTED, 
                Boolean.TRUE.toString());
        setRequestPathInfo("/kickstart/KickstartScriptCreate");
        actionPerform();
        String[] keys = {"kickstart.script.success"};
        verifyActionMessages(keys);
        assertNotNull(ksdata.getScripts());
        KickstartScript ks = (KickstartScript) ksdata.getScripts().iterator().next();
        assertEquals(contents, ks.getDataContents());
        assertEquals(language, ks.getInterpreter());
        assertEquals(KickstartScript.TYPE_POST, ks.getScriptType());
        verifyForward("success");
    }

    public void testEditExecute() throws Exception {
        assertEquals(5, ksdata.getScripts().size());
        addRequestParameter(KickstartScriptCreateAction.SUBMITTED, 
                Boolean.FALSE.toString());
        KickstartScript kss = (KickstartScript) ksdata.getScripts().iterator().next();
        addRequestParameter(RequestContext.KICKSTART_SCRIPT_ID, kss.getId().toString());
        setRequestPathInfo("/kickstart/KickstartScriptEdit");
        actionPerform();
        assertEquals(5, ksdata.getScripts().size());
        verifyFormValue(KickstartScriptCreateAction.TYPE, 
                kss.getScriptType());
        assertNotNull(request.getAttribute(KickstartScriptCreateAction.TYPES));
        assertNotNull(request.getAttribute(RequestContext.KICKSTART_SCRIPT_ID));
    }
    
    public void testEditExecuteSubmit() throws Exception {
        String contents = "some script value " + TestUtils.randomString();
        String language = "/usr/bin/perl";
        addRequestParameter(KickstartScriptCreateAction.CONTENTS, 
                contents);
        addRequestParameter(KickstartScriptCreateAction.LANGUAGE, 
                language);
        addRequestParameter(KickstartScriptCreateAction.TYPE, 
                KickstartScript.TYPE_POST);
        addRequestParameter(KickstartScriptCreateAction.SUBMITTED, 
                Boolean.TRUE.toString());
        KickstartScript kss = (KickstartScript) ksdata.getScripts().iterator().next();
        addRequestParameter(RequestContext.KICKSTART_SCRIPT_ID, kss.getId().toString());
        setRequestPathInfo("/kickstart/KickstartScriptEdit");
        actionPerform();
        String[] keys = {"kickstart.script.success"};
        verifyActionMessages(keys);
        assertNotNull(ksdata.getScripts());
        KickstartScript ks = (KickstartScript) ksdata.getScripts().iterator().next();
        assertEquals(contents, ks.getDataContents());
        assertEquals(language, ks.getInterpreter());
        assertEquals(KickstartScript.TYPE_POST, ks.getScriptType());
        verifyForward("success");
    }
    
    private static KickstartData clearScripts(KickstartData ksdataIn) {
        // Lets zero out the scripts
        ksdataIn.getScripts().clear();
        KickstartFactory.saveKickstartData(ksdataIn);
        ksdataIn = (KickstartData) TestUtils.reload(ksdataIn);
        return ksdataIn;
    }

    
}

