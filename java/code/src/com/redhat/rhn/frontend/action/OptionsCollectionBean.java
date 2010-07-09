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
package com.redhat.rhn.frontend.action;


/**
 * Simple bean class for options collections.
 * OptionsCollectionBean
 * @version $Rev$
 */
public class OptionsCollectionBean {
    private String label;
    private String value;

    /**
     * Create an OptionsCollectionBean with the given label and value.
     * @param labelIn Bean label.
     * @param valueIn Bean value.
     */
    public OptionsCollectionBean(String labelIn, String valueIn) {
        label = labelIn;
        value = valueIn;
    }

    /**
     * Label getter.
     * @return Label for this options collection entry.
     */
    public String getLabel() {
        return label;
    }

    /**
     * Value getter.
     * @return Value for this options collection entry.
     */
    public String getValue() {
        return value;
    }

    /**
     * Value setter.
     * @param valueIn Value to set.
     */
    public void setValue(String valueIn) {
        value = valueIn;
    }

    /**
     * Label setter.
     * @param labelIn Label to set.
     */
    public void setLabel(String labelIn) {
        label = labelIn;
    }

}
