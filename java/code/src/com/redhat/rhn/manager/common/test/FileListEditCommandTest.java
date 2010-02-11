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
package com.redhat.rhn.manager.common.test;

import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.common.test.FileListTest;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.manager.common.BaseFileListEditCommand;
import com.redhat.rhn.manager.common.CreateFileListCommand;
import com.redhat.rhn.manager.common.EditFileListCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

/**
 * FileListEditCommandTest - test for FileListEditCommand
 * @version $Rev$
 */
public class FileListEditCommandTest extends BaseTestCaseWithUser {
    
    private BaseFileListEditCommand cmd;

    public void setupKey(BaseFileListEditCommand cmdIn) throws Exception {
        this.cmd = cmdIn; 
        assertNotNull(cmd.getFileList().getOrg());
        cmd.setLabel("Test label");
        cmd.store();
    }

    public void testBaseFileListEditCommand() throws Exception {
        setupKey(new CreateFileListCommand(user));
        int version = 1; 
        String baseStr = "Test10.";
        String files = "";
        String fileList = "Test10.1\nTest10.2\nTest10.3\nTest10.4" +
                        "\nTest10.5\nTest10.6\nTest10.7" +
                        "\nTest10.8\nTest10.9\nTest10.10";

        files =  cmd.getFileListString() + baseStr + version++;
        cmd.updateFiles(files);

        assertTrue(cmd.getFileListString().equals("Test10.1"));
                

        files =  cmd.getFileListString() + "\n" + baseStr + version++;
        cmd.updateFiles(files);

        assertTrue(cmd.getFileListString().equals("Test10.1\nTest10.2"));
        
        while (version < 11) {
            files += "\n" + baseStr + version++;

        }
        
        cmd.updateFiles(files);
        assertTrue(cmd.getFileListString().equals(fileList));
    }
    
    
    public void testCreateCommand() throws Exception {
        setupKey(new CreateFileListCommand(user));
        FileList list = cmd.getFileList();
          
        String files = "1\n2\n3\n4\n5\n6\n7\n8";
        cmd.updateFiles(files);
        
        ConfigFileName f = (ConfigFileName) cmd.getFileList().getFileNames()
                                               .iterator().next();
       
        assertEquals("1", f.getPath());
        assertEquals(8, cmd.getFileList().getFileNames().size());
        list = (FileList) reload(list);
        assertNotNull(list.getId());
        assertNotNull(list.getOrg());
        assertEquals(files, cmd.getFileListString());
    }

    
    public void testEdit() throws Exception {
        FileList list = FileListTest.createTestFileList(user.getOrg());
        CommonFactory.saveFileList(list);
        flushAndEvict(list);
        setupKey(new EditFileListCommand(user, list.getId()));
        assertNotNull(cmd.getFileList());
        assertNull(cmd.store());
        
    }
    

}

