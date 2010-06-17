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

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ContentSourceDto;
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
    
    /**
     * 
     * @param orgIn org to check
     * @return list of contet source dto's
     */
    public DataResult<ContentSourceDto> sourcesInOrg(Org orgIn) {

        SelectMode m = ModeFactory.getMode("Channel_queries", "contentsrc_for_org");
        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        Map elabParams = new HashMap();
        DataResult<ContentSourceDto> returnDataResult = makeDataResult(params,
                                                            elabParams, null, m);
        return returnDataResult;
    }

    /**
     *     
     * @param user that is logged in
     * @return list of content source dto's for users org
     */
    public List<ContentSourceDto> list(User user) {
        List <ContentSourceDto> repos = new LinkedList<ContentSourceDto>();
        repos.addAll(sourcesInOrg(user.getOrg()));
        return repos;
    }
}
