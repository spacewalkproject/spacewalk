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
package com.redhat.rhn.frontend.action.errata.test;

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.frontend.action.errata.ErrataSearchAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.collections.IteratorUtils;
import org.apache.struts.action.ActionForward;

import java.util.HashMap;
import java.util.Map;

/**
 * ErrataPackagesSetupActionTest
 * @version $Rev$
 */
public class ErrataSearchActionTest extends RhnBaseTestCase {

    public void testExecute() throws Exception {

        ErrataSearchAction action = new ErrataSearchAction();
        ActionHelper ah = new ActionHelper();
        Errata e = ErrataFactoryTest.createTestErrata(UserTestUtils.createOrg("testOrg"));
        String name = e.getAdvisory();

        ah.setUpAction(action, "success");
        ah.getForm().set("view_mode", "errata_search_by_advisory");
        ah.getForm().set(RhnAction.SUBMITTED, Boolean.TRUE);
        // these are duplicated on PURPOSE! Because mockobjects SUCK ASS!
        ah.getRequest().setupAddParameter("search_string", name);
        ah.getRequest().setupAddParameter("search_string", name);
        ah.getRequest().setupAddParameter("view_mode", "errata_search_by_advisory");
        ah.getRequest().setupAddParameter("view_mode", "errata_search_by_advisory");
        
        // I *HATE* Mockobjects
        Map paramnames = new HashMap();
        paramnames.put("search_string", name);
        paramnames.put("view_mode", "errata_search_by_advisory");
        paramnames.put(RhnAction.SUBMITTED, "true");
        ah.getRequest().setupGetParameterNames(
                IteratorUtils.asEnumeration(paramnames.keySet().iterator()));
        
        ah.setupClampListBounds();

        ActionForward af = ah.executeAction();

        assertTrue(af.getPath().indexOf(name.replaceAll(" ", "+")) != -1);
        assertTrue(af.getPath().indexOf("errata_search_by_advisory") != -1);

    }
}

