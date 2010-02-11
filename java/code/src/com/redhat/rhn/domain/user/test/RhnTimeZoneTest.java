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
package com.redhat.rhn.domain.user.test;

import com.redhat.rhn.domain.user.RhnTimeZone;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.TimeZone;

/**
 * TimeZoneTest
 * @version $Rev$
 */
public class RhnTimeZoneTest extends RhnBaseTestCase {
   private RhnTimeZone tz;

   public void testBeanMethods() {
       tz = new RhnTimeZone();
       RhnTimeZone tz2 = new RhnTimeZone();
       String foo = "foo";
       String name = "Australia/Sydney";
       TimeZone nameTZ = TimeZone.getTimeZone(name);
       TimeZone defaultTZ = TimeZone.getTimeZone("yum");
       int id = 7010;
       
       tz.setOlsonName(name);
       assertEquals(name, tz.getOlsonName());
       assertEquals(nameTZ, tz.getTimeZone());
       
       tz.setOlsonName(foo);
       assertEquals(foo, tz.getOlsonName());
       assertTrue(tz.getTimeZone().equals(defaultTZ)); 
               //default is GMT specified by java.util.TimeZone
       
       tz2.setOlsonName(null);
       assertNull(tz2.getOlsonName());
       assertNull(tz2.getTimeZone());
       
       tz.setTimeZoneId(id);
       assertEquals(id, tz.getTimeZoneId());
   }
}
