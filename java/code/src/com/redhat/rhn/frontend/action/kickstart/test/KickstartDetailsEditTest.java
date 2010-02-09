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

import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.frontend.action.kickstart.KickstartDetailsEditAction;
import com.redhat.rhn.frontend.action.kickstart.KickstartFileDownloadAction;
import com.redhat.rhn.frontend.struts.RequestContext;

/**
 * KickstartDetailsEditTest
 * @version $Rev: 1 $
 */
public class KickstartDetailsEditTest extends BaseKickstartEditTestCase {
    
    public void testExecute() throws Exception {
        setRequestPathInfo("/kickstart/KickstartDetailsEdit");
        addRequestParameter(KickstartDetailsEditAction.SUBMITTED, Boolean.FALSE.toString());
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
        String orgDefaultUrl = (String) request.getAttribute(
                KickstartFileDownloadAction.KSURL);
        assertNotNull(orgDefaultUrl);
        assertTrue(orgDefaultUrl.indexOf("/ks/cfg/org") > 0);
        assertTrue(orgDefaultUrl.indexOf("/org_default") > 0);
    }   

    public void testSubmit() throws Exception {
        setRequestPathInfo("/kickstart/KickstartDetailsEdit");
        addRequestParameter(KickstartDetailsEditAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(KickstartDetailsEditAction.COMMENTS, "some comment");
        addRequestParameter(KickstartDetailsEditAction.LABEL, "somelabel");
        addRequestParameter(KickstartDetailsEditAction.ACTIVE, Boolean.TRUE.toString());
        addRequestParameter(KickstartDetailsEditAction.ORG_DEFAULT, 
                Boolean.TRUE.toString());
        addRequestParameter(KickstartDetailsEditAction.VIRTUALIZATION_TYPE_LABEL, 
                KickstartVirtualizationType.KVM_FULLYVIRT);
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
        String[] keys = {"kickstart.details.success"};
        verifyActionMessages(keys);
        assertTrue(ksdata.isOrgDefault().booleanValue());
    }

}

