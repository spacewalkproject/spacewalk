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
package com.redhat.rhn.frontend.action.channel.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.ChannelEntitlementSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * ChannelEntitlementSetupActionTest
 * @version $Rev$
 */
public class ChannelEntitlementSetupActionTest extends RhnBaseTestCase {
    public void testPerformExecute() throws Exception {
        ChannelEntitlementSetupAction action = new ChannelEntitlementSetupAction();
        
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action, "default");
        sah.getRequest().setupAddParameter(RequestContext.FILTER_STRING, (String) null);
        
        User user = sah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        ChannelFactoryTest.createTestChannel(user);
        
        OrgFactory.save(user.getOrg());
        
        sah.setupProcessPagination();
        sah.setupClampListBounds();
        sah.executeAction();
        DataResult dr = (DataResult) sah.getRequest().getAttribute(ListHelper.DATA_SET);
        assertNotEmpty(dr);
   }
}
