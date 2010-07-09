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

import com.redhat.rhn.common.util.manifestfactory.ClassBuilder;
import com.redhat.rhn.common.util.manifestfactory.ManifestFactory;

import java.util.Collection;

/**
 * HandlerFactory, simple factory class that uses ManifestFactory to
 * return RPC Handlers.
 *
 * @version $Rev$
 */

public class HandlerFactory {
    private ManifestFactory factory;
    private static final String PKG_NAME = "com.redhat.rhn.frontend.xmlrpc";

    /** private constructor */
    public HandlerFactory() {
        this(new ClassBuilder(PKG_NAME, "handler-manifest.xml"));
    }

    protected HandlerFactory(ClassBuilder builder) {
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
}
