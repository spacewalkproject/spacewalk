/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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


/**
 * HibernateToSearchTranslator
 * @version $Rev$
 */
public class HibernateToSearchTranslator implements KeyTranslator {

    /**
     * {@inheritDoc}
     */
    public String translateKey(String key) {
        return key.replaceAll("hibernate", "search");
    }

    /**
     * {@inheritDoc}
     */
    public boolean shouldTranslate(String key) {
        return (key.equals("hibernate.connection.driver_class") ||
                key.equals("hibernate.connection.driver_proto"));
    }
}
