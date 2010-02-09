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
package com.redhat.rhn.common.security.acl.test;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.security.acl.ErrataAclHandler;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * ErrataAclHandlerTest
 * @version $Rev$
 */
public class ErrataAclHandlerTest extends RhnBaseTestCase {

    public void testErrataIsPublished() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Errata published = ErrataFactoryTest
                .createTestPublishedErrata(user.getOrg().getId());
        Errata unpublished = ErrataFactoryTest
                .createTestUnpublishedErrata(user.getOrg().getId());

        ErrataAclHandler handler = new ErrataAclHandler();
        
        //test false
        Map ctx = new HashMap();
        ctx.put("user", user);
        ctx.put("eid", unpublished.getId());
        boolean result = handler.aclErrataIsPublished(ctx, null);
        assertFalse(result);
        
        //test true
        //ctx = new HashMap();
        ctx.put("eid", published.getId());
        result = handler.aclErrataIsPublished(ctx, null);
        assertTrue(result);
        
        //make sure we get exceptions when we should
        //ctx = new HashMap();
        //bad errata id
        ctx.put("eid", new Long(-234));
        try {
            handler.aclErrataIsPublished(ctx, null);
            fail();
        }
        catch (LookupException e) {
            // success!!!
        }
        //null errata id
        ctx = new HashMap();
        try {
            handler.aclErrataIsPublished(ctx, null);
            fail();
        }
        catch (BadParameterException e) {
            // success!!!
        }
    }
}
