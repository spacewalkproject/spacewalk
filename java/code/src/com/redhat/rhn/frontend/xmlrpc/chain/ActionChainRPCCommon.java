/**
 * Copyright (c) 2014 SUSE
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

package com.redhat.rhn.frontend.xmlrpc.chain;

import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.InvalidPackageException;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.frontend.xmlrpc.NoSuchActionChainException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections.Transformer;

/**
 * Common mix-in for package resolving.
 */
public class ActionChainRPCCommon {
    protected static final String[] COMBO_KEYS = new String[]{
        "evr_id", "arch_id", "name_id"
    };

    /**
     * Transformer from Long to Integer for the XML-RPC compatibility.
     */
    public static class IntegerToLongTransformer implements Transformer {
        // TODO: add javadoc
        @Override
        public Long transform(Object value) {
            return value == null ? null : ((Integer) value).longValue();
        }
    }

    /**
     * Resolve packages from IDs.
     *
     * @param userPackages User packages
     * @param user User of the system
     * @return selectedPackages Map of the selected packages
     */
    public List<Map<String, Long>> resolvePackages(List<Integer> userPackages, User user) {
        List<Map<String, Long>> selected = new ArrayList<Map<String, Long>>();
        for (Integer pkgId : userPackages) {
            Map<String, Long> pkgMap = new HashMap<String, Long>();

            Package pkg = PackageManager.lookupByIdAndUser(
                    new Long(pkgId.longValue()), user);
            if (pkg == null) {
                throw new InvalidPackageException(pkgId.toString());
            }

            pkgMap.put("name_id", pkg.getPackageName().getId());
            pkgMap.put("evr_id", pkg.getPackageEvr().getId());
            pkgMap.put("arch_id", pkg.getPackageArch().getId());

            selected.add(pkgMap);
        }

        return selected;
    }

    /**
     * Find an Action Chain by label.
     * @param actionChainLabel Chaom label
     * @return Action Chain or throws NoSuchActionChainException.
     */
    public ActionChain getActionChainByLabel(String actionChainLabel) {
        ActionChain chain = ActionChainFactory.getActionChain(actionChainLabel);
        if (chain == null) {
            throw new NoSuchActionChainException(actionChainLabel);
        }

        return chain;
    }

    /**
     * Find a server by Id and ensure it is available for the given user.
     * @param serverId Server ID
     * @param user User
     * @return Server object.
     */
    public Server getServerById(Integer serverId, User user) {
        return SystemManager.lookupByIdAndUser((long) serverId, user);
    }
}
