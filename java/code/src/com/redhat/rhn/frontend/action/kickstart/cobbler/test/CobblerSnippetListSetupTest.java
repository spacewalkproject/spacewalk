/**
 * Copyright (c) 2004-2006 Red Hat, Inc.
 * All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * Red Hat, Inc. ("Confidential Information").  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with Red Hat.
 */
package com.redhat.rhn.frontend.action.kickstart.cobbler.test;

import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

/**
 * CobblerSnippetListSetupTest
 * @version $Rev: 1 $
 */
public class CobblerSnippetListSetupTest extends RhnMockStrutsTestCase {
    
    public void testExecute() throws Exception {
        setRequestPathInfo("/kickstart/cobbler/CobblerSnippetListSetup");
        actionPerform();
        assertNotNull(request.getAttribute(RhnHelper.TARGET_USER));
    }
}

