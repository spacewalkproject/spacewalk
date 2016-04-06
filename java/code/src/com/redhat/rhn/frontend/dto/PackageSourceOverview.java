/**
 * Copyright (c) 2016 Red Hat, Inc.
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

/**
 * PackageSourceOverview
 * @version $Rev$
 */
public class PackageSourceOverview extends BaseDto {

    private Long id;
    private String nvrea;
    private String path;

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    /**
     * @return Returns the nvrea.
     */
    public String getNvrea() {
        return nvrea;
    }
    /**
     * @param nvreaIn The name to set.
     */
    public void setNvrea(String nvreaIn) {
        this.nvrea = nvreaIn;
    }
    /**
     * @return Returns the path.
     */
    public String getPath() {
        return path;
    }
    /**
     * @param pathIn The path to set.
     */
    public void setPath(String pathIn) {
        this.path = pathIn;
    }

}
