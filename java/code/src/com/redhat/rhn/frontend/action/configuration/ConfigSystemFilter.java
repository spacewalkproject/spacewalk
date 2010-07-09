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
package com.redhat.rhn.frontend.action.configuration;

import java.util.ArrayList;
import java.util.List;

/**
 * ConfigSystemFilter
 * @version $Rev$
 */
public class ConfigSystemFilter extends BaseConfigFilter {
    private List fields;

    /**
     * Create a new filter with "name" added to its filter-criteria
     */
    public ConfigSystemFilter() {
        fields = new ArrayList();
        fields.add("name");
    }

    protected List activeNames() {
        return fields;
    }

    protected String getI18NPrefix() {
        return "configsystemfilter";
    }

}
