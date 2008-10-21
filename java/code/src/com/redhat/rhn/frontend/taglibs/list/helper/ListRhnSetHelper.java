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
package com.redhat.rhn.frontend.taglibs.list.helper;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * @author paji
 * @version $Rev$
 */
public class ListRhnSetHelper extends ListSetHelper {
    private RhnSet set;
    private RhnListSetHelper helper;
    private RhnSetDecl decl;
    /**
     * Constructor
     * @param inp list submittable.
     */
    public ListRhnSetHelper(Listable inp, HttpServletRequest request, RhnSetDecl declIn) {
        super(inp, request);
        decl = declIn;
        helper = new RhnListSetHelper(request);
        RequestContext context = new RequestContext(request);
        set = decl.get(context.getLoggedInUser());
    }

    @Override
    protected void clear() {
        set.clear();
        RhnSetManager.store(set);
    }

    @Override
    protected void execute(List dataSet) {
        helper.execute(set,getListName(), dataSet);
    }

    @Override
    protected String getDecl() {
        return decl.getLabel();
    }

    @Override
    protected Map getSelections() {
        return helper.getSelections();
    }

    @Override
    protected int size() {
        return set.size();
    }

    @Override
    protected void syncSelections(List dataSet) {
        helper.syncSelections(set, dataSet);
        
    }

    @Override
    protected void update() {
        helper.updateSet(set, getListName());
    }
    
    /**
     * 
     * @return returns the rhnset associated to set
     */
    public RhnSet getSet() {
        return set;
    }
}
