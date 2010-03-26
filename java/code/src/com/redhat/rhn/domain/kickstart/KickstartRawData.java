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

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.FileUtils;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.cobbler.Profile;


/**
 * @author paji
 * KickstartRawData
 * @version $Rev$
 */
public class KickstartRawData extends KickstartData {
    
    private String data;

    /**
     * Constructor
     */
    public KickstartRawData() {
        super();
        this.kickstartType = TYPE_RAW;
    }
    
    /**
     * the actual raw data asa string. ....
     * @return the raw data
     */
    public String getData() {
        if (this.data == null) {
            Profile prof = Profile.lookupById(
                    CobblerXMLRPCHelper.getConnection(
                            ConfigDefaults.get().getCobblerAutomatedUser()),
                    this.getCobblerId());
            if (prof == null) {
                return "";
            }
            this.data = FileUtils.
                readStringFromFile(prof.getKickstart());
        }
        return this.data;
    }
    
    /**
     * set the raw data info.
     * @param dataIn raw data
     */
    public void setData(String dataIn) {
        this.data = dataIn;
    }
    
    /** {@inheritDoc} */
    @Override
    public boolean isRawData() {
        return true;
    }
    
    /** {@inheritDoc} */
    @Override
    public KickstartData deepCopy(User user, String newLabel) {
        KickstartRawData copied = new KickstartRawData();
        updateCloneDetails(copied, user, newLabel);
        copied.setData(this.getData());
        return copied;
    }
    
    /** {@inheritDoc} */
    @Override
    public String getFileData(String host, 
            KickstartSession session) {
        return getData();
    }    
}
