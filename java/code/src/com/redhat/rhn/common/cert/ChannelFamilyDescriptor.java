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

import com.redhat.rhn.frontend.html.XmlTag;

/**
 * The entitlements for a channel family, consisting
 * of the family name and a quantity.
 *  
 * @version $Rev$
 */
public class ChannelFamilyDescriptor implements Comparable {

    private String family;
    private String quantity;
    
    ChannelFamilyDescriptor(String family0, String quantity0) {
        family = family0;
        quantity = quantity0;
    }

    /**
     * Return the name of this channel family
     * @return the name of this channel family
     */
    public String getFamily() {
        return family;
    }
    
    /**
     * Return the quantity for this family
     * @return the quantity for this family
     */
    public String getQuantity() {
        return quantity;
    }
    
    String asChecksumString() {
        return "channel-families-family-" + getFamily() + "-quantity-" + getQuantity();
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(Object obj) {
        ChannelFamilyDescriptor other = (ChannelFamilyDescriptor) obj;
        // The sort order for families is kinda odd; this replicates
        // exactly the way the Perl code sorts the fields so that
        // signature checking on the result is possible across Perl and Java
        return asSortKey().compareTo(other.asSortKey());
    }
    
    private String asSortKey() {
        return getQuantity() + "familyquantity" + getFamily();
    }
    
    String asXmlString() {
        XmlTag tag = new XmlTag("rhn-cert-field", false);
        tag.setAttribute("name", "channel-families");
        tag.setAttribute("quantity", getQuantity());
        tag.setAttribute("family", getFamily());
        return tag.render();
    }
}
