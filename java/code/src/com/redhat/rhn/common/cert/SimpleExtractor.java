/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.common.cert;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.beanutils.PropertyUtils;
import org.jdom.Element;
import org.jdom.JDOMException;

import java.lang.reflect.InvocationTargetException;

/**
 * SimpleExtractor
 * @version $Rev$
 */
class SimpleExtractor implements FieldExtractor {

    private String fieldName;
    private String propertyName;
    private boolean required;

    public SimpleExtractor(String name) {
        this(name, name, false);
    }
    
    public SimpleExtractor(String fieldName0, String propertyName0) {
        this(fieldName0, propertyName0, false);
    }
    
    public SimpleExtractor(String name, boolean required0) {
        this(name, name, required0);
    }
    
    /**
     * 
     */
    public SimpleExtractor(String fieldName0, String propertyName0, boolean required0) {
        fieldName = fieldName0;
        propertyName = propertyName0;
        required = required0;
    }

    /**
     * {@inheritDoc}
     * @throws JDOMException
     */
    public void extract(Certificate target, Element field) throws JDOMException {
        if (!PropertyUtils.isWriteable(target, propertyName)) {
            throw new JDOMException("Property " + propertyName +
                                    " is not writable in target " + target);
        }
        
        try {
            BeanUtils.setProperty(target, propertyName, field.getTextTrim());
        } 
        catch (IllegalAccessException e) {
            throw new JDOMException("Could not set value of property " + propertyName, e);
        }
        catch (InvocationTargetException e) {
            throw new JDOMException("Could not set value of property " + propertyName, e);
        }
    }

    /**
     * {@inheritDoc}
     */
    public boolean isRequired() {
        return required;
    }

    /**
     * {@inheritDoc}
     */
    public String getFieldName() {
        return fieldName;
    }

}
