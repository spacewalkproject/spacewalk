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

package com.redhat.rhn.frontend.xmlrpc;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.util.manifestfactory.ClassBuilder;
import com.redhat.rhn.common.util.manifestfactory.ManifestFactory;

import org.apache.commons.lang.StringUtils;

import java.util.Collection;

/**
 * HandlerFactory, simple factory class that uses ManifestFactory to
 * return RPC Handlers.
 *
 * @version $Rev$
 */

public class HandlerFactory {
    public static final String HANDLER_MANIFEST = "handler-manifest";
    
    private ManifestFactory factory;
    private static final String PKG_NAME = "com.redhat.rhn.frontend.xmlrpc";
    public static final String DEFAULT_MANIFEST = "handler-manifest.xml"; 
    /** Handler constructor */
    public HandlerFactory() {
        String manifest = StringUtils.defaultIfEmpty(Config.get().
                        getString("handler-manifest"), DEFAULT_MANIFEST);
        setup(manifest);
    }

    /**
     * Constructor that takes in a given handler manifest file
     * mainly used for unit test
     * @param handlerManifest the name of the manifest-xml
     */
    public HandlerFactory(String handlerManifest) {
        setup(handlerManifest);
    }    
    
    protected void setup(String handlerManifest) {
        ClassBuilder builder = new ClassBuilder(PKG_NAME, handlerManifest);
        factory = new ManifestFactory(builder);
    }

    /**
     * getHandler - function to, given a handlerName (corresponding to
     * an entry in handler-manifest.xml) return the Handler object
     * @param handlerName the name of the handler
     * @return Object of the handler in question.
     */
    public BaseHandler getHandler(String handlerName) {
        return (BaseHandler)factory.getObject(handlerName);
    }

    /** 
     * Get all keys from the Factory.
     * @return All keys from the Factory.
     */
    public Collection getKeys() {
        return factory.getKeys();
    }
    
    /**
     * Sets the handler manifest config entry
     * @param value the handler manifest xml location
     */
    public static void setDefaultHandlerManifest(String value) {
        Config.get().setString(HANDLER_MANIFEST, value);
    }
    
    /**
     * @return the handler manifest location
     */
    public static String getHandlerManifest() {
        return StringUtils.defaultIfEmpty(Config.get().
                getString(HANDLER_MANIFEST), DEFAULT_MANIFEST);        
    }    
}
