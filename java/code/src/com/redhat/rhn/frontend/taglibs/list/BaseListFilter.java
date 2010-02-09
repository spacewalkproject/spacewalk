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

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;


/**
 * BaseListFilter
 * @version $Rev$
 */
public abstract class BaseListFilter implements ListFilter {

    private Map fieldMap;

    /**
     * ${@inheritDoc}
     */
    public void prepare(Locale userLocale) {
        fieldMap = new HashMap();
        processMap(fieldMap, userLocale);
    }

    /**
     * ${@inheritDoc}
     */
    public boolean filter(Object object, String field,
            String criteria) {

        //So this is kind of a hack, but without re-writing the whole
        // filter subsystem this is the only way to be able to use the
        // ColumnFilter from the action side (AbstractSetHelper) without
        // doing some really crazy things
        //String methodName = (String) fieldMap.get(field);
        String methodName = (String) fieldMap.values().iterator().next();

        criteria = criteria.toLowerCase();
        if (methodName != null) {
            String value = ListTagUtil.getBeanValue(object, methodName);
            return (value != null) &&
                           value.toLowerCase().indexOf(criteria) >= 0;
        }
        return false;
    }

    /**
     * ${@inheritDoc}
     */
    public List getFieldNames() {
        return new LinkedList(fieldMap.keySet());
    }

    /**
     * Bind the display value of UI column(s) that need to be
     * filtered to bean property of the object that needs to be
     * inspected...
     * @param map the map to which the display value is to be
     *              bound to the bean property
     * @param userLocale the locale info used for the display value
     */
    public abstract void processMap(Map map, Locale userLocale);
}
