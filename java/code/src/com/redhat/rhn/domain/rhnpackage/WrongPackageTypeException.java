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

/*
 * AUTOMATICALLY GENERATED FILE, DO NOT EDIT.
 */
package com.redhat.rhn.domain.rhnpackage;

import com.redhat.rhn.common.RhnRuntimeException;

/**
 * An exception encountered when an rhn Package object is not of the expected
 * arch type.
 * <p>
 *
 *
 * @version definition($Rev: 76724 $)/template($Rev: 67725 $)
 */
public class WrongPackageTypeException extends RhnRuntimeException {

    private Long pkgId;
    private String pkgClass;
    private String expectedPkgClass;

    // ///////////////////////
    // Constructors
    // ///////////////////////
    /**
     * Constructor
     * @param packageId package id
     * @param packageClass package class
     * @param expectedClass expected package class
     * @param message exception message
     */
    public WrongPackageTypeException(Long packageId, String packageClass,
            String expectedClass, String message) {
        super(message);
        // begin member variable initialization
        this.pkgId = packageId;
        this.pkgClass = packageClass;
        this.expectedPkgClass = expectedClass;
    }

    /**
     * Constructor
     * @param packageId package id
     * @param packageClass package class
     * @param expectedClass expected package class
     * @param message exception message
     * @param cause the cause (which is saved for later retrieval by the
     * Throwable.getCause() method). (A null value is permitted, and indicates
     * that the cause is nonexistent or unknown.)
     */
    public WrongPackageTypeException(Long packageId, String packageClass,
            String expectedClass, String message, Throwable cause) {
        super(message, cause);
        // begin member variable initialization
        this.pkgId = packageId;
        this.pkgClass = packageClass;
        this.expectedPkgClass = expectedClass;
    }

    // ///////////////////////
    // Getters/Setters
    // ///////////////////////
    /**
     * Returns the value of packageId
     * @return Long packageId
     */
    public Long getPackageId() {
        return pkgId;
    }

    /**
     * Sets the packageId to the given value.
     * @param packageId package id
     */
    public void setPackageId(Long packageId) {
        this.pkgId = packageId;
    }

    /**
     * Returns the value of packageClass
     * @return String packageClass
     */
    public String getPackageClass() {
        return pkgClass;
    }

    /**
     * Sets the packageClass to the given value.
     * @param packageClass package class
     */
    public void setPackageClass(String packageClass) {
        this.pkgClass = packageClass;
    }

    /**
     * Returns the value of expectedClass
     * @return String expectedClass
     */
    public String getExpectedClass() {
        return expectedPkgClass;
    }

    /**
     * Sets the expectedClass to the given value.
     * @param expectedClass expected package class
     */
    public void setExpectedClass(String expectedClass) {
        this.expectedPkgClass = expectedClass;
    }

}
