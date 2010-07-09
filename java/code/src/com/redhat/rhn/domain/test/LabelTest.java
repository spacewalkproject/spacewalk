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
package com.redhat.rhn.domain.test;

import com.redhat.rhn.domain.Label;

import com.gargoylesoftware.base.testing.EqualsTester;

import junit.framework.TestCase;


/**
 * LabelTest
 * @version $Rev$
 */
public class LabelTest extends TestCase {

    class BeerLabel extends Label {
        private String beerLabel;
        private String beerName;

        public BeerLabel(String name, String label) {
            this.beerLabel = label;
            this.beerName = name;
        }

        public String getName() {
            return beerName;
        }

        public String getLabel() {
            return beerLabel;
        }
    }

    /**
     * @param arg0
     */
    public LabelTest(String name) {
        super(name);
    }

    /**
     * Test method for {@link com.redhat.rhn.domain.Label#equals(java.lang.Object)}.
     */
    public void testEqualsObject() {
        BeerLabel negroModelo = new BeerLabel("Negro Model",
                "Negro Modelo....what beer was meant to be");
        BeerLabel anotherNegroModelo = new BeerLabel("Negro Model",
                "Negro Modelo....what beer was meant to be");
        BeerLabel aprihop = new BeerLabel("Aprihop",
                "Aprihop....Dogfish Head bringing you America's finest beer");


        new EqualsTester(negroModelo, anotherNegroModelo, aprihop, new Object());
    }

}
