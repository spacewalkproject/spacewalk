/**
 * Copyright (c) 2008 Red Hat, Inc.
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

package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.user.User;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;


/**
 * @author paji
 * @version $Rev$
 */
public class CobblerDistroSyncCommand extends CobblerCommand {
    /**
     * Constructor to create a 
     * DistorSyncCommand
     * @param u user object needed to do things like org check..
     */
    public CobblerDistroSyncCommand(User u) {
        super(u);
    }
    
    protected Set<String> getDistroNames() {
        Set <String> distroNames = new HashSet<String>();
        List<Map> distros = (List<Map>)invokeXMLRPC("get_distros", xmlRpcToken);
        for (Map distro : distros) {
            distroNames.add((String)distro.get("name"));
        }
        return distroNames;
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {
        List <KickstartableTree> trees = KickstartFactory.
                                    lookupKickstartTreesByOrg(user.getOrg());
        Set<String> distros = getDistroNames();
        for (KickstartableTree tree : trees) {
            if (!distros.contains(getCobblerDistroName(tree))) {
                createDistro(tree);
            }
        }
        
        return null;
    }
    
    private void createDistro(KickstartableTree tree) {
        CobblerDistroCreateCommand creator = new CobblerDistroCreateCommand(tree, user);
        creator.store();
    }

}
