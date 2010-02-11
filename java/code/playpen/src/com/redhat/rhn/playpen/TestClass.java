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
package com.redhat.rhn.playpen;

/**
 * TestClass
 * @version $Rev$
 */
public class TestClass {

    private String foo;
    private String bar;
    private String baz;
    
    /**
     * @return the bar
     */
    public String getBar() {
        return bar;
    }
    
    /**
     * @param bar The bar to set.
     */
    public void setBar(String bar) {
        this.bar = bar;
    }
    
    /**
     * @return the baz
     */
    public String getBaz() {
        return baz;
    }
    
    /**
     * @param bazIn The baz to set.
     */
    public void setBaz(String bazIn) {
        this.baz = bazIn;
    }
    
    /**
     * @return the foo
     */
    public String getFoo() {
        return foo;
    }
    
    /**
     * @param fooIn The foo to set.
     */
    public void setFoo(String fooIn) {
        this.foo = fooIn;
    }
}
