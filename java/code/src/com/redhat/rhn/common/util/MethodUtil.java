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

package com.redhat.rhn.common.util;

import com.redhat.rhn.common.MethodInvocationException;
import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.translation.TranslationException;
import com.redhat.rhn.common.translation.Translator;

import org.apache.log4j.Logger;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

/**
 * A simple class that assists with method invocation.  We should just use
 * the jakarta-commons MethodUtils class, but that class can't deal with
 * static methods, so it is useless to us.
 * @version $Rev$
 */
public class MethodUtil {

    private static Logger log = Logger.getLogger(MethodUtil.class);

    /**
     * Private constructore
     */
    private MethodUtil() {
    }

    /* This is insanity itself, but the reflection APIs ignore inheritance.
     * So, if you ask for a method that accepts (Integer, HashMap, HashMap),
     * and the class only has (Integer, Map, Map), you won't find the method.
     * This method uses Class.isAssignableFrom to solve this problem.
     */
    private static boolean isCompatible(Class[] declaredParams, Object[] params) {
        if (params.length != declaredParams.length) {
            return false;
        }

        for (int i = 0; i < params.length; i++) {
            if (!declaredParams[i].isInstance(params[i])) {
                return false;
            }
        }
        return true;
    }


    /**
     * Invoke a static method from a class.
     * @param clazz The Class to search for the specified method
     * @param method The method to execute.
     * @param args the Arguments to the method.
     * @return The result of the called method.
     * @throws NoSuchMethodException If the method can't be found
     * @throws IllegalAccessException if the method cannot be accessed
     * @throws InvocationTargetException if the method throws an exception
     */
    public static Object invokeStaticMethod(Class clazz, String method,
                                            Object[] args)
        throws NoSuchMethodException, IllegalAccessException,
               InvocationTargetException {
        Method[] meths = clazz.getMethods();

        for (int i = 0; i < meths.length; i++) {
            if (!meths[i].getName().equals(method)) {
                continue;
            }
            if (!Modifier.isStatic(meths[i].getModifiers())) {
                throw new MethodNotStaticException("Method " + method + " is not static");
            }
            if (isCompatible(meths[i].getParameterTypes(), args)) {
                return meths[i].invoke(null, args);
            }
        }
        throw new NoSuchMethodException("Could not find " + method + " in " + clazz);
    }

