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
package com.redhat.rhn.manager.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.manager.kickstart.KickstartScriptCreateCommand;
import com.redhat.rhn.manager.kickstart.KickstartScriptDeleteCommand;
import com.redhat.rhn.manager.kickstart.KickstartScriptEditCommand;

/**
 * KickstartScriptTest
 * @version $Rev$
 */
public class KickstartScriptCommandTest extends BaseKickstartCommandTestCase {


    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();

    }

    public void testPreCreate() throws Exception {
        // Lets zero out the scripts
        ksdata.getScripts().clear();
        KickstartFactory.saveKickstartData(ksdata);
        ksdata = (KickstartData) reload(ksdata);
        assertEquals(0, ksdata.getScripts().size());

        // Now make sure we add a new one.
        String language = "/usr/bin/perl";
        String contents = "print \"some string\";\n";
        String chroot = "N";
        KickstartScriptCreateCommand cmd = new
            KickstartScriptCreateCommand(ksdata.getId(), user);
        assertNotNull(cmd.getKickstartData().getScripts());
        KickstartScript kss = cmd.getScript();
        assertNotNull(kss.getScriptType());
        cmd.setScript(language, contents, KickstartScript.TYPE_PRE, chroot, false);
        cmd.store();
        ksdata = (KickstartData) reload(ksdata);
        assertEquals(contents, cmd.getContents());
        assertEquals(language, cmd.getLanguage());
        assertTrue(ksdata.getScripts().size() > 0);
    }

    public void testPreEdit() throws Exception {
        KickstartScript kss = (KickstartScript) ksdata.getScripts().iterator().next();
        String language = "/usr/bin/perl";
        String contents = "print \"some string\";\n";
        String chroot = "Y";
        KickstartScriptEditCommand cmd =
            new KickstartScriptEditCommand(ksdata.getId(), kss.getId(), user);
        cmd.setScript(language, contents, KickstartScript.TYPE_PRE, chroot, true);
        cmd.store();
        ksdata = (KickstartData) reload(ksdata);
        assertEquals(contents, cmd.getContents());
        assertEquals(language, cmd.getLanguage());
        assertTrue(ksdata.getScripts().size() > 0);
    }

    public void testScriptDelete() throws Exception {

        KickstartScript kss = (KickstartScript) ksdata.getScripts().iterator().next();
        assertEquals(5, ksdata.getScripts().size());
        KickstartScriptDeleteCommand cmd = new KickstartScriptDeleteCommand(ksdata.getId(),
                kss.getId(), user);
        cmd.store();
        ksdata = (KickstartData) reload(ksdata);
        assertEquals(4, ksdata.getScripts().size());
    }

}
