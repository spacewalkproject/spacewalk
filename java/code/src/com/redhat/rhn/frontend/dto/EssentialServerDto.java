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
 * EssentialServerDto
 * @version $Rev$
 */
public class EssentialServerDto extends BaseDto {

    private Long id;
    private String name;
    
    /**
     * 
     * @return Server name.
     */
    public String getName() {
        return name;
    }

    /**
     * 
     * @param nameIn Set the server name.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * 
     * @param idIn Id to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Long getId() {
        return id;
    }

}
