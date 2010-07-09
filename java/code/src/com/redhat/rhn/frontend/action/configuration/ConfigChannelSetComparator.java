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

import com.redhat.rhn.domain.rhnset.RhnSetElement;

import java.util.Comparator;


/**
 * ConfigSetComparator
 * Used to order RhnSetElements based on the elementTwo which
 * stands for position in this context.
 * @version $Rev$
 */
public class ConfigChannelSetComparator implements Comparator {
    /**
     * {@inheritDoc}
     */
    public int compare(Object o1, Object o2) {
        Long first = ((RhnSetElement)o1).getElementTwo();
        Long second = ((RhnSetElement)o2).getElementTwo();

        //Nulls always come last.
        if (first == null) {
            return 1;
        }
        else if (second == null) {
            return -1;
        }

        //The least comes first.
        if (first.equals(second)) {
            return 0;
        }
        else if (first.longValue() < second.longValue()) {
            return -1;
        }
        else {
            return 1;
        }
    }

}
