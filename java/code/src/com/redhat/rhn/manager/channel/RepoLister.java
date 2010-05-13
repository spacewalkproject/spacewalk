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
package com.redhat.rhn.manager.channel;

import java.util.LinkedList;
import java.util.List;

import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.BaseManager;

/**
 * CobblerSnippetLister
 * @version $Rev$
 */
public class RepoLister extends BaseManager {

    private static final RepoLister INSTANCE = new RepoLister();
    /**
     * Default constructor
     */
    public RepoLister() {

    }

    /**
     * Get the instance of the RepoLister
     * @return CobblerSnippetLister instance
     */
    public static RepoLister getInstance() {
        return INSTANCE;
    }


    public List<ContentSource> list(User user) {
        List <ContentSource> repos = new LinkedList<ContentSource>();
        return repos;
    }
}
