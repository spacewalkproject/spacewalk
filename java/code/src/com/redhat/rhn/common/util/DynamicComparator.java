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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.commons.beanutils.PropertyUtils;

import java.text.Collator;
import java.util.Comparator;

/**
 * DynamicComparator - simple class that can be
 * used with Collections.sort(list, comparator).
 * Create an instance of this class with the 
 * passed in fieldname and it will create a Comparator
 * that will compare two objects based on the field 
 * passed into the Constructor.  
 * 
 * Usefull if you have a Collection of Beans that you
 * want to sort based on a specific property.
 * 
 * @version $Rev$
 */
public class DynamicComparator implements Comparator  {

    private String fieldName;
    private int order;
    private Collator collator;
    /**
     * Create a new DynamicComparator that 
     * can be used to compare indivdual beans..
     * @param fieldNameIn Name of field you want to use in 
     * the bean to compare to
     * 
     * @param sortOrder Should be either <code>RequestContext.LIST_SORT_ASC</code> or
     * <code>RequestContext.LIST_SORT_DESC</code> 
     */
    public DynamicComparator(String fieldNameIn, String sortOrder) {
        this (fieldNameIn, RequestContext.SORT_ASC.equals(sortOrder));
    }
    
    /**
     * Create a new DynamicComparator that 
     * can be used to compare indivdual beans..
     * @param fieldNameIn Name of field you want to use in 
     * the bean to compare to
     * 
     * @param ascending true for ascending order 
     */
    public DynamicComparator(String fieldNameIn, boolean ascending) {
        this.fieldName = fieldNameIn;
        if (ascending) {
            order = 1;
        }
        else {
            order = -1;
        }
    }    
    
    /**
     * {@inheritDoc}
     */
    public int compare(Object o1, Object o2) {
        Comparable val1 = null;
        Comparable val2 = null;
        try {
            val1 = (Comparable)PropertyUtils.getProperty(o1, fieldName);
            val2 = (Comparable)PropertyUtils.getProperty(o2, fieldName);
            if (val1 instanceof String  && val2 instanceof String) {
                return order * getCollator().compare(val1, val2);
            }
            // a < b = -1, a > b = 1 , a== b =0
            
            if (val1 == null && val2 != null) {
                return order * -1;
            }
            else if (val1 != null && val2 == null) {
                return order * 1;
            }
            else if (val1 == val2) {
                return 0;
            }
            return order * val1.compareTo(val2);            
        }
        catch (Exception e) {
            throw new IllegalArgumentException("Exception trying to compare " +
                    "two objects: o1: " + o1 + " o2: " + o2 + " with field: " + 
                    this.fieldName + " generated this exception: " + e);
        }
    }
    
    /**
     * @return Returns the fieldName.
     */
    public String getFieldName() {
        return fieldName;
    }

    private Collator getCollator() {
        if (collator == null) {
            collator = LocalizationService.getInstance().newCollator();
        }
        return collator;
    }
}

