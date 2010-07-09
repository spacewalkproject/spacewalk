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
package com.redhat.rhn.manager.kickstart.test;

import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.manager.kickstart.FilePreservationListsCommand;

import java.util.ArrayList;

/**
 * FilePreservationListsCommandTest
 * @version $Rev$
 */
public class FilePreservationListsCommandTest extends BaseKickstartCommandTestCase {

    public void testCommand() {
        FilePreservationListsCommand cmd =
            new FilePreservationListsCommand(ksdata.getId(), user);

        FileList list1 = KickstartDataTest.createFileList1(user.getOrg());
        FileList list2 = KickstartDataTest.createFileList2(user.getOrg());
        FileList list3 = KickstartDataTest.createFileList3(user.getOrg());

        CommonFactory.saveFileList(list1);
        CommonFactory.saveFileList(list2);
        CommonFactory.saveFileList(list3);

        list1 = (FileList) reload(list1);
        list2 = (FileList) reload(list2);
        list3 = (FileList) reload(list3);

        ArrayList ids = new ArrayList();
        ids.add(list1.getId());
        ids.add(list2.getId());
        ids.add(list3.getId());

        cmd.addFileListsByIds(ids);
        cmd.store();

        flushAndEvict(cmd.getKickstartData());
        assertTrue(cmd.getKickstartData().getPreserveFileLists().size() == 3);
        cmd.removeFileListsByIds(ids);
        cmd.store();
        flushAndEvict(cmd.getKickstartData());

        assertTrue(cmd.getKickstartData().getPreserveFileLists().size() == 0);
    }
}
