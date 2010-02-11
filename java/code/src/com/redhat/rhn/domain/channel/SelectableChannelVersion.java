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
package com.redhat.rhn.domain.channel;

import com.redhat.rhn.frontend.struts.Selectable;

import java.util.ArrayList;
import java.util.List;

/**
 * 
 * SelectableChannelVersion
 * @version $Rev$
 */
public class SelectableChannelVersion  implements Selectable {

    private boolean selected;
    private ChannelVersion version;

    /**
     * Constructor
     * @param versionIn the Channel version to wrap
     */
    public SelectableChannelVersion(ChannelVersion versionIn) {
        version = versionIn;
    }

    /**
     * {@inheritDoc}
     */
    public String getSelectionKey() {
        return null;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean isSelectable() {
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public boolean isSelected() {
        return selected;
    }

    /**
     * {@inheritDoc}
     */
    public void setSelected(boolean selectedIn) {
        selected = selectedIn;
        
    }
    
    /**
     * @return Returns the name.
     */
    public String getName() {
        return version.getName();
    }
    
    /**
     * @param name The name to set.
     */
    public void setName(String name) {
        version.setName(name);
    }
    
    
    /**
     * @return Returns the version.
     */
    public String getVersion() {
        return version.getVersion();
    }

    
    /**
     * @param versionIn The version to set.
     */
    public void setVersion(String versionIn) {
        version.setVersion(versionIn);
    }
    
    /**
     * Provides a list of the current Channel Versions
     * @return List of SelectableChannelVersion objects
     */
    public static List<SelectableChannelVersion> getCurrentChannelVersionList() {
        List currentList = new ArrayList<ChannelVersion>();
        currentList.add(new SelectableChannelVersion(ChannelVersion.RHEL5));
        currentList.add(new SelectableChannelVersion(ChannelVersion.RHEL4));
        currentList.add(new SelectableChannelVersion(ChannelVersion.RHEL3));
        currentList.add(new SelectableChannelVersion(ChannelVersion.RHEL21));        
        return currentList;
    }
    
    
}
