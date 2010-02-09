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
package com.redhat.rhn.domain.common.test;

import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestStatics;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;

/**
 * FileListTest
 * @version $Rev$
 */
public class FileListTest extends RhnBaseTestCase {

    public void testDeleteFileList() {
        Org o = UserTestUtils.findNewOrg(TestStatics.TESTORG);
        FileList f = createTestFileList(o);
        
        CommonFactory.saveFileList(f);
        assertNotNull(CommonFactory.lookupFileList(f.getId(), o));
        f.addFileName("/tmp/dir/history/file.history");
        f.addFileName("/tmp/dir/history/file2.history");
        f.addFileName("/tmp/dir/history/file3.history");
        flushAndEvict(f);
        assertEquals(CommonFactory.removeFileList(f), 1);
        flushAndEvict(f);
        assertNull(CommonFactory.lookupFileList(f.getId(), o));
           
    }
    
    public void testFileList() throws Exception {
        Org o = UserTestUtils.findNewOrg(TestStatics.TESTORG);
        FileList f = createTestFileList(o);
        
        CommonFactory.saveFileList(f);
        f.addFileName("/tmp/foo.txt");
        flushAndEvict(f);
        FileList f2 = CommonFactory.lookupFileList(f.getId(), o);
        assertNotNull(f2.getId());
        ConfigFileName cfn = (ConfigFileName) f2.getFileNames().iterator().next();
        assertEquals("/tmp/foo.txt", cfn.getPath());
    }
    
        
    public static FileList createTestFileList(Org orgIn) {
        FileList f = new FileList();
        
        f.setLabel("Test FileList" + TestUtils.randomString());
        f.setOrg(orgIn);
        f.setCreated(new Date());
        f.setModified(new Date());                                                      
        assertNull(f.getId());
        return f;
    }
}
