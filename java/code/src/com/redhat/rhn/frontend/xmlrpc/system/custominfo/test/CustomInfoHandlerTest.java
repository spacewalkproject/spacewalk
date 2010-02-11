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
package com.redhat.rhn.frontend.xmlrpc.system.custominfo.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.dto.CustomDataKeyOverview;
import com.redhat.rhn.frontend.xmlrpc.system.custominfo.CustomInfoHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.Iterator;

/**
 * CustomInfoHandlerTest
 * @version $Rev$
 */
public class CustomInfoHandlerTest extends BaseHandlerTestCase {

    private CustomInfoHandler handler = new CustomInfoHandler();
    
    public void testCreateKey() throws Exception {

        // default setup already includes a custom key; therefore, let's
        // grab the initial size
        int initialSize = SystemManager.listDataKeys(admin).size();

        handler.createKey(adminKey, "testlabel", "test description");
        
        DataResult result = SystemManager.listDataKeys(admin);
        
        assertEquals(initialSize + 1, result.size());
        
        boolean foundKey = false;
        for (Iterator itr = result.iterator(); itr.hasNext();) {
            CustomDataKeyOverview key = (CustomDataKeyOverview) itr.next();
            if (key.getLabel().equals("testlabel") && 
                key.getDescription().equals("test description")) {
                foundKey = true;
                break;
            }
        }
        assertTrue(foundKey);
    }

    public void testDeleteKey() throws Exception {

        // default setup already includes a custom key; therefore, let's
        // grab the initial size
        DataResult initialKeys = SystemManager.listDataKeys(admin);

        handler.createKey(adminKey, "testlabel", "test description");
        DataResult result = SystemManager.listDataKeys(admin);
        assertEquals(initialKeys.size() + 1, result.size());
        
        boolean foundKey = false;
        for (Iterator itr = result.iterator(); itr.hasNext();) {
            CustomDataKeyOverview key = (CustomDataKeyOverview) itr.next();
            if (key.getLabel().equals("testlabel") && 
                key.getDescription().equals("test description")) {
                foundKey = true;
                break;
            }
        }
        assertTrue(foundKey);

        handler.deleteKey(adminKey, "testlabel");
        result = SystemManager.listDataKeys(admin);
        assertEquals(initialKeys.size(), result.size());
        
        foundKey = false;
        for (Iterator itr = result.iterator(); itr.hasNext();) {
            CustomDataKeyOverview key = (CustomDataKeyOverview) itr.next();
            if (key.getLabel().equals("testlabel") && 
                key.getDescription().equals("test description")) {
                foundKey = true;
                break;
            }
        }
        assertFalse(foundKey);
    }
    
    public void testListAllKeys() throws Exception {
        
        // default setup already includes a custom key; therefore, we don't 
        // need to add any as part of this test.
        
        Object[] keys = handler.listAllKeys(adminKey);
        
        assertEquals(SystemManager.listDataKeys(admin).size(),
                keys.length);
    }
}

