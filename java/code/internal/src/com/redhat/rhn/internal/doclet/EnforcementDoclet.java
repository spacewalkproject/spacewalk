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


package com.redhat.rhn.internal.doclet;

import com.sun.javadoc.ClassDoc;
import com.sun.javadoc.FieldDoc;
import com.sun.javadoc.RootDoc;

import java.io.InvalidObjectException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


/**
 *
 * EnforcementDoclet
 *
 * This doclet checks to make sure that we do not have any non static or final member
 * variables in our Actions
 *
 * Exceptions can be added in initializeExceptions()
 *
 * @version $Rev$
 */
public class EnforcementDoclet {


    protected EnforcementDoclet() {
    }


    private static HashMap<String, List<String>> exceptions =
        new HashMap<String, List<String>>();




    /**
     * start the doclet
     * @param root the document root
     * @return boolean
     * @throws Exception e
     */
    public static boolean start(RootDoc root) throws Exception {
        ClassDoc[] classes = root.classes();
        initializeExceptions();
        boolean found = false;

        for (ClassDoc clas : classes) {

            ClassDoc parent = clas.findClass("org.apache.struts.action.Action");
            if (parent == null) {
                System.out.println("Skipping " + clas.name());
                continue;
            }

            if (clas.subclassOf(parent)) {
                for (FieldDoc field : clas.fields()) {
                    if (!field.isFinal() && !hasException(clas.name(), field.name())) {
                        found = true;
                        System.out.println("WARNING: Action Class " + clas.name() +
                                " has member: " + field.name());
                    }
                }
            }
        }
        if (found) {
            throw new InvalidObjectException("Found non-final, non-exempt member " +
                    "variables in one or more Action classes.  See Warnings " +
                    "above for more information.");
        }
        return true;
    }


    private static void initializeExceptions() {
        setException("LoginAction", "pxtDelegate");
        setException("CreateUserAction", "pxtDelegate");
    }




    private static boolean hasException(String clazz, String field) {
        if (field.equals("log") || field.equals("logger")) {
            return true;
        }
        if (exceptions.get(clazz) == null) {
            return false;
        }
        else {
            return exceptions.get(clazz).contains(field);
        }

    }
    private static void setException(String clazz, String field) {
        if (exceptions.get(clazz) == null) {
            exceptions.put(clazz, new ArrayList<String>());
        }
        exceptions.get(clazz).add(field);
    }


}
