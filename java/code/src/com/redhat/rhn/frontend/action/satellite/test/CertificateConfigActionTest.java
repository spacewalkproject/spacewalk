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
package com.redhat.rhn.frontend.action.satellite.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.action.satellite.CertificateConfigForm;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.DynaActionForm;

/**
 * CertificateConfigActionTest
 * @version $Rev: 1 $
 */
public class CertificateConfigActionTest extends RhnMockStrutsTestCase {

    public void setUp() throws Exception {
        super.setUp();
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addRole(RoleFactory.SAT_ADMIN);
        Config.get().setString("web.com.redhat.rhn.frontend." +
                "action.satellite.CertificateConfigAction.command",
                TestConfigureCertificateCommand.class.getName());
        setRequestPathInfo("/admin/config/CertificateConfig");
    }

    public void testExecute() throws Exception {

        actionPerform();
    }

    public void testExecuteTextSubmit() throws Exception {

        String certString = "some cert text" + TestUtils.randomString();
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(CertificateConfigForm.CERT_TEXT, certString);
        actionPerform();

        DynaActionForm form = (DynaActionForm) getActionForm();
        assertEquals(form.get(CertificateConfigForm.CERT_TEXT), certString);
        verifyActionMessages(new String[]{"certificate.config.success"});
    }

    public void testExecuteTextSubmitWithMismatch() throws Exception {

        String certString = "some cert text" + TestUtils.randomString();
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(CertificateConfigForm.CERT_TEXT, certString);
        addRequestParameter("ignoreMismatch", "true");
        actionPerform();

        DynaActionForm form = (DynaActionForm) getActionForm();
        assertEquals(form.get(CertificateConfigForm.CERT_TEXT), certString);
        verifyActionMessages(new String[]{"certificate.config.success"});
    }

    public void testExecuteSubmitNoCert() throws Exception {
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        actionPerform();
        verifyActionMessages(new String[]{"certificate.config.error.nocert"});
    }

}

