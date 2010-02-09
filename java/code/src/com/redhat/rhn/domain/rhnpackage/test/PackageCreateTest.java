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
package com.redhat.rhn.domain.rhnpackage.test;

import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import java.util.List;
import java.util.Vector;

/**
 * PackageCreateTest
 * @version $Rev$
 */
public class PackageCreateTest extends BaseTestCaseWithUser {
    
    public void testPackageCreate() throws Exception {
        String randomString = TestUtils.randomString();
        Thread[] threads = new Thread[10];
        List finishedList = new Vector();
        for (int i = 0; i < threads.length; i++) {
            Runnable r = new PackageCreateTestThread(randomString, finishedList);
            threads[i] = new Thread(r);
            threads[i].start();
        }
        synchronized (finishedList) {
            while (finishedList.size() < threads.length) {
                finishedList.wait();
            }
        }
        
    }
    

    
}
