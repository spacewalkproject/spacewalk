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
package com.redhat.rhn.frontend.action.configuration.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.dto.ConfigSystemDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Locale;
import java.util.TimeZone;

/**
 * TargetSystemsTest
 * @version $Rev$
 */
public class TargetSystemsTest extends RhnMockStrutsTestCase {

    public void testExecute() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());

        //Need to set the locale and timezone for the datepicker.
        Context ctxt = Context.getCurrentContext();
        ctxt.setLocale(Locale.ENGLISH);
        ctxt.setTimezone(TimeZone.getDefault());

        //Make a not currently managed system
        ServerFactoryTest.createTestServer(user, true);

        setRequestPathInfo("/configuration/system/TargetSystems");
        actionPerform();
        assertNotNull(request.getAttribute("set"));
        assertNotNull(request.getAttribute("newset"));
        verifyList(RequestContext.PAGE_LIST, ConfigSystemDto.class);
    }
}

