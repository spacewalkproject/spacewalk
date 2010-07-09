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
package com.redhat.rhn.manager.channel.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParentChannelException;
import com.redhat.rhn.manager.channel.CreateChannelCommand;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * CreateCommandTest
 * @version $Rev$
 */
public class CreateCommandTest extends RhnBaseTestCase {

    private CreateChannelCommand ccc = null;
    private int label_count = 0;
    private User user = null;

    public void setUp() {
        ccc = new CreateChannelCommand();
        Long oid = UserTestUtils.createOrg("testOrg");
        user = UserTestUtils.createUser("testUser", oid);
        ccc.setUser(user); // non-super user
        ccc.setArchLabel("channel-ia32"); // valid arch label
        ccc.setSummary("empty summary"); // valid summary
        // label and name get set in the test methods as appropriate.
    }
    public void testVerifyChannelName() {

        // channel names at least 6 chars
        //  begin with a letter
        //  contain only letters, digits, spaces, '-', '/', '_', and '.'

        // I N V A L I D
        invalidChannelName("0dd");
        invalidChannelName("Bite Me$");
        invalidChannelName("a123456?");
        invalidChannelName("abc ok &");
        invalidChannelName("");
        invalidChannelName("abc 123-foo/bar_under.ALPHA@");
        invalidChannelName("abc123\\");
        invalidChannelName(null);
        invalidChannelName("_123456");
        // test rhn or red hat channels
        assertFalse(user.hasRole(RoleFactory.RHN_SUPERUSER));
        invalidChannelName("rhn-channel-name");
        invalidChannelName("redhat linux");
        invalidChannelName("Red Hat Enterprise Spacewalk Sync");


        // V A L I D
        validChannelName("dude where's my car"); // we allow ' just don't advertise it
        validChannelName("abc123)");
        validChannelName("thisabc(");
        validChannelName("dude-this-channel");
        validChannelName("is_this-a.valid Channel Name");
        validChannelName("bin/channel/ok");
        validChannelName("abc 123-foo/bar_under.ALPHA");
        validChannelName("Jesusrs API Test Channel");
        validChannelName("0longerthansix");

        // we allow the following characters but don't advertise them
        // ' ( )
        validChannelName("this's a (legal) Nam3");
        validChannelName("Custom Channel 123");
    }

    private void invalidChannelName(String cname) {
        // Give it an invalid name
        ccc.setName(cname);
        ccc.setLabel("valid-label-name"); // valid label

        try {
            assertNotNull(ccc.create());
            fail("invalid channel name should've thrown error");
        }
        catch (InvalidChannelLabelException e) {
            fail("valid label caused error");
        }
        catch (InvalidChannelNameException expected) {
            // expected
        }
        catch (InvalidParentChannelException e) {
            fail("valid parent channel caused error");
        }
    }

    private void validChannelName(String cname) {
        // Give it an valid name
        ccc.setName(cname);
        // need to create unique label names.
        ccc.setLabel("valid-label-name-" + label_count++);

        try {
            Channel c = ccc.create();
            assertNotNull(c);
            assertEquals(c.getName(), cname);
        }
        catch (InvalidChannelLabelException e) {
            fail("valid label caused error");
        }
        catch (InvalidChannelNameException e) {
            fail("valid name caused error");
        }
        catch (InvalidParentChannelException e) {
            fail("valid parent channel caused error");
        }
    }

    public void testVerifyChannelLabel() {

        // channel names at least 6 chars
        //  begin with a letter
        //  contain only letters, digits, spaces, '-', '/', '_', and '.'

        // I N V A L I D
        invalidChannelLabel("0dd");
        invalidChannelLabel("Bite Me$");
        invalidChannelLabel("a123456?");
        invalidChannelLabel("abc ok &");
        invalidChannelLabel("");
        invalidChannelLabel("abc 123-foo/bar_under.ALPHA@");
        invalidChannelLabel("abc123\\");
        invalidChannelLabel(null);
        invalidChannelLabel("_123456");
        invalidChannelLabel("dude where's my car"); // we allow ' just don't advertise it
        invalidChannelLabel("abc123)");
        invalidChannelLabel("thisabc(");
        invalidChannelLabel("is_this-a.valid Channel Label");
        invalidChannelLabel("bin/channel/ok");
        invalidChannelLabel("abc 123-foo/bar_under.ALPHA");
        invalidChannelLabel("Jesusrs API Test Channel");
        invalidChannelLabel("......");
        invalidChannelLabel("------");
        invalidChannelLabel("______");
        // test rhn or red hat channels
        assertFalse(user.hasRole(RoleFactory.RHN_SUPERUSER));
        invalidChannelLabel("rhn-channel-name");
        invalidChannelLabel("redhat linux");
        invalidChannelLabel("Red Hat Enterprise Spacewalk Sync");

        // V A L I D
        validChannelLabel("dude-this-channel");
        validChannelLabel("this.is-valid_1212");
        validChannelLabel("custom-channel-label-200000");
        validChannelLabel("this.is.valid.too");
        validChannelLabel("this-is-valid-too");
        validChannelLabel("and_so_is_this");
        validChannelLabel("nopuncmakesforavalidlabeltoo");
        validChannelLabel("0longerthansix");
    }

    private void invalidChannelLabel(String clabel) {
        // Give it an invalid label
        ccc.setLabel(clabel);
        ccc.setName("Valid Name"); // valid name

        try {
            assertNotNull(ccc.create());
            fail("invalid channel label should've thrown error");
        }
        catch (InvalidChannelLabelException expected) {
            // expected
        }
        catch (InvalidChannelNameException e) {
            fail("valid name caused error");
        }
        catch (InvalidParentChannelException e) {
            fail("valid parent channel caused error");
        }
    }

    private void validChannelLabel(String clabel) {
        // Give it an valid label
        ccc.setLabel(clabel);
        // need to create unique label names.
        ccc.setName("Valid Name" + label_count++);

        try {
            Channel c = ccc.create();
            assertNotNull(c);
            assertEquals(c.getLabel(), clabel);

        }
        catch (InvalidChannelLabelException e) {
            fail("valid label caused error");
        }
        catch (InvalidChannelNameException e) {
            fail("valid name caused error");
        }
        catch (InvalidParentChannelException e) {
            fail("valid parent channel caused error");
        }
    }
}
