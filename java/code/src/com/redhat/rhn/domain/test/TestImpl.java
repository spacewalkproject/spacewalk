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

package com.redhat.rhn.domain.test;

import java.util.Date;

/**
 * $Rev$
 */
public class TestImpl implements TestInterface {

    private String testColumn;
    private String foobar;
    private String hidden;
    private Long id;
    private Integer pin;
    private String noColumnField;
    private Date created;

    public void setId(Long i) {
        id = i;
    }

    public Long getId() {
        return id;
    }

    public void setPin(Integer i) {
        pin = i;
    }

    public Integer getPin() {
        return pin;
    }

    public void setFoobar(String foo) {
        foobar = foo;
    }

    public String getFoobar() {
        return foobar;
    }

    public void setHidden(String hideIn) {
        // Thread.dumpStack();
        hidden = hideIn;
    }

    public String getHidden() {
        return hidden;
    }

    public void setTestColumn(String foo) {
        testColumn = foo;
    }

    public String getTestColumn() {
        return testColumn;
    }

    public void setNoColumnField(String foo) {
        this.noColumnField = foo;
    }

    public String getNoColumnField() {
        return this.noColumnField;
    }

    public void setCreated(Date d) {
        created = d;
    }

    public Date getCreated() {
        return created;
    }
}