    /**
     * Call the specified method with the specified arguments, converting
     * the argument type if necessary.
     * @param o The object from which to call the method
     * @param methodCalled The method to call
     * @param params a Collection of the parameters to methodCalled
     * @return the results of the method of the subclass
     */
    public static Object callMethod(Object o, String methodCalled,
                                    Object... params) {
        /* This whole method is currently an ugly mess that needs to be
         * refactored.   rbb
         */
        if (log.isDebugEnabled()) {
            log.debug("Trying to call: " + methodCalled + " in " + o.getClass());
        }
        Class myClass = o.getClass();
        Method[] methods;
        try {
            methods = myClass.getMethods();
        }
        catch (SecurityException e) {
            // This should _never_ happen, because the Handler classes must
            // have public classes if they're expected to work.
            throw new IllegalArgumentException("no public methods in class " + myClass);
        }

        Method foundMethod = null;
        Object[] converted = new Object[params.length];
        boolean rightMethod = false;
        for (int i = 0; i < methods.length; i++) {
            if (methods[i].getName().equals(methodCalled)) {
                foundMethod = methods[i];

                Class[] types = foundMethod.getParameterTypes();
                if (types.length != params.length) {
                    continue;
                }

                // We have a method that might work, now we need to loop
                // through the params and make sure that the types match
                // with what was provided in the Collection.  If they don't
                // match, try to do a translation, if that fails try the next
                boolean found = true;
                for (int j = 0; j < types.length; j++) {
                    Object curr = params[j];
                    if (log.isDebugEnabled()) {
                        log.debug("Trying to translate from: " +
                                 ((curr == null) ? null : curr.getClass()) +
                                 " to: " + types[j] +
                                 " isInstance: " + types[j].isInstance(curr));
                    }
                    if (curr != null && curr.getClass().isPrimitive() &&
                        types[j].isPrimitive()) {
                        if (log.isDebugEnabled()) {
                            log.debug("2 primitives");
                        }
                        converted[j] = curr;
                    }
                    if ((curr == null && !types[j].isPrimitive()) ||
                        types[j].isInstance(curr)) {
                        if (log.isDebugEnabled()) {
                            log.debug("same type");
                        }
                        converted[j] = curr;
                        continue;
                    }
                    try {
                        if (log.isDebugEnabled()) {
                            log.debug("calling converter: " + curr);
                        }
                        converted[j] = Translator.convert(curr, types[j]);
                    }
                    catch (TranslationException e) {
                        log.debug("Couldn't translate between " + curr +
                                  " and " + types[j]);
                        // move on to the next method.
                        found = false;
                        break;
                    }
                }
                if (found) {
                    rightMethod = found;
                    break;
                }
            }
        }

        if (!rightMethod) {
            String message = "Could not find method called: " + methodCalled +
                           " in class: " + o.getClass().getName() + " with params: [";
            for (int i = 0; i < params.length; i++) {
                if (params[i] != null) {
                    message = message + ("type: " + params[i].getClass().getName() +
                              ", value: " + params[i]);
                    if (i < params.length - 1) {
                        message = message + ", ";
                    }
                }
            }
            message = message + "]";
            throw new MethodNotFoundException(message);
        }
        try {
            return foundMethod.invoke(o, converted);
        }
        catch (IllegalAccessException e) {
            throw new MethodInvocationException("Could not access " + methodCalled, e);
        }
        catch (InvocationTargetException e) {
            e.printStackTrace();
            throw new MethodInvocationException("Something bad happened when " +
                                                "calling " + methodCalled, e);
        }
    }




    /**
     * Get an instance of a class that can have its classname overridden in our config
     * system.  If you want a class to not return an instance of the passed in parameter
     * you need to define a config with that same name.  For example:
     *
     * List someList = getClassFromConfig("java.lang.LinkedList");
     *
     * would return a new LinkedList() object.
     *
     * But if you define a config var with:
     *
     * java.lang.LinkedList = com.redhat.rhn.utilRhnSuperLinkedList
     *
     * you will get an instance of that class. Beware this can cause some weird issues
     * if done improperly.
     *
     * @param className to fetch
     * @param args arguments to the constructor.
     * @return Object created.  will throw exception explosion if you
     * define this incorrectly
     */
    public static Object getClassFromConfig(String className, Object... args) {
        return callNewMethod(getClassNameFromConfig(className), args);
    }

    /**
     * Return the classname from the config.  Useful if you want to configure a different
     * class to be returned in specific instances.
     * @param className to check for overridden value.
     * @return className from config or the className from parameter if not found
     */
    private static String getClassNameFromConfig(String className) {
        return Config.get().getString(className, className);
    }

    /**
     * Create a new instance of the classname passed in.
     *
     * @param className
     * @return instance of class passed in.
     */
    private static Object callNewMethod(String className, Object... args) {
        Object retval = null;

        try {
            Class clazz = Thread.currentThread().
                            getContextClassLoader().loadClass(className);
            if (args == null || args.length == 0) {
                retval = clazz.newInstance();
            }
            else {
                try {
                    Constructor[] ctors = clazz.getConstructors();
                    for (Constructor ctor : ctors) {
                        if (isCompatible(ctor.getParameterTypes(), args)) {
                            return ctor.newInstance(args);
                        }
                    }
                }
                catch (IllegalArgumentException e) {
                    throw new RuntimeException(e);
                }
                catch (InvocationTargetException e) {
                    throw new RuntimeException(e);
                }
            }

        }
        catch (InstantiationException e) {
           throw new RuntimeException(e);
        }
        catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }
        catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        return retval;
    }
}
