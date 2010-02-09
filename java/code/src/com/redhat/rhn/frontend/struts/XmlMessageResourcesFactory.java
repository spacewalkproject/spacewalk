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

package com.redhat.rhn.frontend.struts;

import org.apache.struts.util.MessageResources;
import org.apache.struts.util.MessageResourcesFactory;

/**
 * XmlMessageResourcesFactory - factory class used by Struts to 
 * get to the XML based 
 * @version $Rev$
 */

public class XmlMessageResourcesFactory extends MessageResourcesFactory {

    /**
     * Create and return a newly instansiated <code>MessageResources</code>.
     * This method must be implemented by concrete subclasses.
     *
     * @param config Configuration parameter(s) for the requested bundle
     * @return A new instance of a MessageResources class.
     */
    public MessageResources createResources(String config) {
        return new XmlMessageResources(this, config, this.returnNull);
    }
    
    /**
     * Create and return a <code>MessageResourcesFactory</code> instance of the
     * appropriate class, which can be used to create customized
     * <code>MessageResources</code> instances.  If no such factory can be
     * created, return <code>null</code> instead.
     * @return an appropriate instance of the MessageResourceFactory.
     */
    public static MessageResourcesFactory createFactory() {
        // Force the factoryclass to be set to the one *we* want it to be set to.
        // Struts is hardcoded in the base class MessageResourcesFactory
        // to use PropertyMessageResourceFactory which is lame, IMHO
        XmlMessageResourcesFactory.
            setFactoryClass("com.redhat.rhn.frontend.struts.XmlMessageResourcesFactory");
        // Since its a static method we can't override it, we have to encapsulate it
        return MessageResourcesFactory.createFactory();
    }    


}
