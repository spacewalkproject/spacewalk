/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.events.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.events.UpdateErrataCacheAction;
import com.redhat.rhn.frontend.events.UpdateErrataCacheEvent;
import com.redhat.rhn.manager.errata.cache.test.ErrataCacheManagerTest;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

public class UpdateErrataCacheEventTest extends BaseTestCaseWithUser {

    public void testUpdateCache() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        for (int i = 0; i < 10; i++) {
            ErrataCacheManagerTest.createServerNeedintErrataCache(user);
        }

        UpdateErrataCacheEvent evt =
            new UpdateErrataCacheEvent(UpdateErrataCacheEvent.TYPE_ORG);
        evt.setOrgId(user.getOrg().getId());

        UpdateErrataCacheAction action = new UpdateErrataCacheAction();
        action.execute(evt);
    }

}
