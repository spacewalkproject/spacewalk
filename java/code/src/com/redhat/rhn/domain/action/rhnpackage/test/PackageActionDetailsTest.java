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
package com.redhat.rhn.domain.action.rhnpackage.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.rhnpackage.PackageActionDetails;
import com.redhat.rhn.domain.action.rhnpackage.PackageActionResult;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.rhnpackage.test.PackageEvrFactoryTest;
import com.redhat.rhn.domain.rhnpackage.test.PackageNameTest;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

/**
 * PackageActionDetailsTest
 * @version $Rev$
 */
public class PackageActionDetailsTest extends RhnBaseTestCase {

    public void testBeanMethods() throws Exception {
        PackageActionDetails pad = new PackageActionDetails();
        Long id = new Long(456);
        Date now = new Date();
        String foo = "foo";
        
        Long testid = new Long(100);
        PackageArch arch = (PackageArch) TestUtils
            .lookupFromCacheById(testid, "PackageArch.findById");
        
        PackageEvr evr = PackageEvrFactoryTest.createTestPackageEvr();
        PackageName pn = PackageNameTest.createTestPackageName();
        PackageAction action = new PackageAction();
        
        pad.setCreated(now);
        assertEquals(now, pad.getCreated());
        
        pad.setModified(now);
        assertEquals(now, pad.getModified());
        
        pad.setPackageId(id);
        assertEquals(id, pad.getPackageId());
        
        pad.setParameter(foo);
        assertEquals(foo, pad.getParameter());
        
        pad.setArch(arch);
        assertTrue(arch.equals(pad.getArch()));
        
        pad.setEvr(evr);
        assertTrue(evr.equals(pad.getEvr()));
        
        pad.setPackageName(pn);
        assertTrue(pn.equals(pad.getPackageName()));
        
        pad.setParentAction(action);
        assertTrue(action.equals(pad.getParentAction()));
    }
    
    public void testResultSetting() {
        PackageActionDetails pad = new PackageActionDetails();
        pad.setParentAction(new Action());
        PackageActionResult par = new PackageActionResult();
        PackageActionResult par1 = new PackageActionResult();
        PackageActionResult par2 = new PackageActionResult();
        par.setResultCode(new Long(20));
        par1.setResultCode(new Long(40)); //so that none are equal
        
        assertNotNull(pad.getResults());
        pad.addResult(par);
        assertEquals(1, pad.getResults().size());
        assertNotNull(pad.getResults().toArray()[0]);
        assertEquals(par, pad.getResults().toArray()[0]);
        
        pad.addResult(par1);
        assertEquals(2, pad.getResults().size());
        assertFalse(pad.getResults().contains(null));
        assertTrue(pad.getResults().contains(par1));
        
        Set results = new HashSet();
        results.add(par);
        results.add(par1);
        results.add(par2);
        
        pad.setResults(results);
        assertEquals(3, pad.getResults().size());
        assertEquals(results, pad.getResults());
    }
    
    public void testEquals() {
        PackageActionDetails pad = new PackageActionDetails();
        PackageActionDetails pad1 = new PackageActionDetails();
        
        Action parent = new Action();
        Action parent1 = new Action();
        parent.setId(new Long(3));
        parent1.setId(new Long(2));
        
        
        assertTrue(pad.equals(pad1));
        
        pad.setParentAction(parent);
        assertFalse(pad.equals(pad1));
        assertFalse(pad1.equals(pad));
        
        pad1.setParentAction(parent1);
        assertFalse(pad.equals(pad1));
        
        parent1.setId(new Long(3));
        assertTrue(pad.equals(pad1));
        
        pad1.setParentAction(parent);
        assertTrue(pad.equals(pad1));
        
        pad.setPackageId(new Long(2));
        assertFalse(pad.equals(pad1));
        assertFalse(pad1.equals(pad));
        
        pad1.setPackageId(new Long(3));
        assertFalse(pad.equals(pad1));
        
        pad.setPackageId(new Long(3));
        assertTrue(pad.equals(pad1));
        
    }

    // Some PackageActionDetails objects have package name only
    public static PackageActionDetails createTestDetailsWithName(User user, Action parent)
        throws Exception {

        PackageActionDetails pad = new PackageActionDetails();

        pad.setParameter("upgrade");
        Long testid = new Long(100);
        pad.setArch((PackageArch) TestUtils
                .lookupFromCacheById(testid, "PackageArch.findById"));
        pad.setPackageName(PackageNameTest.createTestPackageName());
        
        ((PackageAction) parent).addDetail(pad);
        //add parent before result because parent needed for hashcode
        
        PackageActionResult par = new PackageActionResult();
        par.setServer(ServerFactoryTest.createTestServer(user));
        par.setResultCode(new Long(3));
        par.setCreated(new Date());
        par.setModified(new Date());
        pad.addResult(par);
        
        return pad;
    }

    // Some PackageActionDetails objects have package name and package evr
    public static PackageActionDetails createTestDetailsWithNvre(User user, Action parent) 
                                                                    throws Exception {

        PackageActionDetails pad = new PackageActionDetails();

        pad.setParameter("upgrade");
        Long testid = new Long(100);
        pad.setArch((PackageArch) TestUtils
                .lookupFromCacheById(testid, "PackageArch.findById"));
        pad.setPackageName(PackageNameTest.createTestPackageName());
        pad.setEvr(PackageEvrFactoryTest.createTestPackageEvr());

        ((PackageAction) parent).addDetail(pad);
        //add parent before result because parent needed for hashcode
        
        PackageActionResult par = new PackageActionResult();
        par.setServer(ServerFactoryTest.createTestServer(user));
        par.setResultCode(new Long(3));
        par.setCreated(new Date());
        par.setModified(new Date());
        pad.addResult(par);
        
        return pad;

    }
}
