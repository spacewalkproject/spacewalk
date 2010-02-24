/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.dto.kickstart;

import com.redhat.rhn.domain.kickstart.KickstartableTree;


/**
 * KickstartableTreeDetail
 * @version $Rev$
 */
public class KickstartableTreeDetail extends KickstartableTree {

    /**
     * @param tree kickstart tree as origin
     */
    public KickstartableTreeDetail(KickstartableTree tree) {
        this.setBasePath(tree.getBasePath());
        this.setChannel(tree.getChannel());
        this.setId(tree.getId());
        this.setInstallType(tree.getInstallType());
        this.setLabel(tree.getLabel());
        this.setLastModified(tree.getLastModified());
        this.setCobblerId(tree.getCobblerId());
        this.setCobblerXenId(tree.getCobblerXenId());
        this.setOrg(tree.getOrg());
        this.setTreeType(tree.getTreeType());
    }

}
