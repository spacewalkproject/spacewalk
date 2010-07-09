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
package com.redhat.rhn.frontend.action.user;


/**
 * UserRoleStatusBean
 * @version $Rev$
 */
public class UserRoleStatusBean {

    private String name;
    private String value;
    private boolean selected;
    private boolean disabled;

    /**
     * Constructor.
     *
     * Note: if both addable and removable are false, the role is read-only.
     *
     * @param nameIn User visible name for this role.
     * @param valueIn Role label in the database.
     * @param selectedIn Does the user currently have this role.
     * @param disabledIn Is the role modifiable for this user.
     */
    public UserRoleStatusBean(String nameIn, String valueIn, boolean selectedIn,
            boolean disabledIn) {

        this.name = nameIn;
        this.value = valueIn;
        this.selected = selectedIn;
        this.disabled = disabledIn;
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

    /**
     * @return Returns the disabled.
     */
    public boolean isDisabled() {
        return disabled;
    }

    /**
     * @param disabledIn The disabled to set.
     */
    public void setRemovable(boolean disabledIn) {
        this.disabled = disabledIn;
    }

    /**
     * @return Returns the selected.
     */
    public boolean isSelected() {
        return selected;
    }


    /**
     * @param selectedIn The selected to set.
     */
    public void setSelected(boolean selectedIn) {
        this.selected = selectedIn;
    }

}
