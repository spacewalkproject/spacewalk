/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.serializer.util;

import com.redhat.rhn.common.util.StringUtil;

import org.apache.commons.beanutils.PropertyUtils;
import org.apache.log4j.Logger;

import java.io.Writer;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * SerializerHelper
 * @version $Rev$
 */
public class BeanSerializer {
    private Set excludes;
    private Set includes;
    private static Logger log = Logger.getLogger(BeanSerializer.class); 

    /**
     * Constructor
     */
    public BeanSerializer() {
        excludes = new LinkedHashSet();
        includes = new LinkedHashSet();

        // don't want to try and serialize class
        excludes.add("class");
    }
    /**
     * Add a debeanified name that must be excluded from the final map 
     * @param fieldName the debeanified property name to exclude
     */
    public void exclude(String fieldName) {
        excludes.add(fieldName);
    }
    
    /**
     *  
     * @param fieldName the debeanified property name
     *              to be included in the final map.
     */
    public void include(String fieldName) {
        includes.add(fieldName);
    }    
    
    
    /**
     * Basically you pass in a bean object to it and it spits out the
     * serialized version of bean object where the name is the
     * debeanified method name and the value is what ever the method
     * returns.
     * 
     * Basic operation is (Master List ^ includes) - excludes
     * Where ^ = intersection
     * However there is on catch ...
     * If "includes" is empty, it includes everything.. 
     * ie... includes  = empty ==> Master List - excludes
     *  
     * @param bean the bean object to be serialized
     * @param output the string buffer to be updated for the serializer.
     * @param serializer helper class to serialize basic objects.
     * @throws XmlRpcException thrown during describing a bean or the
     * serializer throws an error.
     */
    public void serialize(Object bean, Writer output, SerializerHelper serializer) 
        throws XmlRpcException {
        
        try {
            Map properties = PropertyUtils.describe(bean);
            for (Iterator itr = excludes.iterator(); itr.hasNext();) {
                properties.remove(itr.next());
            }
            if (!includes.isEmpty()) {
                for (Iterator itr = includes.iterator(); itr.hasNext();) {
                    String include = (String)itr.next();
                    if (properties.containsKey(include)) {
                        serializer.add(StringUtil.debeanify(include), 
                                    properties.get(include));
                    }
                }
            }
            else {
                for (Iterator itr = properties.keySet().iterator(); itr.hasNext();) {
                    String key = (String)itr.next();
                    serializer.add(StringUtil.debeanify(key),
                                properties.get(key));
                }                
            }
            serializer.writeTo(output);
        }
        catch (XmlRpcException e) {
            log.error(e);
            throw e;
        }        
        catch (Exception e) {
            log.error(e);
            throw new XmlRpcException("Caught error trying to describe a bean. ", e);
        }
    }

    
    /**
     * Basically you pass in a bean object to it and it spits out the
     * serialized version of bean object where the name is the
     * debeanified method name and the value is what ever the method
     * returns.
     * 
     * Basic operation is (Master List ^ includes) - excludes
     * Where ^ = intersection
     * However there is on catch ...
     * If "includes" is empty, it includes everything.. 
     * ie... includes  = empty ==> Master List - excludes
     *  
     * @param bean the bean object to be serialized
     * @param output the string buffer to be updated for the serializer.
     * @param serializer the built-in XmlRpcSerializer
     * @throws XmlRpcException thrown during describing a bean or the
     * serializer throws an error.
     */
    
    public void serialize(Object bean, Writer output,
                                    XmlRpcSerializer serializer)
                                            throws XmlRpcException {
        serialize(bean, output, new SerializerHelper(serializer));
    }
}
