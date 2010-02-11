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
package com.redhat.rhn.frontend.action.rhnpackage.ssm.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.taglibs.list.ListTagUtil;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

/**
 * @version $Revision$
 */
public class SelectRemovePackagesActionTest extends RhnMockStrutsTestCase {

    private SsmActionTestUtils utils;

    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/ssm/PackageRemove");

        utils = new SsmActionTestUtils(user);
    }

    public void testNonDispatch() throws Exception {
        // Setup
        utils.initSsmEnvironment();

        // Test
        actionPerform();

        // Verify
        verifyForward("default");

        Object pageList = getRequest().getAttribute("pageList");
        assertNotNull(pageList);

        DataResult result = (DataResult)pageList;
        assertEquals(2, result.size());
    }

    public void testDispatch() throws Exception {
        // Setup
        utils.initSsmEnvironment();
        selectAllPackagesInUI();
        addDispatchCall("ssm.package.remove.select.confirm");

        // Test
        actionPerform();

        // Verify
        verifyForward("confirm");
    }

    private void selectAllPackagesInUI() throws Exception {

        String[] itemsSelected = new String[] {
            "dummy"
        };

        String listName = TagHelper.generateUniqueName(ListHelper.LIST);
        String requestParameterName = ListTagUtil.makePageItemsName(listName);
        addRequestParameter(requestParameterName, itemsSelected);

        requestParameterName = ListTagUtil.makeSelectedItemsName(listName);
        addRequestParameter(requestParameterName, itemsSelected);
    }
}
