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

package com.redhat.rhn.frontend.listview;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.CharacterMap;

import java.text.MessageFormat;
import java.util.Iterator;
import java.util.List;

/**
 * AlphaBar, helper class to render a listing of letters/digits that 
 * are contained in a set.  For example a a simple text list could be generated
 * with a list of letters contained within the set passed into the getAlphaList()
 * method.
 * <pre>
 *       CharacterMap charset = new CharacterMap();
 *       charset.add(new Character('A'));
 *       charset.add(new Character('M'));
 *       charset.add(new Character('Z'));
 *       charset.add(new Character('5'));
 *       AlphaBar ab = new AlphaBar("{0}* ", "{0} ");
 *       System.out.println(ab.getAlphaList(charset));
 * </pre>
 * produces the following output:
 * 
 * A* B C D E F G H I J K L M* N O P Q R S T U V W X Y Z* 1 2 3 4 5* 6 7 8 9 0
 *
 * With each letter highlighted with an * indicating its contained within the set
 *
 * @version $Rev: 448 $
 */

public class AlphaBar {

    private String charEnabled;
    private String charDisabled;

    /**
     * Public constructor.  In order for the characters to be 
     * parameterized on a per character basis, the paramters 
     * must include a numbered parameter to indicate where to place
     * the alphanumeric character within the string if it is or is not
     * contained within the set. 
     * This simply means you must include a {0} in the string to indicate 
     * where you want the character to go. If the Character is enabled, {1} 
     * represents the starting point in the DataResult of that character.
     * @param charEnabledIn the MessageFormat style text 
     * @param charDisabledIn the MessageFormat style text 
     */
    public AlphaBar(String charEnabledIn, String charDisabledIn) {
        charEnabled = charEnabledIn;
        charDisabled = charDisabledIn;
    }

    /** 
    * get the alphabetical list of enabled and disabled 
    * elements in the alphabet.  See above for examples.
    * 
    * @param charsEnabled the set of characters that are 
    * contained within the listview.
    * @return String representation of Alpha bar with the
    * correct characters enabled.
    */
    public String getAlphaList(CharacterMap charsEnabled) {
        StringBuffer target = new StringBuffer();
        // Get the list of all the letters and digits in current thread's Locale
        // and put them together in the collection
        List alist = LocalizationService.getInstance().getAlphabet();
        alist.addAll(LocalizationService.getInstance().getDigits());
        Iterator it = alist.iterator();
        // Iterator over each character and determine if we need to 
        // enable or disable the row.
        while (it.hasNext()) {
            String ch = (String) it.next();
            // Format the message with current char as parameter
            MessageFormat form;

            if (charsEnabled.containsKey(ch.charAt(0))) {
                Object[] charArg = {ch, charsEnabled.get(ch.charAt(0)).toString()};
                form = new MessageFormat(charEnabled);
                target.append(form.format(charArg).toString());
            } 
            else {
                Object[] charArg = {ch};
                form = new MessageFormat(charDisabled);
                target.append(form.format(charArg).toString());
            }

        }
        return target.toString();
    }

}


