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

import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/*
 * $Rev$
 */
public class TestFactory extends HibernateFactory {

    private static Logger log = Logger.getLogger(TestFactory.class);
    private static TestFactory singleton = new TestFactory();

    private TestFactory() {
        super();
    }

    /**
     * Return the Implementation class used by the derived 
     * class's Factory
     */
    protected Class getImplementationClass() {
        return TestImpl.class;
    
    }
    
    /** Get the Logger for the derived class so log messages
    *   show up on the correct class
    */
    protected Logger getLogger() {
        return log;
    }

    public static TestInterface createTest() {
        TestInterface retval = new TestImpl();
        return retval; 
    }

    public static TestInterface lookupByFoobar(String f) {
        // Get PersonalInfo row
        Map m = new HashMap();
        m.put("fooBar", f);
        return (TestInterface) singleton.lookupObjectByNamedQuery("Test.findByFoobar", m);
    }
    
    public static List lookupAll() {
        return singleton.listObjectsByNamedQuery("Test.findAll", null);
    }
    
    public static void save(TestInterface t) {
        singleton.saveObject(t);
    }
    
}
