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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.BaseDomainHelper;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * Dmi
 * @version $Rev$
 */
public class Dmi extends BaseDomainHelper {

    private Long id;
    private Server server;
    private String vendor;
    private String system;
    private String product;
    private Bios bios;
    private String asset;
    private String board;
    
    /**
     * 
     */
    public Dmi() {
        super();
    }
    
    /**
     * @return Returns the asset.
     */
    public String getAsset() {
        return asset;
    }
    
    /**
     * @param assetIn The asset to set.
     */
    public void setAsset(String assetIn) {
        asset = assetIn;
    }
    
    /**
     * @return Returns the bios.
     */
    public Bios getBios() {
        return bios;
    }
    
    /**
     * Sets the bios.
     * @param biosVendor BIOS vendor
     * @param version BIOS version
     * @param release BIOS release
     */
    public void setBios(String biosVendor, String version, String release) {
        bios = new Bios(biosVendor, version, release);
    }
    
    /**
     * @param biosIn The bios to set.
     */
    private void setBios(Bios biosIn) {
        bios = biosIn;
    }
    
    /**
     * @return Returns the board.
     */
    public String getBoard() {
        return board;
    }
    
    /**
     * @param boardIn The board to set.
     */
    public void setBoard(String boardIn) {
        board = boardIn;
    }
    
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
        id = idIn;
    }
    
    /**
     * @return Returns the product.
     */
    public String getProduct() {
        return product;
    }
    
    /**
     * @param productIn The product to set.
     */
    public void setProduct(String productIn) {
        product = productIn;
    }
    
    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }
    
    /**
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        server = serverIn;
    }
    
    /**
     * @return Returns the system.
     */
    public String getSystem() {
        return system;
    }
    
    /**
     * @param systemIn The system to set.
     */
    public void setSystem(String systemIn) {
        system = systemIn;
    }
    
    /**
     * @return Returns the vendor.
     */
    public String getVendor() {
        return vendor;
    }
    
    /**
     * @param vendorIn The vendor to set.
     */
    public void setVendor(String vendorIn) {
        vendor = vendorIn;
    }
    
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof Dmi)) {
            return false;
        }
        Dmi castOther = (Dmi) other;
        return new EqualsBuilder().append(id, castOther.id)
                                  .append(vendor, castOther.vendor)
                                  .append(system, castOther.system)
                                  .append(product, castOther.product)
                                  .append(asset, castOther.asset)
                                  .append(board, castOther.board)
                                  .append(bios, castOther.bios)
                                  .append(server, castOther.server)
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(id)
                                    .append(vendor)
                                    .append(system)
                                    .append(product)
                                    .append(asset)
                                    .append(board)
                                    .append(bios)
                                    .append(server)
                                    .toHashCode();
    }
    
    /**
     * Bios class
     * @version $Rev$
     */
    public static class Bios {
        
        private String vendor;
        private String version;
        private String release;
        
        /**
         * default constructor
         */
        public Bios() {
            this("", "", "");
        }
        
        /**
         * Constructs a BIOS object with vendor, version, and release.
         * @param vendorIn BIOS vendor
         * @param versionIn BIOS version
         * @param releaseIn BIOS release
         */
        public Bios(String vendorIn, String versionIn, String releaseIn) {
            vendor = vendorIn;
            version = versionIn;
            release = releaseIn;
        }
        
        /**
         * @return Returns the release.
         */
        public String getRelease() {
            return release;
        }
        
        /**
         * @param releaseIn The release to set.
         */
        public void setRelease(String releaseIn) {
            release = releaseIn;
        }
        
        /**
         * @return Returns the vendor.
         */
        public String getVendor() {
            return vendor;
        }
        
        /**
         * @param vendorIn The vendor to set.
         */
        public void setVendor(String vendorIn) {
            vendor = vendorIn;
        }
        
        /**
         * @return Returns the version.
         */
        public String getVersion() {
            return version;
        }
        
        /**
         * @param versionIn The version to set.
         */
        public void setVersion(String versionIn) {
            version = versionIn;
        }
        
        /**
         * {@inheritDoc}
         */
        public boolean equals(final Object other) {
            if (!(other instanceof Bios)) {
                return false;
            }
            Bios castOther = (Bios) other;
            return new EqualsBuilder().append(vendor, castOther.vendor)
                                      .append(version, castOther.version)
                                      .append(release, castOther.release)
                                      .isEquals();
        }
        
        /**
         * {@inheritDoc}
         */
        public int hashCode() {
            return new HashCodeBuilder().append(vendor)
                                        .append(version)
                                        .append(release)
                                        .toHashCode();
        }
    }
}
