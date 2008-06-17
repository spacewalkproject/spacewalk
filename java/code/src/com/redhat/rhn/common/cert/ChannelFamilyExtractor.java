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

import org.jdom.Element;

/**
 * ChannelFamilyExtractor
 * @version $Rev$
 */
class ChannelFamilyExtractor implements FieldExtractor {

    private String fieldName;
    /**
     * 
     */
    public ChannelFamilyExtractor(String fieldName0) {
        fieldName = fieldName0;
   }
    /**
     * {@inheritDoc}
     */
    public void extract(Certificate target, Element field) {
        String quantity = field.getAttributeValue("quantity");
        String family = field.getAttributeValue("family");
        ChannelFamilyDescriptor cf = new ChannelFamilyDescriptor(family, quantity);
        target.addChannelFamily(cf);
    }

    public boolean isRequired() {
        return false;
    }
    
    public String getFieldName() {
        return fieldName;
    }

}
