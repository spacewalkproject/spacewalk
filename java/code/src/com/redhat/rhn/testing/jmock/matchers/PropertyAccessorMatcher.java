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
package com.redhat.rhn.testing.jmock.matchers;

import org.jmock.core.Invocation;
import org.jmock.core.matcher.StatelessInvocationMatcher;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.lang.reflect.Method;

import junit.framework.AssertionFailedError;

/**
 * PropertyAccessorMatcher is a custom InvocationMatcher that matches JavaBean property
 * accessor methods. A property accessor is of the form, <code>getXXX()</code> or
 * <code>isXXX()</code>. For a full description of JavaBean properties, see the
 * <a href="http://java.sun.com/products/javabeans/docs/spec.html">
 *   JavaBeans specfication
 * </a>
 * <br/><br/>
 * The code in
 * <a href=http://www.jmock.org/custom-matchers.html">Writing Custom Invocation Matchers</a>
 * forms the basis for this class.
 *
 * @version $Rev$
 */
public class PropertyAccessorMatcher extends StatelessInvocationMatcher {

    /**
     * {@inheritDoc}
     */
    public boolean matches(Invocation invocation) {
        return isPropertyAccessor(invocation.invokedMethod,
                invocation.invokedMethod.getDeclaringClass());
    }

    /**
     * Returns <code>true</code> if the invoked method is a property accessor of the bean
     * class.
     *
     * @param invokedMethod The invoked method.
     * @param beanClass The class on which the method was invoked.
     * @return <code>true</code> if the invoked method is a property accessor of the bean
     * class.
     */
    private boolean isPropertyAccessor(Method invokedMethod, Class beanClass) {
        try {
            BeanInfo beanInfo = Introspector.getBeanInfo(beanClass);
            PropertyDescriptor[] propertyDescriptors = beanInfo.getPropertyDescriptors();

            for (int i = 0; i < propertyDescriptors.length; ++i) {
                if (invokedMethod.equals(propertyDescriptors[i].getReadMethod())) {
                    return true;
                }
            }
            return false;
        }
        catch (IntrospectionException e) {
            throw new AssertionFailedError("could not introspect bean class " + beanClass +
                    ": " + e.getMessage());
        }
    }

    /**
     * {@inheritDoc}
     */
    public StringBuffer describeTo(StringBuffer buffer) {
        return new StringBuffer("any JavaBean property accessor");
    }

}
