/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.testing;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * A simple class that stores a global Map of objects that can be used to store 
 * state across test classes.
 * 
 * @version $Rev$
 */
public class TestObjectStore {

    // private instance of the service.
    private static TestObjectStore instance = new TestObjectStore();
    private Map testObjectStore;
    
    
    private TestObjectStore() {
        testObjectStore = new ConcurrentHashMap();
        
    }
    
    /**
     * Get the instance of this Service
     * @return TestObjectStore instance.
     */
    public static TestObjectStore get() {
        return instance;
    }
    
    /**
     * Clear the set of mock objects
     */
    public void clearObjects() {
        testObjectStore.clear();
    }

    /**
     * Add/put an object into the map
     * @param key to store it as
     * @param value to store
     */
    public void putObject(String key, Object value) {
        testObjectStore.put(key, value);
    }
    
    /**
     * Get an object from the store.  Null it not found
     * @param key to lookup
     * @return Object if found.  null if not
     */
    public Object getObject(String key) {
        return testObjectStore.get(key);
    }

    /**
     * Get the set of objects.
     * @return Map of objects in the store
     */
    public Map getObjects() {
        return testObjectStore;
    }
}
