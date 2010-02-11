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
package com.redhat.rhn.frontend.action.kickstart.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.frontend.action.kickstart.KickstartDetailsEditAction;
import com.redhat.rhn.frontend.struts.RequestContext;

import org.hibernate.Session;

public class KickstartDeleteActionTest extends BaseKickstartEditTestCase {
    
    private final String KICKSTART_ID = "ksid";
    
    public void testExecute() throws Exception {
        setRequestPathInfo("/kickstart/KickstartDelete");
        addRequestParameter(KickstartDetailsEditAction.COMMENTS, "test comment");
        addRequestParameter(KickstartDetailsEditAction.LABEL, "test label");
        addRequestParameter(KickstartDetailsEditAction.ACTIVE, Boolean.TRUE.toString());
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
    }  
    
    public void testSubmit() throws Exception {
        setRequestPathInfo("/kickstart/KickstartDelete");
        addRequestParameter(KickstartDetailsEditAction.SUBMITTED, 
                                               Boolean.TRUE.toString());
        addRequestParameter(KickstartDetailsEditAction.COMMENTS, "test comment");
        addRequestParameter(KickstartDetailsEditAction.LABEL, "test label");
        addRequestParameter(KickstartDetailsEditAction.ACTIVE, Boolean.TRUE.toString());
        actionPerform();
       
        String[] keys = {"kickstart.delete.success"};
        verifyActionMessages(keys);
        
        assertNull(lookupById(new Long(request.getParameter(KICKSTART_ID))));
    } 
    
    /**
     * Helper method to lookup KickstartData by id
     * @param id Id to lookup
     * @return Returns the KickstartData
     * @throws Exception
     */
    private KickstartData lookupById(Long id) throws Exception {
        Session session = HibernateFactory.getSession();
        return (KickstartData) session.getNamedQuery("KickstartData.findByIdAndOrg")
                          .setLong("id", id.longValue())
                          .setLong("org_id", user.getOrg().getId().longValue())
                          .uniqueResult();
    }
}
