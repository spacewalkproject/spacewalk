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

import org.apache.commons.collections.CollectionUtils;

import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

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
     * Contructor
     * @param inp the listable
     * @param request the servlet request
     * @param declIn declaration
     * @param params the parameter map for this request
     */
    public ListRhnSetHelper(Listable inp, HttpServletRequest request,
                                        RhnSetDecl declIn, Map params) {
        super(inp, request, params);
        decl = declIn;
        helper = new RhnListSetHelper(request);
        RequestContext context = new RequestContext(request);
        set = decl.get(context.getLoggedInUser());
    }

    /**
     * Contructor
     * @param inp the listable
     * @param request the servlet request
     * @param declIn declaration
     */
    public ListRhnSetHelper(Listable inp, HttpServletRequest request,
                                        RhnSetDecl declIn) {
        this(inp, request, declIn, Collections.EMPTY_MAP);
    }    
    @Override
    protected void clear() {
        set.clear();
        RhnSetManager.store(set);
    }

    /**
     * clears the set
     * */
    public void  obliterate() {
        clear();
    }
    @Override
    protected void execute(List dataSet) {
        helper.execute(set, getListName(), dataSet);
    }

    @Override
    protected String getDecl() {
        Map params = getParamMap();
        return decl.createCustom(params.entrySet().toArray()).getLabel();
    }

    @Override
    protected Map getSelections() {
        Map <Long, Long> selections = new HashMap<Long, Long>();
        for (Long id : set.getElementValues()) {
            selections.put(id, id);
        }
        return selections;
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

    @Override
    protected void add(Set c) {
        for (Object elem :  c) {
            set.addElement((Long)elem);
        }
        RhnSetManager.store(set);
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public Collection getAddedKeys() {
        return CollectionUtils.subtract(getPreSelected(), set.getElementValues());
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public Collection getRemovedKeys() {
        return CollectionUtils.subtract(set.getElementValues(), getPreSelected());
    }
}
