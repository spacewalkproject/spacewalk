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

import com.redhat.rhn.frontend.struts.Expandable;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.List;

/**
 * ListFilterHelper
 * @version $Rev$
 */
public class ListFilterHelper {

    /**
     * Constructor.
     */
    private ListFilterHelper() {
    }
    
    /**
     * Filter a list using the specified filter 
     * @param dataSet the dataset to filter
     * @param filter the filter to use
     * @param filterBy which value to filter by in the bean
     * @param filterValue the value to filter on
     * @return the filtered list
     */
    public static List filter(List dataSet, ListFilter filter, String filterBy, 
            String filterValue) {
        String tmp = null;
        try {
            tmp = URLDecoder.decode(filterBy, "UTF-8");
            filterBy = tmp;
        }
        catch (UnsupportedEncodingException e) {
            // This makes checkstyle happy
            tmp = null;
        }
        catch (IllegalArgumentException e) {
            // an illegal sequence was detected
            tmp = null;
        }
        
        try {
            tmp = URLDecoder.decode(filterValue, "UTF-8");
            filterValue = tmp;
        }
        catch (UnsupportedEncodingException e) {
            // This makes checkstyle happy
            tmp = null;
        }
        catch (IllegalArgumentException e) {
            // an illegal sequence was detected
            tmp = null;
        }
        
        List filteredData = new ArrayList();
        Expandable parent = null;
        for (Object object : dataSet) {
            if (object instanceof Expandable) {
                parent = (Expandable) object;
                for (Object obj : parent.expand()) {
                    if (filter.filter(object, filterBy, filterValue)) {
                        filteredData.add(parent);
                        break;
                    }
                }
                
            }
            else if (filter.filter(object, filterBy, filterValue)) {
                filteredData.add(object);
            }

        }
        return filteredData;
    }
    
    
}
