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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.channel.Channel;

import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.ArrayList;
import java.util.List;

/**
 * PackageMetadata represents some information about a Package
 * between two systems or between a system and a profile. This is
 * similar to the hash, array, map or whatever it is on the perl
 * side.
 * @version $Rev$
 */
public class PackageMetadata extends BaseDto implements Comparable {
    public static final int KEY_NO_DIFF = 0;
    public static final int KEY_THIS_ONLY = 1;
    public static final int KEY_THIS_NEWER = 2;
    public static final int KEY_OTHER_ONLY = 3;
    public static final int KEY_OTHER_NEWER = 4;
    
    public static final int ACTION_NONE = -1;
    public static final int ACTION_INSTALL = 0;
    public static final int ACTION_REMOVE = 1;
    public static final int ACTION_UPGRADE = 2;
    public static final int ACTION_DOWNGRADE = 3;

    private PackageListItem system;
    private PackageListItem other; // could be another system or a profile
    private int comparison;
    private String compareParam;
    private int actionStatus;
    private List channels;
    
    /**
     * Constructs a PackageMetadata
     * @param sys PackageListItem for the current system
     * @param victim PackageListItem for the profile or other system
     */
    public PackageMetadata(PackageListItem sys, PackageListItem victim) {
        system = sys;
        other = victim;
        comparison = KEY_NO_DIFF;
        compareParam = null;
        actionStatus = ACTION_NONE;
        channels = new ArrayList();
    }
    
    /**
     * Default ctor
     */
    public PackageMetadata() {
        this(new PackageListItem(), new PackageListItem());
    }
    
    /**
     * Return the actionstatus as an int.
     * @return the actionstatus as an int.
     */
    public int getActionStatusAsInt() {
        return actionStatus;
    }
    
    /**
     * Return the localized action status string.
     * @return the localized action status string.
     */
    public String getActionStatus() {
        LocalizationService ls = LocalizationService.getInstance();

        switch(actionStatus) {
            case ACTION_INSTALL:
                return ls.getMessage("message.install");
            case ACTION_REMOVE:
                return ls.getMessage("message.actionremove");
            case ACTION_DOWNGRADE:
                return ls.getMessage("message.actiondowngrade", other.getEvr());
            case ACTION_UPGRADE:
                return ls.getMessage("message.actionupgrade", other.getEvr());
            default:
                return "";
        }
    }
    
    /**
     * Returns the comparison key.
     * @return the comparison key.
     */
    public int getComparisonAsInt() {
        return comparison;
    }
    /**
     * @return Returns the comparison.
     */
    public String getComparison() {
        LocalizationService ls = LocalizationService.getInstance();

        switch(comparison) {
            case KEY_THIS_ONLY:
                return ls.getMessage("message.thissystemonly");
            case KEY_THIS_NEWER:
                return ls.getMessage("message.thissystemnewer");
            case KEY_OTHER_ONLY:
                if (compareParam != null) {
                    return ls.getMessage("message.otheronly", compareParam);
                }
                return ls.getMessage("message.profileonly");
            case KEY_OTHER_NEWER:
                if (compareParam != null) {
                    return ls.getMessage("message.othernewer", compareParam);
                }
                return ls.getMessage("message.profilenewer");
            default:
                return "";
        }
    }
    
    /**
     * Sets the comparison to given value.
     * @param comparisonIn The comparison to set.
     */
    public void setComparison(int comparisonIn) {
        comparison = comparisonIn;
    }

    /**
     * @param aCompareParam The parameter to the comparison string.
     */
    public void setCompareParam(String aCompareParam) {
        compareParam = aCompareParam;
    }
    
    /**
     * Returns the System's PackageListItem
     * @return the System's PackageListItem
     */
    public PackageListItem getSystem() {
        return system;
    }
    
    /**
     * Returns the other system or profile's PackageListItem
     * @return  the other system or profile's PackageListItem
     */
    public PackageListItem getOther() {
        return other;
    }
    
    /**
     *  {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this)
            .append("name", getName())
            .append("systemEvr", system != null ? system.getEvr() : "")
            .append("otherEvr", other != null ? other.getEvr() : "")
            .append("comparison", comparison)
            .toString();
    }
    
    /**
     * Returns the name of the Package, if both the system and
     * other PackageListItem are null, returns the empty string.
     * @return the name of the Package, if both the system and
     * other PackageListItem are null, returns the empty string.
     */
    public String getName() {
        if (system != null) {
            return system.getName();
        }
        else if (other != null) {
            return other.getName();
        }
        
        return "";
    }
    
    /**
     * Returns the nameid of the Package, if both the system and
     * other PackageListItem are null, returns null.
     * @return the nameid of the Package, if both the system and
     * other PackageListItem are null, returns null.
     */
    public Long getNameId() {
        if (system != null) {
            return system.getNameId();
        }
        else if (other != null) {
            return other.getNameId();
        }
        
        return null;
    }
    
