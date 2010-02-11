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

package com.redhat.rhn.frontend.xmlrpc.serializer;

import java.util.ArrayList;
import java.util.List;

import redstone.xmlrpc.XmlRpcCustomSerializer;

/**
 * HandlerFactory, simple factory class that uses ManifestFactory to
 * return RPC Handlers.
 *
 * @version $Rev: 101893 $
 */

public class SerializerFactory {
    private List<XmlRpcCustomSerializer> serializers;
    
    private static final String INTERFACE_NAME =
        "redstone.xmlrpc.XmlRpcCustomSerializer";
    
    /** private constructor */
    public SerializerFactory() {
        serializers = new ArrayList<XmlRpcCustomSerializer>();
        initialize();
    }
    
    /**
     * 
     * @return a list of serializers.
     */
    public List getSerializers() {
        return serializers;
    }
    
    private void initialize() {
        String[] excludes = new String[1];
        excludes[0] = "Test";
        List<Class> classes = SerializerRegistry.getSerializationClasses();
        for (Class clazz : classes) {
            try {
                if (doesClassImplement(clazz, INTERFACE_NAME)) {
                    Object s = clazz.newInstance();
                    serializers.add((XmlRpcCustomSerializer)s);
                }
            }
            catch (Exception e) {
                e.printStackTrace(System.out);
            }
        }
    }
    
    private boolean doesClassImplement(Class clazz, String interfaceName) {
        Class[] interfaces = clazz.getInterfaces();
        boolean found = false;
        for (int i = 0; i < interfaces.length; i++) {
            if (interfaces[i].getName().equals(interfaceName)) {
                found = true;
                break;
            }
        }
        return found;
    }
}
