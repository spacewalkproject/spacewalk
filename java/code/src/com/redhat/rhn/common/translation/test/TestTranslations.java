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

import com.redhat.rhn.common.translation.Translations;

import java.util.Date;
import java.util.List;

public class TestTranslations extends Translations {

    private TestTranslations() {
    }

    public static Object convert(Object have, Class want) {
        return convert(TestTranslations.class, have, want);
    }

    public static Integer string2Int(String foo) {
        return Integer.valueOf(foo);
    }

    public static Date long2Date(Long d) {
        return new Date(d.longValue());
    }

    // This is here to test that we can't access a private method and that
    // when we try, we get a consistent error.
    private static Long int2Long(Integer i) {
        return new Long(i.intValue());
    }

    public static String list2String(List l) {
        return l.toString();
    }
}
