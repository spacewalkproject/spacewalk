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
package com.redhat.rhn.taskomatic.task.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.test.MockMail;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.taskomatic.task.PushedUsers;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.math.RandomUtils;
import org.quartz.JobExecutionException;

import java.util.HashMap;
import java.util.Map;

/**
 * PushedUsersTest
 * @version $Rev$
 */
public class PushedUsersTest extends RhnBaseTestCase {

    private MockMail mailer = new MockMail();
    
    public void testExecute() throws Exception {
        User admin = UserTestUtils.findNewUser("testuser", "testorg", true);
        User newUser = UserTestUtils.createUser("testuser2", admin.getOrg().getId());
        
        //make sure org has an oracle customer number
        Org org = admin.getOrg();
        org.setOracleCustomerNumber(new Integer(RandomUtils.nextInt()));
        OrgFactory.save(org);
        
        WriteMode m = ModeFactory.getWriteMode("test_queries", "insert_into_notifications");
        Map params = new HashMap();
        params.put("id", newUser.getId());
        params.put("org_id", admin.getOrg().getId());
        params.put("contact_email_address", newUser.getEmail());
        m.executeUpdate(params);

        // We don't set any expected send counts because
        // we simply check the value of the email body at the end.
        
        PushedUsers pu = new PushedUsers() {
            protected Mail getMailer() { 
                return mailer;
            }
        };
        
        try {
            pu.execute(null);
        }
        catch (JobExecutionException e) {
            e.printStackTrace();
        }
        
        SelectMode s = ModeFactory.getMode("test_queries", "get_user_notification");
        params = new HashMap();
        params.put("id", newUser.getId());
        DataResult result = s.execute(params);
        assertNotNull(result);
    }
}