    /**
     * Returns the evrid of the Package, if both the system and
     * other PackageListItem are null, returns null.
     * @return the evrid of the Package, if both the system and
     * other PackageListItem are null, returns null.
     */
    public Long getEvrId() {
        if (system != null) {
            return system.getEvrId();
        }
        else if (other != null) {
            return other.getEvrId();
        }
        
        return null;
    }
    
    /**
     * Returns the archid of the Package, if both the system and
     * other PackageListItem are null, returns null.
     * @return the archid of the Package, if both the system and
     * other PackageListItem are null, returns null.
     */
    public Long getArchId() {
        if (system != null) {
            return system.getArchId();
        }
        else if (other != null) {
            return other.getArchId();
        }

        return null;
    }

    /**
     * Returns the arch of the Package, if both the system and
     * other PackageListItem are null, returns null.
     * @return the arch of the Package, if both the system and
     * other PackageListItem are null, returns null.
     */
    public String getArch() {
        if (system != null) {
            return system.getArch();
        }
        else if (other != null) {
            return other.getArch();
        }

        return null;
    }

    /**
     * Returns the epoch of the Package, if both the system and
     * other PackageListItem are null, returns null.
     * @return the epoch of the Package, if both the system and
     * other PackageListItem are null, returns null.
     */
    public String getEpoch() {
        if (system != null) {
            return system.getEpoch();
        }
        else if (other != null) {
            return other.getEpoch();
        }
        
        return null;
    }
    
    /**
     * Returns the version of the Package, if both the system and
     * other PackageListItem are null, returns null.
     * @return the version of the Package, if both the system and
     * other PackageListItem are null, returns null.
     */
    public String getVersion() {
        if (system != null) {
            return system.getVersion();
        }
        else if (other != null) {
            return other.getVersion();
        }
        
        return null;
    }
    
    /**
     * Returns the release of the Package, if both the system and
     * other PackageListItem are null, returns null.
     * @return the release of the Package, if both the system and
     * other PackageListItem are null, returns null.
     */
    public String getRelease() {
        if (system != null) {
            return system.getRelease();
        }
        else if (other != null) {
            return other.getRelease();
        }
        
        return null;
    }
    
    /**
     * {@inheritDoc}
     */
    public int compareTo(Object o) {
        PackageMetadata pm = (PackageMetadata) o;
        return getName().toLowerCase().compareTo(pm.getName().toLowerCase());
    }

    /**
     * Updates the action status.
     */
    public void updateActionStatus() {
        switch(comparison) {
            case KEY_THIS_ONLY:
                actionStatus = ACTION_REMOVE;
                break;
            case KEY_THIS_NEWER:
                actionStatus = ACTION_DOWNGRADE;
                break;
            case KEY_OTHER_ONLY:
                actionStatus = ACTION_INSTALL;
                break;
            case KEY_OTHER_NEWER:
                actionStatus = ACTION_UPGRADE;
                break;
            default:
                actionStatus = ACTION_NONE;
        }
    }

    /**
     * @return Returns target Nevra to be displayed on webui
     */
    public String getActionTargetNevra() {
        if (comparison == KEY_THIS_ONLY) {
            return system.getNevra();
        }
        else {
            return other.getNevra();
        }
    }

    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return getNameId();
    }
    
    /**
     * Returns the list of Channels which supply this package.
     * @return the list of Channels which supply this package.
     */
    public List getChannels() {
        return channels;
    }
    
    /**
     * Sets the list of Channels which supply this package.
     * @param chanList list of Channels which supply this package.
     */
    public void setChannels(List chanList) {
        channels.addAll(chanList);
    }
    
    /**
     * Add a channel which supplies this package to the list.
     * @param c the Channel which supplies this package.
     */
    public void addChannel(Channel c) {
        channels.add(c);
    }

    /**
     * Returns the IdCombo which is the nameid, evrid and archid seperated by a pipe (|).
     * <code>nameid|evrid[|archid]</code>.  Arch id will only be included if it is
     * available.
     * @return the IdCombo which is the nameid and evrid seperated by a pipe (|).
     */
    public String getIdCombo() {
        StringBuilder result = new StringBuilder();
        result.append(getNameId())
              .append("|")
              .append(getEvrId());

        if (getArchId() != null) {
            result.append("|")
                  .append(getArchId());
        }
        return result.toString();
    }

    /**
     * Returns a unique id (nameId x archId) for HashMap
     * @return a map id
     */
    public String getMapHash() {
        return "" + getNameId() + "|" + getArchId();
    }

    /**
     * Get the EVR of the System's rev of the RPM
     * @return String EVR for the system
     */
    public String getSystemEvr() {
        if (this.system != null) {
            return this.system.getEvr();
        }
        return null;
    }
    
    /**
     * Get the EVR of the Other's package
     * @return String EVR from Other system/profile
     */
    public String getOtherEvr() {
        if (this.other != null) {
            return this.other.getEvr();
        }
        return null;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String getSelectionKey() {
        return getIdCombo(); 
    }
}
