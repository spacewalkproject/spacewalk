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
package com.redhat.rhn.frontend.xmlrpc.kickstart.filepreservation.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.frontend.dto.FilePreservationDto;
import com.redhat.rhn.frontend.xmlrpc.kickstart.filepreservation.FilePreservationListHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.kickstart.KickstartLister;

import java.util.ArrayList;
import java.util.List;

/**
 * Test cases for the {@link FilePreservationListHandler}.
 *
 * @version $Revision$
 */
public class FilePreservationListHandlerTest extends BaseHandlerTestCase {

    private FilePreservationListHandler handler = new FilePreservationListHandler();

    public void testListAll() throws Exception {
        // Setup
        KickstartLister lister = KickstartLister.getInstance();
        int initialSize = lister.preservationListsInOrg(admin.getOrg(), null).size();
        FileList fileList = createFileList();

        // Test
        List<FilePreservationDto> list = handler.listAllFilePreservations(adminKey);

        // Verify
        assertNotNull(list);
        assertEquals(initialSize + 1, list.size());

        DataResult<FilePreservationDto> dataResult = lister.preservationListsInOrg(
                admin.getOrg(), null);
        boolean found = false;
        for (FilePreservationDto expected : dataResult) {
            for (FilePreservationDto received : list) {
                if (expected.getId().equals(received.getId()) &&
                    expected.getLabel().equals(received.getLabel()) &&
                    expected.getCreated().equals(received.getCreated()) &&
                    expected.getModified().equals(received.getModified())) {
                    found = true;
                    break;
                }
            }
        }
        assertTrue(found);
    }

    public void testCreate() throws Exception {
        // Setup
        KickstartLister lister = KickstartLister.getInstance();
        int initialSize = lister.preservationListsInOrg(admin.getOrg(), null).size();

        // Test
        List<String> files = new ArrayList<String>();
        files.add("file1");
        files.add("file2");
        int result = handler.create(adminKey, "list1", files);

        // Verify
        assertEquals(1, result);
        assertEquals(initialSize + 1, handler.listAllFilePreservations(adminKey).size());

        FileList entryCreated = CommonFactory.lookupFileList("list1", admin.getOrg());
        assertNotNull(entryCreated);
        assertEquals("list1", entryCreated.getLabel());
        assertEquals(2, entryCreated.getFileNames().size());
    }

    public void testDelete() throws Exception {
        // Setup
        KickstartLister lister = KickstartLister.getInstance();
        int initialSize = lister.preservationListsInOrg(admin.getOrg(), null).size();
        FileList fileList = createFileList();

        assertEquals(initialSize + 1, handler.listAllFilePreservations(adminKey).size());

        // Test
        int result = handler.delete(adminKey, fileList.getLabel());

        // Verify
        assertEquals(1, result);
        assertEquals(initialSize, handler.listAllFilePreservations(adminKey).size());

        FileList entryDeleted = CommonFactory.lookupFileList(fileList.getLabel(),
                admin.getOrg());
        assertNull(entryDeleted);
    }

    public void testGetDetails() throws Exception {
        // Setup
        FileList fileList = createFileList();

        // Test
        FileList details = handler.getDetails(adminKey, fileList.getLabel());

        // Verify
        assertNotNull(details);
        assertEquals(fileList.getLabel(), details.getLabel());
        assertEquals(fileList.getFileNames(), details.getFileNames());
    }

    private FileList createFileList() {
        List<String> files = new ArrayList<String>();
        files.add("file1");
        files.add("file2");
        int result = handler.create(adminKey, "list1", files);
        assertEquals(1, result);
        return CommonFactory.lookupFileList("list1", admin.getOrg());
    }
}
