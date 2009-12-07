/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.common.ChecksumFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.ChangeLogEntry;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageCapability;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageFile;
import com.redhat.rhn.domain.rhnpackage.PackageGroup;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.rhnpackage.PackageSource;
import com.redhat.rhn.domain.rpm.SourceRpm;
import com.redhat.rhn.domain.rpm.test.SourceRpmTest;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * PackageTest
 * @version $Rev$
 */
public class PackageTest extends RhnBaseTestCase {
    
    public void testPackage() throws Exception {
        
        Package pkg = createTestPackage();
        assertNotNull(pkg);
        //make sure we got written to the db
        assertNotNull(pkg.getId());
        TestUtils.flushAndEvict(pkg);
        
        Package lookup = PackageFactory.lookupByIdAndOrg(pkg.getId(), pkg.getOrg());
        assertNotNull(lookup.getBuildTime());
                
        
        assertTrue(lookup.getChangeLog().size() > 0);
        
        ChangeLogEntry change2 = ChangeLogEntryTest.createTestChangeLogEntry(lookup,
                new Date(System.currentTimeMillis() + 1000));
        lookup.addChangeLogEntry(change2);
        
        assertTrue(lookup.getChangeLog().size() > 1);
    }

    public void testFile() throws Exception {
        Package pkg = createTestPackage();
        assertNotNull(pkg);
        
        String filename = "foo-2.31-4-i386.rpm";
        String path = "/foo/bar/foos/";
        
        pkg.setPath(path + filename);
        assertEquals(filename, pkg.getFile());

        pkg.setPath(filename);
        assertEquals(filename, pkg.getFile());
        
        pkg.setPath("");
        assertNull(pkg.getFile());
        
        pkg.setPath(null);
        assertNull(pkg.getFile());
        
        pkg.setPath("////foo//b///foo/");
        assertEquals("foo", pkg.getFile());
    }
    
    //TODO: scrap this in preference of createTestPackage(org)
    public static Package createTestPackage() throws Exception {
        Package p = new Package();
        Org org = OrgFactory.lookupById(UserTestUtils.createOrg("testOrg"));
        
        p = populateTestPackage(p, org);
        TestUtils.saveAndFlush(p);

        return p;
    }
    


    public static Package createTestPackage(Org org) throws Exception {
        Package p = new Package();
        populateTestPackage(p, org);
        
        TestUtils.saveAndFlush(p);
        
        return p;
    }
    
    public static Package populateTestPackage(Package p, Org org) throws Exception {
        PackageName pname = PackageNameTest.createTestPackageName();
        PackageEvr pevr = PackageEvrFactoryTest.createTestPackageEvr();
        PackageGroup pgroup = PackageGroupTest.createTestPackageGroup();
        SourceRpm srpm = SourceRpmTest.createTestSourceRpm();

        Long testid = new Long(100);
        String query = "PackageArch.findById";
        PackageArch parch = (PackageArch) TestUtils.lookupFromCacheById(testid, query);
        
        p.setRpmVersion("foo");
        p.setDescription("RHN-JAVA Package Test");
        p.setSummary("Created by RHN-JAVA unit tests. Please disregard.");
        p.setPackageSize(new Long(42));
        p.setPayloadSize(new Long(42));
        p.setBuildHost("foo2");
        p.setBuildTime(new Date());
        p.setChecksum(ChecksumFactory.safeCreate(
            MD5Crypt.crypt(TestUtils.randomString()), "md5"));
        p.setVendor("Rhn-Java");
        p.setPayloadFormat("testpayloadformat");
        p.setCompat(new Long(0));
        p.setPath(MD5Crypt.crypt(TestUtils.randomString()));
        p.setHeaderSignature("Rhn-Java Unit Test");
        p.setCopyright("Red Hat - RHN - 2005");
        p.setCookie("Chocolate Chip");
        p.setLastModified(new Date());
        p.setCreated(new Date());
        p.setModified(new Date());
        
        p.setOrg(org);
        p.setPackageName(pname);
        p.setPackageEvr(pevr);
        p.setPackageGroup(pgroup);
        p.setSourceRpm(srpm);
        p.setPackageArch(parch);
        

        p.getPackageFiles().add(createTestPackageFile(p));
        p.getPackageFiles().add(createTestPackageFile(p));
        p.getChangeLog().add(createTestChangeLogEntry(p));
        p.getChangeLog().add(createTestChangeLogEntry(p));

        HibernateFactory.getSession().save(createTestPackageSource(srpm, org));


        return p;

    }
    

