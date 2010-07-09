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
package com.redhat.rhn.frontend.filter;

import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.common.util.StringUtil;

import org.apache.commons.lang.StringUtils;


/**
 * DefaultMatcher
 * @version $Rev$
 */
class StringMatcher implements Matcher {
    /**
     * {@inheritDoc}
     */
    public boolean include(Object obj, String filterData, String filterColumn) {

        if (StringUtils.isBlank(filterData) ||
                    StringUtils.isBlank(filterColumn)) {
            return true; ///show all if I entered a blank value
        }
        else {
            String value = ((String)MethodUtil.callMethod(obj,
                    StringUtil.beanify("get " +
                                        filterColumn),
                                    new Object[0]));
            if (!StringUtils.isBlank(value)) {
                return  value.toUpperCase().indexOf(filterData.toUpperCase()) >= 0;
            }
        }
        return false;
    }
}
