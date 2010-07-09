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

import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.frontend.action.kickstart.KickstartPreservationListSubmitAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.TestUtils;

/**
 * KickstartKeysEditActionTest
 * @version $Rev$
 */
public class KickstartPreservationListTest extends BaseKickstartEditTestCase {

    protected FileList list1;
    protected FileList list2;
    protected FileList list3;

    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        list1 = KickstartDataTest.createFileList1(user.getOrg());
        CommonFactory.saveFileList(list1);
        list2 = KickstartDataTest.createFileList2(user.getOrg());
        CommonFactory.saveFileList(list2);
        list3 = KickstartDataTest.createFileList3(user.getOrg());
        CommonFactory.saveFileList(list3);

        TestUtils.flushAndEvict(list1);
        TestUtils.flushAndEvict(list2);
        TestUtils.flushAndEvict(list3);
    }

    public void testSetupExecute() throws Exception {
        setRequestPathInfo("/kickstart/KickstartFilePreservationLists");
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
    }

    public void testSubmitExecute() throws Exception {
        addSelectedItem(list1.getId());
        addSelectedItem(list2.getId());
        addDispatchCall(KickstartPreservationListSubmitAction.UPDATE_METHOD);
        setRequestPathInfo("/kickstart/KickstartFilePreservationListsSubmit");
        //        assertTrue(ksdata.getCryptoKeys() == null);
        actionPerform();
        //        assertTrue(ksdata.getCryptoKeys().size() == 1);
    }

}

