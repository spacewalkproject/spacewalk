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
package com.redhat.rhn.manager.channel.repo;

import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.user.User;

/**
 * EditRepoCommand - Command to edit a repo
 * @version $Rev: 119601 $
 */
public class EditRepoCommand extends BaseRepoCommand {

    /**
     *
     * @param currentUser logged in user
     * @param repoId id of content source object
     */
    public EditRepoCommand(User currentUser, Long repoId) {
        this.setOrg(currentUser.getOrg());
        this.repo = ChannelFactory.lookupContentSource(repoId, currentUser.getOrg());
    }
}
