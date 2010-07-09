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

import org.apache.commons.lang.builder.EqualsBuilder;

import java.util.HashMap;

/**
 * An wrapper around HashMap that ONLY acccepts
 * java.lang.Characters and java.lang.Integers.
 *
 * 5.0: This class should be removed once we
 * switch to Java 5.0 and we get Generics.
 *
 * @version $Rev: 325 $
 */
public class CharacterMap {

    private HashMap innerMap;

    /**
    * public constructor
    */
    public CharacterMap() {
        innerMap = new HashMap();
    }

    /**
    * Add charIn and intIn to the map.
    * @param charIn Character to add
    * @param intIn Integer to add
    */
    public void put(Character charIn, Integer intIn) {
        innerMap.put(charIn, intIn);
    }

    /**
    * Add charIn and intIn to the map.
    * @param charIn Character to add
    * @param intIn Integer to add
    */
    public void put(char charIn, int intIn) {
        innerMap.put(new Character(charIn), new Integer(intIn));
    }

    /**
     * Retrieve value
     * @param key Character you want the starting position of
     * @return Integer for corresponding key
     */
    public Integer get(Character key) {
        return (Integer)innerMap.get(key);
    }

    /**
     * Retrieve value
     * @param key Character you want the starting position of
     * @return Integer for corresponding key
     */
    public Integer get(char key) {
        return (Integer)innerMap.get(new Character(key));
    }

    /**
    * Check to see if the map contains this character
    * @param charTest The character to test
    * @return true if the character is in the map, false otherwise
    */
    public boolean containsKey(Character charTest) {
        return innerMap.containsKey(charTest);
    }

    /**
    * Check to see if the map contains this character
    * @param charTest The character to test
    * @return true if the character is in the map, false otherwise
    */
    public boolean containsKey(char charTest) {
        return innerMap.containsKey(new Character(charTest));
    }

    /**
     * Implement size function for CharacterMap
     * @return Number of elements in CharacterMap
     */
    public int size() {
        return innerMap.size();
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object o) {
        if (o == null || !(o instanceof CharacterMap)) {
            return false;
        }
        CharacterMap other = (CharacterMap)o;
        return new EqualsBuilder().append(this.innerMap, other.innerMap)
                                  .isEquals();
    }

    /**
     * Implement hashCode for CharacterMap
     * @return hashCode for innerMap
     */
    public int hashCode() {
        return innerMap.hashCode();
    }

    /** {@inheritDoc} */
    public String toString() {
        return innerMap.toString();
    }
}
