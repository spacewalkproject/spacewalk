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
package com.redhat.rhn.common.filediff;


/**
 * A single edit for a file diff.
 * One part of a tree of edits in which children point to their parents.
 * @version $Rev$
 */
public class Edit {

    public static final char DELETE = 'd';
    public static final char ADD = 'a';
    public static final char MATCH = 'm';

    private Edit parent;
    private char type;
    private int number;

    /**
     * @param typeIn The edit command (d | a | m)
     * @param parentIn This edits parent.
     */
    protected Edit(char typeIn, Edit parentIn) {
        type = typeIn;
        parent = parentIn;
        number = 1;
    }

    /**
     * @return The edit command.
     */
    public char getType() {
        return type;
    }

    /**
     * @return The number of this type of edit in a row.
     */
    public int getNumber() {
        return number;
    }

    /**
     * @param numberIn The number to set.
     */
    public void setNumber(int numberIn) {
        number = numberIn;
    }

    /**
     * Increment the number.
     */
    public void increment() {
        number++;
    }

    /**
     * @return The parent
     */
    public Edit getParent() {
        return parent;
    }

    /**
     * @return A copy of this edit.
     */
    public Edit copy() {
        Edit clone = new Edit(type, parent);
        clone.setNumber(number);
        return clone;
    }

}
