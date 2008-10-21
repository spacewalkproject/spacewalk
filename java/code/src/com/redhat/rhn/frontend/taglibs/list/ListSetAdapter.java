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

package com.redhat.rhn.frontend.taglibs.list;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;


/**
 * @author paji
 * @version $Rev$
 */
interface ListSetAdapter {
    /**
     * clear the set
     */
    void clear();
    
    /**
     * Obliterate the set
     */
    void obliterate();

    /**
     * Update the set getting data 
     * from List, basically perform
     * the RhnListSetHelper.updateSet 
     */
    void update();
    
    /**
     * Perform the execute step of the helpers
     * basicall handles the selectall updateset etc..
     * @param dataSet the input data set
     */
    void execute(List dataSet);

    /**
     * sync the selections of rhn or session set to dataset.
     * @param dataSet the result set.
     */
    void syncSelections(List dataSet);
    
    /**
     * return the size of the set
     * @return set size
     */
    int size();
    
    /**
     * returns the selections map.
     * @return selection map
     */
    Map getSelections();
}

/**
 * @author paji
 * @version $Rev$
 */
class SessionSetAdapter implements ListSetAdapter {
    private Set set;
    private SessionSetHelper helper;
    private RequestContext context;
    private ListSubmitable listable;
    
    
    SessionSetAdapter(HttpServletRequest req, ListSubmitable ls) {
        context = new RequestContext(req);
        listable = ls;
        helper = new SessionSetHelper(req);
        set = SessionSetHelper.lookupAndBind(req,
                                        listable.getDecl(context));
    }
    public void clear() {
        set.clear();
    }

    public void execute(List dataSet) {
        helper.execute(set, 
                listable.getListName(),
                dataSet);
    }

    public int size() {
        return set.size();
    }

    public void obliterate() {
        SessionSetHelper.obliterate(context.getRequest(),
                                        listable.getDecl(context));
    }

    public void syncSelections(List dataSet) {
        helper.syncSelections(set, dataSet);
    }
    
    public Map getSelections() {
        Map selections = new HashMap<Long, Long>();
        for (Object id : set) {
            Long item = Long.valueOf(id.toString());
            selections.put(item, item);
        }
        return selections;
    }

    public void update() {
       helper.updateSet(set, listable.getListName());
    }
    
}

/**
 * @author paji
 * @version $Rev$
 */
class RhnSetAdapter implements ListSetAdapter {
    private RhnSet set;
    private RhnListSetHelper helper;
    private RequestContext context;
    private ListSubmitable listable;
    
    
    RhnSetAdapter(HttpServletRequest req, ListSubmitable ls) {
        context = new RequestContext(req);
        listable = ls;
        helper = new RhnListSetHelper(req);
        RhnSetDecl decl = RhnSetDecl.find(listable.getDecl(context));
        User user =  context.getLoggedInUser();
        set = decl.get(user);
    }
    
    public void clear() {
        set.clear();
        RhnSetManager.store(set);
    }

    public void execute(List dataSet) {
        helper.execute(set, 
                listable.getListName(),
                dataSet);
    }

    public int size() {
        return set.size();
    }

    public void obliterate() {
        clear();
    }

    public void syncSelections(List dataSet) {
        helper.syncSelections(set, dataSet);
    }
    
    public Map getSelections() {
        Map <Long, Long> selections = new HashMap<Long, Long>();
        for (Long id : set.getElementValues()) {
            selections.put(id, id);
        }
        return selections;
    }
    
    public void update() {
       helper.updateSet(set, listable.getListName());
    }
        
}