    public static ChangeLogEntry createTestChangeLogEntry(Package pack) {
        ChangeLogEntry log = new ChangeLogEntry();
        log.setName(TestUtils.randomString());
        log.setRhnPackage(pack);
        log.setText(TestUtils.randomString());
        log.setTime(new Date());
        log.setCreated(new Date());
        return log;

    }

    public static PackageSource createTestPackageSource(SourceRpm rpm, Org org) {

        PackageSource source = new PackageSource();

        String string = "dkfjdkjf";
        Date date = new Date();

        try {
            source.setBuildHost(string);
            source.setBuildTime(date);
            source.setCookie(string);
            source.setCreated(date);
            source.setChecksum(ChecksumFactory.safeCreate(string, "md5"));
            source.setOrg(org);
            source.setPackageGroup(PackageGroupTest.createTestPackageGroup());
            source.setPackageSize(343L);
            source.setPath(string);
            source.setPayloadSize(343L);
            source.setRpmVersion(string);
            source.setSigchecksum(ChecksumFactory.safeCreate(string, "md5"));
            source.setSourceRpm(rpm);
            source.setVendor(string);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return source;
    }


    public static PackageFile createTestPackageFile(Package pack) {
        PackageFile file = new PackageFile();
        PackageCapability cap = new PackageCapability();
        cap.setName(TestUtils.randomString());
        cap.setVersion(TestUtils.randomString());
        cap.setCreated(new Date());
        cap = (PackageCapability) TestUtils.saveAndReload(cap);

        file.setCapability(cap);
        file.setPack(pack);
        file.setDevice(234L);
        file.setFileMode(3434L);
        file.setFileSize(3434L);
        file.setFlags(343L);
        file.setGroupname("herjej");
        file.setInode(343L);
        file.setLang("eng");
        file.setLinkTo("dkfjdkfj");
        file.setChecksum(ChecksumFactory.safeCreate("kfdjfkd", "md5"));
        file.setModified(new Date());
        file.setMtime(new Date());
        file.setRdev(3434L);
        file.setUsername("dkfjdk");
        file.setCreated(new Date());
        file.setVerifyFlags(34434L);

        return file;
    }


    public static void addPackageToChannelNewestPackage(Package p, Channel c) {
        /*
       INSERT INTO rhnChannelNewestPackage(CHANNEL_ID, NAME_ID, EVR_ID, 
         PACKAGE_ARCH_ID, PACKGE_ID)
         VALUES(:channel_id, :name_id, :evr_id, :package_arch_id, :packge_id)
         */
        
        WriteMode m = 
            ModeFactory.
            getWriteMode("test_queries", "insert_into_rhnChannelNewestPackage");
        Map params = new HashMap();
        params.put("channel_id", c.getId());
        params.put("name_id", p.getPackageName().getId());
        params.put("evr_id", p.getPackageEvr().getId());
        params.put("package_arch_id", p.getPackageArch().getId());
        params.put("packge_id", p.getId());

        m.executeUpdate(params);
        
        // insert_into_rhnChannelPackage
        WriteMode cp = 
            ModeFactory.
            getWriteMode("test_queries", "insert_into_rhnChannelPackage");
        params = new HashMap();
        params.put("channel_id", c.getId());
        params.put("packge_id", p.getId());

        cp.executeUpdate(params);
    }
    
    public void testIsInChannel() {
        // TODO make this work on sate
    }
}
