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

package com.redhat.rhn.common.util;

import org.apache.commons.digester.Rule;
import org.xml.sax.Attributes;

import java.lang.reflect.Method;

/**
 * AttributeCopyRule, a simple Digester rule to copy attributes and
 * invoke them on set(name, value) on the top object on the stack
 * @version $Rev$
 */

public class AttributeCopyRule extends Rule {
    /** {@inheritDoc} */
    public void begin(String namespace, String name,
                      Attributes attributes) throws Exception {
        Object param = digester.peek();
        Method me;
        try {
            me = param.getClass().getMethod("put",
                                            new Class[] { Object.class, Object.class });
        }
        catch (NoSuchMethodException e) {
            return;
        }

        for (int i = 0; i < attributes.getLength(); i++) {
            me.invoke(param, attributes.getQName(i), attributes.getValue(i));
        }
    }
}


