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
package com.redhat.rhn.domain.kickstart;

import com.redhat.rhn.common.hibernate.HibernateFactory;

import java.util.Date;

/**
 * KickstartScript - Class representation of the table rhnKickstartScript.
 * @version $Rev: 1 $
 */
public class KickstartScript implements Comparable<KickstartScript> {

    public static final String TYPE_PRE = "pre";
    public static final String TYPE_POST = "post";

    private Long id;
    private Long position;
    private String scriptType;
    private String chroot;
    private String interpreter;
    private byte[] data;
    private Date created;
    private Date modified;
    private Boolean raw = true;

    private KickstartData ksdata;

    /** Setup the default value for
     * chroot and other fields.
     */
    public KickstartScript() {
        this.chroot = "Y";
        this.scriptType = TYPE_PRE;
    }

    /**
     * Getter for id
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for position
     * @return Long to get
    */
    public Long getPosition() {
        return this.position;
    }

    /**
     * Setter for position
     * @param positionIn to set
    */
    public void setPosition(Long positionIn) {
        this.position = positionIn;
    }

    /**
     * Getter for scriptType
     * @return String to get
    */
    public String getScriptType() {
        return this.scriptType;
    }

    /**
     * Setter for scriptType
     * @param scriptTypeIn to set
    */
    public void setScriptType(String scriptTypeIn) {
        if (!(scriptTypeIn.equals(TYPE_PRE) || scriptTypeIn.equals(TYPE_POST))) {
            throw new IllegalArgumentException("Invalid script type");
        }
        this.scriptType = scriptTypeIn;
    }

    /**
     * Getter for chroot
     * @return String to get
    */
    public String getChroot() {
        return this.chroot;
    }

    /**
     * Setter for chroot
     * @param chrootIn to set
    */
    public void setChroot(String chrootIn) {
        this.chroot = chrootIn;
    }

    /**
     * Getter for interpreter
     * @return String to get
    */
    public String getInterpreter() {
        return this.interpreter;
    }

    /**
     * Setter for interpreter
     * @param interpreterIn to set
    */
    public void setInterpreter(String interpreterIn) {
        this.interpreter = interpreterIn;
    }

    /**
     * Get the String version of the pre contents
     * @return String version of the pre contents
     */
    public String getDataContents() {
        return HibernateFactory.getByteArrayContents(this.data);
    }

    /**
     * Getter for created
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /**
     * Setter for created
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * Getter for modified
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /**
     * Setter for modified
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }


    /**
     * @return the ksdata
     */
    public KickstartData getKsdata() {
        return ksdata;
    }


    /**
     * @param ksdataIn The ksdata to set.
     */
    public void setKsdata(KickstartData ksdataIn) {
        this.ksdata = ksdataIn;
    }


    /**
     * @return the data
     */
    public byte[] getData() {
        return data;
    }


    /**
     * @param dataIn The data to set.
     */
    public void setData(byte[] dataIn) {
        this.data = dataIn;
    }

    /**
     * Clone/copy this KickstartScript into a new instance.
     *
     * @param ksDataIn that will own this new KickstartScript
     * @return KickstartScript object that is a copy
     */
    public KickstartScript deepCopy(KickstartData ksDataIn) {
        KickstartScript cloned = new KickstartScript();
        cloned.setChroot(this.getChroot());
        cloned.setData(this.getData());
        cloned.setInterpreter(this.getInterpreter());
        cloned.setKsdata(ksDataIn);
        cloned.setPosition(this.getPosition());
        cloned.setScriptType(this.getScriptType());
        cloned.setRaw(this.getRaw());
        return cloned;
    }

    /**
     *
     * @param scriptIn KickstartScript to compare order to
     * @return the position order of this script
     */
    public int compareTo(KickstartScript scriptIn) {
        final int before = -1;
        final int after = 1;

        if (scriptIn.getPosition() < this.getPosition()) {
            return after;
        }
        else {
            return before;
        }
    }


    /**
     * @return Returns the raw.
     */
    public Boolean getRaw() {
        return raw;
    }


    /**
     * @param rawIn The raw to set.
     */
    public void setRaw(Boolean rawIn) {
        this.raw = rawIn;
    }

}
