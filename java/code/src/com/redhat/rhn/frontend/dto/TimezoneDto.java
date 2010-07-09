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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.common.db.datasource.RowCallback;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 *
 * @version $Rev$
 */
public class TimezoneDto extends BaseDto implements RowCallback {

    private Long id;
    private String name;
    private String label;

    /**
     * Returns the Timezone's id.
     * @return the Timezone's id.
     */
    public Long getId() {
        return id;
    }

    /**
     * Sets the Timezone's id.
     * @param idIn Timezone id.
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * Returns the Timezone's name.
     * @return the Timezone's name.
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the Timezone's name.
     * @param nameIn Timezone name.
     */
    public void setName(String nameIn) {
        name = nameIn;
    }

    /**
     * Returns the Timezone's label.
     * @return the Timezone's label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * Sets the Timezone's label.
     * @param labelIn Timezone label.
     */
    public void setLabel(String labelIn) {
        label = labelIn;
    }

    /**
     * {@inheritDoc}
     */
    public void callback(ResultSet rs) throws SQLException {
    }

    /**
     *
     * {@inheritDoc}
     */
    public List<String> getCallBackColumns() {
        return new ArrayList<String>();
    }
}
