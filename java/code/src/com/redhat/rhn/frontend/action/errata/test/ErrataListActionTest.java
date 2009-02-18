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
package com.redhat.rhn.frontend.action.errata.test;

import com.redhat.rhn.frontend.action.errata.ErrataListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForward;

/**
 * ErrataListRelevantActionTest
 * @version $Rev$
 */
public class ErrataListActionTest extends RhnBaseTestCase {

    public ErrataListActionTest(String name) {
        super(name);
    }

    public void testExecute() throws Exception {
        ErrataListAction action = new ErrataListAction();
        ActionHelper ah = new ActionHelper();
            
        ah.setUpAction(action);    
        ah.setupProcessPagination();
        ah.getRequest().setupAddParameter(RequestContext.FILTER_STRING, "zzzz");
        ah.getRequest().setupAddParameter(RequestContext.PREVIOUS_FILTER_STRING, "zzzz");
        ActionForward forward = ah.executeAction();
        
        assertTrue(forward.getPath().indexOf("zzzz") >= 0);
    }
    
}
