/**
 * Copyright (c) 2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.struts;


/**
 * SelectableLabelValueBean
 * @version $Rev$
 */
public class SelectableLabelValueBean extends SelectableAdapter {

    private String label;
    private String value;

    /**
     * @param labelIn label
     * @param valueIn value
     * @param selectedIn selected property
     * @param disabledIn disabled property
     *
     */
    public SelectableLabelValueBean(String labelIn, String valueIn, boolean selectedIn,
            boolean disabledIn) {
        label = labelIn;
        value = valueIn;
        setSelected(selectedIn);
        setDisabled(disabledIn);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getSelectionKey() {
        return label;
    }


    /**
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }


    /**
     * @param labelIn The label to set.
     */
    public void setLabel(String labelIn) {
        label = labelIn;
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
        value = valueIn;
    }
}
