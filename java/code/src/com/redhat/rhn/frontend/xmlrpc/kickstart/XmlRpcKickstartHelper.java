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

package com.redhat.rhn.frontend.xmlrpc.kickstart;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;


/**
 * @author paji
 * @version $Rev $
 */
public class XmlRpcKickstartHelper {
    private static final XmlRpcKickstartHelper HELPER =
                                            new XmlRpcKickstartHelper();
    /**
     * private constructor to make this a singleton
     */
    private XmlRpcKickstartHelper() {
    }

    /**
     * @return Returns the running instance of this helper class
     */
    public static XmlRpcKickstartHelper getInstance() {
        return HELPER;
    }

    /**
     * Returns the kickstart data associated to the given label and org
     * @param label the label of the Ks profile
     * @param org the org of the ks profile
     * @return the kickstart data
     */
    public KickstartData lookupKsData(String label, Org org) {
        KickstartData data = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                label, org.getId());
        if (data == null) {
            throw new InvalidKickstartLabelException(label);
        }
        return data;
    }

    /**
     * Returns the kickstart data associated to the given label and user's org
     * @param label the label of the Ks profile
     * @param user the user.
     * @return the kickstart data
     */
    public KickstartData lookupKsData(String label, User user) {
        return lookupKsData(label, user.getOrg());
    }
}
