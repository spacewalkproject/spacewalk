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
package com.redhat.rhn.frontend.action.user.test;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.StateChange;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.user.EnableConfirmSetupAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagUtil;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.struts.action.ActionForward;

import java.util.Date;

/**
 * EnableConfirmSetupActionTest
 * @version $Rev$
 */
public class EnableConfirmSetupActionTest extends RhnBaseTestCase {
    
    /**
     * Setting "dispatch" to a non-null value.
     * Expecting to return a "enabled" ActionForward.
     * @throws Exception
     */
    public void testExecute() throws Exception {
        EnableConfirmSetupAction action = new EnableConfirmSetupAction();
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);
        ah.setupProcessPagination();
        ah.getMapping().addForwardConfig(new ActionForward("enabled", "path", true));
        ah.getUser().addRole(RoleFactory.ORG_ADMIN);
        RhnSet set = RhnSetDecl.USERS.get(ah.getUser());
        User one = UserTestUtils.createUser("testUser", ah.getUser().getOrg().getId());
        User two = UserTestUtils.createUser("testUser", ah.getUser().getOrg().getId());
        set.addElement(one.getId());
        set.addElement(two.getId());
        RhnSetManager.store(set);
        
        //success
        StateChange change = new StateChange();
        StateChange change2 = new StateChange();
        change.setState(UserFactory.DISABLED);
        change2.setState(UserFactory.DISABLED);
        Date now = new Date();
        now.setTime(now.getTime() - 33000);
        change.setDate(now);
        change2.setDate(now);
        change.setUser(one);
        change2.setUser(two);
        change.setChangedBy(ah.getUser());
        change2.setChangedBy(ah.getUser());
        one.addChange(change);
        two.addChange(change2);
        
        //Add parameter for list.
        String listName = TagHelper.generateUniqueName(EnableConfirmSetupAction.LIST_NAME);

        ah.getRequest().setupAddParameter(ListTagUtil.
                                    makeSelectedItemsName(listName), "0");
        ah.getRequest().setupAddParameter(ListTagUtil.
                                        makePageItemsName(listName), "0");
        ah.getRequest().setupAddParameter("dispatch", "dummyValue");
        ActionForward af = ah.executeAction("execute", false);
        assertEquals("enabled", af.getName());
    }
}
