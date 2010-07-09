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
package com.redhat.rhn.frontend.xmlrpc.util.test;


/**
 * TestBean
 * @version $Rev$
 */
public class TestBean {
    public static final String DEFAULT_VALUE = "foo";
    private String fieldA = DEFAULT_VALUE;
    private String fieldB = DEFAULT_VALUE;
    private String fieldC = DEFAULT_VALUE;
    private String fieldD = DEFAULT_VALUE;
    private String fieldWierdo = DEFAULT_VALUE;
    private String fieldNull;
    /**
     * @return the fieldA
     */
    public String getFieldA() {
        return fieldA;
    }

    /**
     * @param fieldA the fieldA to set
     */
    public void setFieldA(String val) {
        this.fieldA = val;
    }

    /**
     * @return the fieldB
     */
    public String getFieldB() {
        return fieldB;
    }

    /**
     * @param fieldB the fieldB to set
     */
    public void setFieldB(String val) {
        this.fieldB = val;
    }

    /**
     * @return the fieldC
     */
    public String getFieldC() {
        return fieldC;
    }

    /**
     * @param fieldC the fieldC to set
     */
    public void setFieldC(String val) {
        this.fieldC = val;
    }

    /**
     * @return the fieldD
     */
    public String getFieldD() {
        return fieldD;
    }

    /**
     * @param fieldD the fieldD to set
     */
    public void setFieldD(String val) {
        this.fieldD = val;
    }


    /**
     * @return the fieldWierdo
     */
    public String getFieldWierdo() {
        return fieldWierdo;
    }


    /**
     * @param fieldWierdo the fieldWierdo to set
     */
    public void setFieldWierdo(String val) {
        this.fieldWierdo = val;
    }


    /**
     * @return the fieldNull
     */
    public String getFieldNull() {
        return fieldNull;
    }
}
