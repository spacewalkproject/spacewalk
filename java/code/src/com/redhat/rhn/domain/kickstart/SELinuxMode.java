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

package com.redhat.rhn.domain.kickstart;

import com.redhat.rhn.common.validator.ValidatorException;

import java.util.Collection;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.Map;


/**
 * @author paji
 * @version $Rev$
 */
public enum SELinuxMode {
    ENFORCING ("enforcing"),
    PERMISSIVE("permissive"),
    DISABLED ("disabled");
    private static final Map<String, SELinuxMode> MODE_MAP =
                                    new HashMap<String, SELinuxMode>();

    static {
        for (SELinuxMode m : EnumSet.allOf(SELinuxMode.class)) {
            MODE_MAP.put(m.getValue(), m);
        }
    }

    private String mode;
    /**
     * Selinux mode constructor
     * @param str the selinux mode.
     */
    SELinuxMode(String str) {
        mode = str;
    }

    /**
     * @return the SE Linux Mode..
     */
    public String getValue() {
        return mode;
    }

    /**
     * Given a key such as enforcing, permissive, or disabled,
     * the code returns the appropriate mode..
     * @param key enforcing, permissive, or disabled
     * @return the appropirate SE Linux Mode object
     */
    public static SELinuxMode lookup(String key) {
        if (!MODE_MAP.containsKey(key)) {
            ValidatorException.raiseException("selinux.java.invalid_mode",
                                                key, MODE_MAP.keySet().toString());
        }
        return MODE_MAP.get(key);
    }

    /**
     * @return the mode keys available.
     */
    public static Collection keys() {
        return MODE_MAP.keySet();
    }

    /**
     * @return appropriate to string.
     */
    public String toString() {
        return getValue();
    }

}
