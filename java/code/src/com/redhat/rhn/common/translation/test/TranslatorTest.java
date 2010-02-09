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
package com.redhat.rhn.common.translation.test;

import com.redhat.rhn.common.translation.Translator;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TranslatorTest extends RhnBaseTestCase {

    public void testInt2String() {
        Integer i = new Integer(42);
        assertEquals("42", Translator.int2String(i));
        assertEquals("", Translator.int2String(null));
    }
    
    public void testInt2List() {
        Integer i = new Integer(42);
        List list = Translator.int2List(i);
        assertEquals(1, list.size());
        Integer result = (Integer) list.iterator().next();
        assertEquals(i, result);
        
        list = Translator.int2List(null);
        assertTrue(list.isEmpty());
    }
    
    public void testBigDecimal2SomethingElse() throws Exception {
        BigDecimal bd = new BigDecimal(1);
        int i = Translator.bigDecimal2Int(bd);
        assertEquals(1, i);
        
        Integer bi = Translator.bigDecimal2IntObject(bd);
        assertEquals(new Integer(1), bi);
        
        long l = Translator.bigDecimal2Long(bd);
        assertEquals(1, l);
        
        Long bl = Translator.bigDecimal2LongObj(bd);
        assertEquals(new Long(1), bl);
    }
    
    public void testDouble2SomethingElse() {
        Double d = new Double(10.0);
        String s = Translator.double2String(d);
        assertEquals("10.0", s);
    }
    
    public void testLong2SomethingElse() throws Exception {
        Long bl = new Long(10);
        long ll = Translator.long2Objlong(bl);
        assertEquals(10, ll);
        
        Long uid = UserTestUtils.createUser("testUser", "testOrg");
        User user = Translator.long2User(new Integer(uid.intValue()));
        assertNotNull(user);
        assertEquals(uid, user.getId());
        assertTrue(user.getLogin().startsWith("testUser"));
    }
    
    public void testString2SomethingElse() throws Exception {
        assertFalse(Translator.string2boolean(null));
        assertTrue(Translator.string2boolean("Y"));
        assertTrue(Translator.string2boolean("y"));
        assertTrue(Translator.string2boolean("1"));
        assertTrue(Translator.string2boolean("true"));
        assertTrue(Translator.string2boolean("tRUe"));
        assertFalse(Translator.string2boolean("0"));
        assertFalse(Translator.string2boolean("f"));
        assertFalse(Translator.string2boolean("F"));
        assertFalse(Translator.string2boolean("n"));
        assertFalse(Translator.string2boolean("false"));
        assertFalse(Translator.string2boolean("faLSe"));
        assertFalse(Translator.string2boolean("rock on"));
    }
    
    public void testInteger2Boolean() {
        Integer zero = new Integer(0);
        Integer one = new Integer(1);
        Integer two = new Integer(2);
        
        assertTrue(Translator.int2Boolean(one));
        assertFalse(Translator.int2Boolean(zero));
        assertFalse(Translator.int2Boolean(two));
        assertFalse(Translator.int2Boolean(null));
    }
    
    public void testDate2String() {
        Date now = new Date();
        assertEquals(now.toString(), Translator.date2String(now));
        assertEquals("", Translator.date2String(null));
    }
    
    public void testBoolean2Somethingelse() {
        assertTrue(Translator.boolean2boolean(Boolean.TRUE));
        assertFalse(Translator.boolean2boolean(Boolean.FALSE));
        assertFalse(Translator.boolean2boolean(null));
        
        assertEquals("false", Translator.boolean2String(Boolean.FALSE));
        assertEquals("true", Translator.boolean2String(Boolean.TRUE));
        assertEquals("false", Translator.boolean2String(null));
    }
    
    public void testMap2String() {
        Map foo = new HashMap();
        foo.put("bar", "nut");
        foo.put("java", "sucks");
        assertEquals(foo.toString(), Translator.map2String(foo));
        assertEquals("", Translator.map2String(null));
    }
    
    public void testList2String() {
        List l = new ArrayList();
        l.add(1);
        l.add(2);
        assertEquals(l.toString(), Translator.list2String(l));
        assertEquals("", Translator.list2String(null));
    }
}
