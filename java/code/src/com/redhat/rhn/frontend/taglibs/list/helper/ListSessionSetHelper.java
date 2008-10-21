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

import com.redhat.rhn.frontend.struts.SessionSetHelper;

import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;


/**
 * @author paji
 * ListSessionSetHelper.java
 * @version $Rev$
 */
public class ListSessionSetHelper extends ListSetHelper {
    private Set set;
    private SessionSetHelper helper;
    private String decl;
    /**
     * constructor
     * @param inp listable
     * @param req the servlet request
     * @param declIn the session declaration
     */
    public ListSessionSetHelper(Listable inp, HttpServletRequest req, String declIn) {
        super(inp, req);
        helper = new SessionSetHelper(req);
        set = SessionSetHelper.lookupAndBind(req, declIn);
        decl = declIn;
    }
    
    @Override
    protected void clear() {
        set.clear();
        
    }

    @Override
    protected void execute(List dataSet) {
        helper.execute(set, getListName(), dataSet);
        
    }

    @Override
    protected String getDecl() {
        return decl;
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
     * @return returns the set assoctiated to this class   
     */
    public Set <String> getSet() {
        return set;
    }
}
