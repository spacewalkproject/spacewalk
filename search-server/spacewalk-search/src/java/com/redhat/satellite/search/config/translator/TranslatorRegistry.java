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
package com.redhat.satellite.search.config.translator;

import com.redhat.satellite.search.config.KeyTranslator;

import java.util.LinkedList;
import java.util.List;


/**
 * TranslatorRegistry
 * @version $Rev$
 */
public class TranslatorRegistry {

    private TranslatorRegistry() {
        // hide the default constructor
    }
    
    private static final List<Class> TRANSLATOR_CLASSES;
    static {
        TRANSLATOR_CLASSES = new LinkedList<Class>();
        TRANSLATOR_CLASSES.add(HibernateToSearchTranslator.class);
    }
    
    private static List<KeyTranslator> translators = new LinkedList<KeyTranslator>();
    
    /**
     * Returns the list of all available translators.
     * @return the list of all available translators.
     */
    public static List<KeyTranslator> getTranslators() {
        if (translators.isEmpty() && !TRANSLATOR_CLASSES.isEmpty()) {
            for (Class clazz : TRANSLATOR_CLASSES) {
                try {
                        Object s = clazz.newInstance();
                        translators.add((KeyTranslator)s);
                }
                catch (Exception e) {
                    e.printStackTrace(System.out);
                }
            }
        }
        
        return translators;
    }
}
