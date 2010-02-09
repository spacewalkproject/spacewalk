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

/**
 * ProfilePackageOverviewDto class represents a package associated with a stored profile.
 *
 * @version $Rev$
 */
public class ProfilePackageOverviewDto {

    private String nvre;
    private String arch;

    /**
     * @return Returns the nvre.
     */
    public String getNvre() {
        return nvre;
    }
    /**
     * @param nvreIn The nvre to set.
     */
    public void setNvre(String nvreIn) {
        nvre = nvreIn;
    }

    /**
     * @return Returns the arch.
     */
    public String getArch() {
        return arch;
    }
    /**
     * @param archIn The arch to set.
     */
    public void setArch(String archIn) {
        this.arch = archIn;
    }
}
