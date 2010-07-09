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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.taglibs.list.ListFilter;
import com.redhat.rhn.frontend.taglibs.list.ListTagUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Allows us to filter config lists.  All the concrete class needs to do is provide a list
 * of bean-ready field names (ie, if getFoo() exists in the Dto, "foo" is the field name),
 * and an I18N msg of the form "configfilter.method.<field>", and the base class will
 * do the rest.
 *
 * ConfigFileFilter
 * @version $Rev$
 */
public abstract class BaseConfigFilter implements ListFilter {

    private Map fieldMap;
    /**
     * Map method-names to I18N strings for the fields we might filter on (which
     * is (path, channelLabel) at the moment
     * {@inheritDoc}
     */
    public void prepare(Locale userLocale) {
        buildMap(userLocale);
    }

    /**
     * {@inheritDoc}
     */
    public List getFieldNames() {
        return new ArrayList(fieldMap.keySet());
    }

    /**
     * {@inheritDoc}
     */
    public boolean filter(Object object, String field, String criteria) {
        String methodName = (String) fieldMap.get(field);
        criteria = criteria.toLowerCase();
        boolean retval = false;
        if (methodName != null) {
            String value = ListTagUtil.getBeanValue(object, methodName);
            if (value != null) {
                retval = value.toLowerCase().indexOf(criteria) >= 0;
            }
        }
        return retval;
    }


    private void buildMap(Locale aLoc) {
        LocalizationService ls = LocalizationService.getInstance();
        fieldMap = new HashMap();
        List names = activeNames();
        for (int i = 0; i < names.size(); i++) {
            String aName = names.get(i).toString();
            fieldMap.put(ls.getMessage(getI18NPrefix() + "." + aName, aLoc), aName);
        }
    }

    protected abstract List activeNames();

    protected abstract String getI18NPrefix();
}
