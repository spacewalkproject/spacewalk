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
package com.redhat.rhn.scripts;

import org.apache.bcel.Repository;
import org.apache.bcel.classfile.Constant;
import org.apache.bcel.classfile.ConstantPool;
import org.apache.bcel.classfile.ConstantString;
import org.apache.bcel.classfile.JavaClass;

/**
 * A program to find hard-coded strings in java class files
 *
 * @version $Rev$ 
 */
class FindStrings {

    private FindStrings() {
    }

    /**
     * Main class, to find strings in class files.
     * @param args Arguments to program.
     */
    public static void main(String[] args) {
        try {
            JavaClass clazz = Repository.lookupClass(args[0]);
            ConstantPool cp = clazz.getConstantPool();
            Constant[] consts = cp.getConstantPool();
            

            for (int i = 0; i < consts.length; i++) {

                if (consts[i] instanceof ConstantString) {
                    System.out.println("Found String: " + 
                            ((ConstantString)consts[i]).getBytes(cp));
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
