/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.schedule.test;

import com.redhat.rhn.frontend.action.schedule.ArchivedActionsAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForward;

/**
 * ArchivedActionsSetupTest
 * @version $Rev$
 */
public class ArchivedActionsTest extends RhnBaseTestCase {

    public void testArchive() throws Exception {
        ArchivedActionsAction action = new ArchivedActionsAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
        sah.setupProcessPagination();
        ActionForward af = sah.executeAction();
        String expectedPath = "path?lower=10";
        assertEquals(expectedPath, af.getPath());
    }
}
