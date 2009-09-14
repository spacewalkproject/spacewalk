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
package com.redhat.rhn.frontend.action.multiorg;

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.org.OrgManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.collections.ListUtils;
import org.apache.commons.collections.Transformer;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UserListSetupAction
 * @version $Rev: 101893 $
 */
public class UserOrgsAction extends RhnAction implements Listable {

    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form, 
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();     
        
        User uidUser = requestContext.getUserFromUIDParameter();
        
        
        
        
        
        ListSessionSetHelper helper = new ListSessionSetHelper(this, request);
        
        Set userSet = new HashSet();
        for (Org org : UserFactory.getInstance().listOrgsForUser(uidUser)) {
            userSet.add(org.getId().toString());
        }
        
        helper.preSelect(userSet);
        
        
        helper.execute();
        request.setAttribute("uid", uidUser.getId());
        
        
        if(helper.isDispatched()) {
            Collection added = helper.getAddedKeys();
            CollectionUtils.transform(added, this.new StringTransformer());
            UserManager.addUserToOrgs(user, uidUser, added);
            
            Collection removed = helper.getRemovedKeys();
            CollectionUtils.transform(removed, this.new StringTransformer());
            UserManager.removeUsersFromOrgs(user, uidUser, removed);
             

             helper.destroy() ;
             
             Map params = new HashMap();
             params.put(RequestContext.USER_ID, uidUser.getId());
             return getStrutsDelegate().forwardParams(mapping.findForward("submit"),
                     params);
         } 
        
        
        return mapping.findForward("default");
    }

    @Override
    public List getResult(RequestContext context) {
        return OrgManager.allOrgs(context.getLoggedInUser());
    }
    
    
    private class StringTransformer implements Transformer {

        @Override
        public Object transform(Object input) {
            String string = (String) input;
            return Long.parseLong(string);
        }
        
    }
    
}
