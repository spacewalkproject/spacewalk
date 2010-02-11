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
package com.redhat.rhn.frontend.dto;

/**
 * NameDescriptionValue - Simple class that can hold a name, a description and a
 * value for a field.  Can be used in <forms> that have a dynamic set of <input> values
 * where the description field is the header text that is localized.
 * 
 * For example:  
 * Login: <input name="login" value="mmccune" type="text"></input>
 *   |                  |             |
 * description         name          value 
 * 
 * @version $Rev: 50942 $
 */
public class NameDescriptionValue {
    private String name; 
    private String description;
    private String value;
    
    /**
     * Create an instance with default values
     * @param nameIn to be used
     * @param descriptionIn to be used
     * @param valueIn to be used
     */
    public NameDescriptionValue(String nameIn, String descriptionIn, String valueIn) {
        super();
        this.name = nameIn;
        this.description = descriptionIn;
        this.value = valueIn;
    }
    
    /**
     * @return Returns the description.
     */
    public String getDescription() {
        return description;
    }
    /**
     * @param descriptionIn The description to set.
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }
    /**
     * @return Returns the value.
     */
    public String getValue() {
        return value;
    }
    /**
     * @param valueIn The value to set.
     */
    public void setValue(String valueIn) {
        this.value = valueIn;
    }
}
