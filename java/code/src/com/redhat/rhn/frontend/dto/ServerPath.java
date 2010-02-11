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
 * ServerPath
 * @version $Rev: 76626 $
 */
public class ServerPath {

    private Long id;
    private String name; 
    private Long position;
    private String hostname;
    
    /**
     * 
     * @return host name for proxy
     */
    public String getHostname() {
        return hostname;
    }
    
    /**
     * 
     * @param hostnameIn host name to set
     */
    public void setHostname(String hostnameIn) {
        this.hostname = hostnameIn;
    }
    
    /**
     * 
     * @return id of proxy
     */
    public Long getId() {
        return id;
    }
    
    /**
     * 
     * @param idIn id of proxy to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    
    /**
     * 
     * @return name of proxy
     */
    public String getName() {
        return name;
    }
    
    /**
     * 
     * @param nameIn name of proxy to set
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }
    
    /**
     * 
     * @return position in proxy chain
     */
    public Long getPosition() {
        return position;
    }
    
    /**
     * 
     * @param positionIn position to set in proxy chain
     */
    public void setPosition(Long positionIn) {
        this.position = positionIn;
    }
}
