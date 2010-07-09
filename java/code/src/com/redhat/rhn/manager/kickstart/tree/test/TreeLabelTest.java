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
package com.redhat.rhn.manager.kickstart.tree.test;

import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.manager.kickstart.tree.TreeEditOperation;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * TreeLabelTest
 * @version $Rev$
 */
public class TreeLabelTest extends BaseTestCaseWithUser {

    public void testValidLabel() {
        // ^([0-9A-Za-z@.]{1,255})$
        // ^([1-zA-Z0-1@.\s]{1,255})$
        // a-zA-Z\d\-\._
        // qr/^[a-zA-Z\d\-\._]*$/
        // PatternCompiler compiler = new Perl5Compiler();

        String regEx = "^([-_0-9A-Za-z@.]{1,255})$";
        Pattern pattern = Pattern.compile(regEx);
        String invalid = "jlkasf*(*&^^(((";
        Matcher matcher = pattern.matcher(invalid);
        assertFalse(matcher.matches());

        invalid = "asdf asdf asdf";
        matcher = pattern.matcher(invalid);
        assertFalse(matcher.matches());

        invalid = "asdf *";
        matcher = pattern.matcher(invalid);
        assertFalse(matcher.matches());

        String valid = "jlkasf_";
        matcher = pattern.matcher(valid);
        assertTrue(matcher.matches());

        valid = "jlkasf_asdf-ajksldf";
        matcher = pattern.matcher(valid);
        assertTrue(matcher.matches());

        valid = "jlkasf_asdf-ajksldf";
        matcher = pattern.matcher(valid);
        assertTrue(matcher.matches());

        //"The Distribution Label field should contain only letters, numbers, hyphens,
        // periods, and underscores. It must also be at least 4 characters long."
        valid = "jlkasf_asdf-ajksldf.890234";
        matcher = pattern.matcher(valid);
        assertTrue(matcher.matches());

    }

    public void testValidateLabel() throws Exception {

        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree(
                ChannelFactoryTest.createTestChannel(user));
        KickstartFactory.saveKickstartableTree(tree);
        tree = (KickstartableTree) reload(tree);
        tree.setLabel("jlkasf_asdf-ajksldf.890234");
        TreeEditOperation cmd = new TreeEditOperation(tree.getId(), user);
        assertTrue(cmd.validateLabel());

        tree.setLabel("jlkasf_asdf-ajksldf.890234**((*(*(9");
        assertFalse(cmd.validateLabel());
    }

}
