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
package com.redhat.rhn.frontend.context.test;

import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.Locale;
import java.util.TimeZone;

/**
 * ContextTest to test the static access to the Context object
 * @version $Rev$
 */
public class ContextTest extends RhnBaseTestCase {



    public void testCreateContext() {

        Context ctx = Context.getCurrentContext();
        ctx.setLocale(Locale.US);
        TimeZone tz = TimeZone.getTimeZone("America/Los_Angeles");
        ctx.setTimezone(tz);

        assertEquals(Context.getCurrentContext().getLocale(), Locale.US);
        assertEquals(Context.getCurrentContext().getTimezone(), tz);
    }

    /**
    * Check to make sure we can support having NULL for a context
    */
    public void testNullContext() {
        int originalHashcode = Context.getCurrentContext().hashCode();
        Context.freeCurrentContext();
        int newHashcode = Context.getCurrentContext().hashCode();
        assertTrue(originalHashcode != newHashcode);
    }

}
