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
import com.redhat.rhn.domain.kickstart.KickstartInstallType;
import com.redhat.rhn.domain.kickstart.SELinuxMode;
import com.redhat.rhn.frontend.action.kickstart.SystemDetailsEditAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.kickstart.KickstartWizardHelper;
import com.redhat.rhn.testing.TestUtils;

public class KickstartSystemDetailsTest extends BaseKickstartEditTestCase {

    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        // TODO Auto-generated method stub
        super.setUp();
        KickstartWizardHelper cmd = new KickstartWizardHelper(user);
        cmd.createCommand("selinux", "--permissive", ksdata);
    }

    public void testDisplay() throws Exception {

        // Create a kickstart and the ranges so the list
        // will return something.
        setupForDisplay(ksdata);
        actionPerform();
        verifyNoActionErrors();
     }

    public void testEditSELinux() throws Exception {
        setupForEdit(ksdata);
        addRequestParameter("selinuxMode", "enforcing");
        addRequestParameter("rootPassword", "blahblah");
        addRequestParameter("rootPasswordConfirm", "blahblah");
        addRequestParameter("pwdChanged", "true");
        actionPerform();
        verifyNoActionErrors();
        verifyFormValue("selinuxMode", "enforcing");
    }

    public void testEditRootPasswordErr() throws Exception {
        setupForEdit(ksdata);
        addRequestParameter("rootPassword", "blahblah");
        addRequestParameter("rootPasswordConfirm", "blah");
        addRequestParameter("pwdChanged", "true");
        actionPerform();
        String[] errMessages = {"kickstart.systemdetails.root.password.jsp.error"};
        verifyActionErrors(errMessages);
    }

    public void testEditRootPasswordSuccess() throws Exception {
        setupForEdit(ksdata);
        addRequestParameter("selinuxMode", "permissive");
        addRequestParameter("rootPassword", "blahblah");
        addRequestParameter("rootPasswordConfirm", "blahblah");
        addRequestParameter("pwdChanged", "true");
        actionPerform();
        verifyNoActionErrors();
    }

    public void testEditNetworkSuccess() throws Exception {
        setupForEdit(ksdata);
        addRequestParameter("selinuxMode", "permissive");
        addRequestParameter("rootPassword", "blahblah");
        addRequestParameter("rootPasswordConfirm", "blahblah");
        addRequestParameter("pwdChanged", "true");
        actionPerform();
        verifyNoActionErrors();
    }

    public void testRHEL3Execute() throws Exception {
        ksdata.getKickstartDefaults().getKstree().
            setInstallType(KickstartFactory.
                lookupKickstartInstallTypeByLabel(KickstartInstallType.RHEL_3));
        KickstartFactory.saveKickstartData(ksdata);
        ksdata = (KickstartData) TestUtils.reload(ksdata);

        setRequestPathInfo("/kickstart/SystemDetailsEdit");
        addRequestParameter("registrationType", "reactivation");
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(SystemDetailsEditAction.SE_LINUX_PARAM,
                SELinuxMode.ENFORCING.getValue());
        actionPerform();
        // Make sure we DONT update if its rhel3
        assertEquals("--permissive", ksdata.getCommand("selinux").getArguments());
        verifyNoActionErrors();
    }

    public void testRHEL4Execute() throws Exception {
        ksdata.getKickstartDefaults().getKstree().
        setInstallType(KickstartFactory.
            lookupKickstartInstallTypeByLabel(KickstartInstallType.RHEL_4));
        KickstartFactory.saveKickstartData(ksdata);
        ksdata = (KickstartData) TestUtils.reload(ksdata);

        assertNotNull(ksdata.getCommand("selinux"));
        setRequestPathInfo("/kickstart/SystemDetailsEdit");
        addRequestParameter("registrationType", "reactivation");
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(SystemDetailsEditAction.SE_LINUX_PARAM,
                SELinuxMode.ENFORCING.getValue());
        actionPerform();
        // Make sure we update if its rhel4
        assertEquals("--enforcing", ksdata.getCommand("selinux").getArguments());
        verifyNoActionErrors();

    }

    private void setupForDisplay(KickstartData k) throws Exception {
        clearRequestParameters();
        setRequestPathInfo("/kickstart/SystemDetailsEdit");
        addRequestParameter("ksid", k.getId().toString());
    }

    private void setupForEdit(KickstartData k) throws Exception {
        setupForDisplay(k);
        addRequestParameter("submitted", "true");
        addRequestParameter("registrationType", "reactivation");
    }
}
