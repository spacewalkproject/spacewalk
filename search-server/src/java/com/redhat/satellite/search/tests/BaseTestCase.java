package com.redhat.satellite.search.tests;

import com.redhat.satellite.search.config.Configuration;

import org.picocontainer.defaults.DefaultPicoContainer;

import junit.framework.TestCase;

public abstract class BaseTestCase extends TestCase {
    
    protected DefaultPicoContainer container;

    @Override
    protected void setUp() throws Exception {
        System.getProperties().put("isTesting", "true");
        super.setUp();
        container = TestUtil.buildContainer(getComponentClasses());
        container.start();
    }

    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
        Configuration config = (Configuration) 
            container.getComponentInstanceOfType(Configuration.class);
        TestUtil.cleanupDirectories(config); 
        container.stop();
    }
    
    @SuppressWarnings("unchecked")
    protected abstract Class[] getComponentClasses();

}
