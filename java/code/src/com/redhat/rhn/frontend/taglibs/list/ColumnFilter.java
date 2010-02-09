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
package com.redhat.rhn.frontend.taglibs.list;

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.Locale;
import java.util.Map;


/**
 * ColumnFilter
 * @version $Rev$
 */
public class ColumnFilter extends BaseListFilter {
    private String key;
    private String attr;

    /**
     * Constructor
     * @param headerKey the key selected for search
     * @param filterAttr the attribute to search on
     */
    public ColumnFilter(String headerKey, String filterAttr) {
        key = headerKey;
        attr = filterAttr;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void processMap(Map map, Locale userLocale) {
        LocalizationService ls =
            LocalizationService.getInstance();
        String label = ls.getMessage(key, userLocale);
        map.put(label, attr);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        return new ToStringBuilder(this).append("Column Key", key).
                            append("Attribute", attr).toString();
    }
}
