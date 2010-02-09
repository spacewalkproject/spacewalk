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
package com.redhat.rhn.frontend.xmlrpc.packages.provider.test;

import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageKey;
import com.redhat.rhn.domain.rhnpackage.PackageProvider;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.xmlrpc.packages.provider.PackagesProviderHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;

import org.apache.commons.lang.RandomStringUtils;

import java.util.List;

public class PackagesProviderHandlerTest extends BaseHandlerTestCase {

    private PackagesProviderHandler handler = new PackagesProviderHandler();
    
    
    public void testListKeys() throws Exception {
        String name = RandomStringUtils.randomAlphabetic(5);
        admin.addRole(RoleFactory.SAT_ADMIN);
        PackageProvider prov = new PackageProvider();
        prov.setName(name);
        
        PackageFactory.save(prov);
        
        assertTrue(handler.listKeys(adminKey, name).isEmpty());
        
        
        String keyStr = RandomStringUtils.randomAlphabetic(5);
        PackageKey key = new PackageKey();
        key.setKey(keyStr);
        key.setType(PackageFactory.PACKAGE_KEY_TYPE_GPG);
        prov.addKey(key);
        
        assertFalse(handler.listKeys(adminKey, name).isEmpty());
        
    }
    
    public void testList() throws Exception {
        admin.addRole(RoleFactory.SAT_ADMIN);
        String name = RandomStringUtils.randomAlphabetic(5);
        PackageProvider prov = new PackageProvider();
        prov.setName(name);
        
        PackageFactory.save(prov);
        
        List list = handler.list(adminKey);
        assertContains(list, prov);
          
    }
    
    
    public void testAddKey() throws Exception {
        admin.addRole(RoleFactory.SAT_ADMIN);
        
        String provStr = RandomStringUtils.randomAlphabetic(5);
        String keyStr = RandomStringUtils.randomAlphabetic(5);
        
        handler.associateKey(adminKey, provStr, keyStr, "gpg");
        assertFalse(handler.listKeys(adminKey, provStr).isEmpty());
        
    }
    

    
    
}
