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
package com.redhat.rhn.domain.rhnset;

import java.util.Set;

/**
 * RhnSet
 * @version $Rev$
 */
public interface RhnSet extends Set {

    /**
     * Setter for user id
     * @param id User id associated with this Set.
     */
    void setUserId(Long id);

    /**
     * Getter for user id
     * @return UserId associated with this Set.
     */
    Long getUserId();

    /**
     * Setter for label
     * @param lbl Label for this Set.
     */
    void setLabel(String lbl);

    /**
     * Getter for label
     * @return Set label
     */
    String getLabel();

    /**
     * Add a new element to the Set.
     * @param e Element to add
     */
    void addElement(RhnSetElement e);

    /**
     * Add a new element to the Set
     * @param elem Element one.
     * @param elemTwo Element two, can be null.
     * @param elemThree Element three, can be null.
     */
    void addElement(Long elem, Long elemTwo, Long elemThree);

    /**
     * Add a new element to the Set.
     * @param elem Element one.
     * @param elemTwo Element two, can be null.
     */
    void addElement(Long elem, Long elemTwo);

    /**
     * Add a new element to the Set.
     * @param elem Element one
     */
    void addElement(Long elem);

    /**
     * Add a new element to the Set.
     * @param elem Element one  or Element1|Element2
     */
    void addElement(String elem);

    /**
     * Adds an array of elements to the set.
     * @param elems String [] - array of elements to add
     */
    void addElements(String [] elems);

    /**
     * Removes an array of elements to the set.
     * @param elems String [] - array of elements to add
     */
    void removeElements(String [] elems);

    /**
     * Remove an element from the set
     * @param e Element to remove
     */
    void removeElement(RhnSetElement e);

    /**
     * Remove an element from the set
     * @param elem value for element
     * @param elemTwo value for elementTwo
     */
    void removeElement(Long elem, Long elemTwo);

    /**
     * Remove an element from the set
     * @param elem value for element
     */
    void removeElement(Long elem);

    /**
     * Clear the set - remove all elements
     */
    void clear();

    /**
     * Returns a java.util.Set of the Elements in the RhnSet.
     * @return java.util.Set of the Elements in the RhnSet.
     */
    Set <RhnSetElement> getElements();

    /**
     * Returns a java.util.Set of the Long values in each RhnSetElement.
     *
     * NOTE: does not include the element2 values.
     *
     * @return java.util.Set values in the RhnSet.
     */
    Set <Long>getElementValues();

    /**
     * Returns whether or not the set contains the given RhnSetElement
     * @param e RhnSetElement to look for
     * @return true or false
     */
    boolean contains(RhnSetElement e);

    /**
     * Returns whether or not the set contains the given RhnSetElement
     * given elem and elemTwo
     * @param elem first elem to look for
     * @param elemTwo second elem to look for
     * @return true or false
     */
    boolean contains(Long elem, Long elemTwo);

    /**
     * Returns whether or not the set contains the given RhnSetElement
     * given elem (elementTwo is assumed to be null)
     * @param elem first elem to look for
     * @return true or false
     */
    boolean contains(Long elem);

    /**
     * Returns the size of the element list for the set
     * @return elements.size()
     */
    int size();

    /**
     * Determine if the set is empty
     * @return true if the set is empty
     */
    boolean isEmpty();
}
