/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.SessionSetHelper;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;

import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
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
     * @param params the parameter map for this request
     * @param declPrefix the declaration prefix
     *               needed to make this set declaration unique.
     */
    public ListSessionSetHelper(Listable inp, HttpServletRequest req, 
                                            Map params, String declPrefix) {
        super(inp, req, params);
        setup(declPrefix);
        
    }

    
    /**
     * constructor
     * @param inp listable
     * @param req the servlet request
     * @param params the parameter map for this request
     */
    public ListSessionSetHelper(Listable inp, HttpServletRequest req, Map params) {
        this (inp, req, params, inp.getClass().getName());
    }


    /**
     * constructor
     * @param inp listable
     * @param req the servlet request
     */
    public ListSessionSetHelper(Listable inp, HttpServletRequest req) {
        this(inp, req, Collections.EMPTY_MAP);
    }
    
    @Override
    protected void clear() {
        set.clear();
    }
    
    /**
     * Objliterates the set from the session
     */
    @Override
    public void  destroy() {
        SessionSetHelper.obliterate(getContext().getRequest(), getDecl()); 
    }

    @Override
    protected void execute(List dataSet) {
        helper.execute(set, getListName(), dataSet);
    }
    
    private void setup(String prefix) {
        RequestContext context = getContext();
        helper = new SessionSetHelper(context.getRequest());
        
        if (StringUtils.isBlank(prefix)) {
            prefix = getListable().getClass().getName();
        }
        decl =  prefix;
        
        Map params = getParamMap(); 
        if (!params.isEmpty()) {
            decl = decl + params.hashCode();
        }
        
        set = SessionSetHelper.lookupAndBind(context.getRequest(),
                    decl);

    }

    /** {@inheritDoc} */
    @Override
    public String getDecl() {
        return decl;
    }
    
    @Override
    protected Map getSelections() {
        Map selections = new HashMap<Long, Long>();
        for (Object id : set) {
            Long item = Long.valueOf(id.toString());
            selections.put(item, item);
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
     * @return returns the set assoctiated to this class   
     */
    public Set <String> getSet() {
        return set;
    }
    
    @Override
    protected void add(Set c) {
        set.addAll(c);
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public Collection getAddedKeys() {
        return CollectionUtils.subtract(getPreSelected(), set);
    }

    /**
     * {@inheritDoc}
     */    
    @Override
    public Collection getRemovedKeys() {
        return CollectionUtils.subtract(set, getPreSelected());
    }    
}
