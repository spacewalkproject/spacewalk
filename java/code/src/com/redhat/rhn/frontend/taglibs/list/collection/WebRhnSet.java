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

package com.redhat.rhn.frontend.taglibs.list.collection;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;


/**
 * @author paji
 * ListSessionSetHelper.java
 * @version $Rev$
 */
public abstract class WebRhnSet extends SelectableWebList {
    private RhnSet set;
    private RhnListSetHelper helper;
    
    /**
     * Constructor
     * @param request Servlet request
     */
    public WebRhnSet(HttpServletRequest request) {
        super(request);
    }

    @Override
    protected void setup() {
        HttpServletRequest request = getContext().getRequest();
        helper = new RhnListSetHelper(request);
        RhnSetDecl decl = RhnSetDecl.find(getDecl());
        User user =  getContext().getLoggedInUser();
        set = decl.get(user);
        super.setup();
    }    
    
    protected void clear() {
        set.clear();
        RhnSetManager.store(set);
    }

    protected void execute(List dataSet) {
        helper.execute(set, getListName(),
                dataSet);
    }

    protected int size() {
        return set.size();
    }

    protected void obliterate() {
        clear();
    }

    protected void syncSelections(List dataSet) {
        helper.syncSelections(set, dataSet);
    }
    
    protected Map getSelections() {
        Map <Long, Long> selections = new HashMap<Long, Long>();
        for (Long id : set.getElementValues()) {
            selections.put(id, id);
        }
        return selections;
    }

    protected void update() {
       helper.updateSet(set, getListName());
    }

    /**
     * @return returns the rhnset associated 
     *          to set
     */
    public RhnSet getSet() {
        return set;
    }
}
