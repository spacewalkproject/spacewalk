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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.manager.kickstart.KickstartWizardHelper;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.List;


/**
 *
 */
public class KickstartWizardHelperTest extends BaseTestCaseWithUser {

    public void testVirtTypes() {
        KickstartWizardHelper helper = new KickstartWizardHelper(user);
        String origConfig = Config.get().getString(ConfigDefaults.PRODUCT_NAME);
        Config.get().setString(ConfigDefaults.PRODUCT_NAME, ConfigDefaults.SPACEWALK);
        assertTrue(ConfigDefaults.get().isSpacewalk());
        List types = helper.getVirtualizationTypes();
        assertNotNull(types);
        boolean found = false;
        for (int i = 0; i < types.size(); i++) {
            KickstartVirtualizationType type = (KickstartVirtualizationType) types.get(i);
            if (type.getLabel().equals(KickstartVirtualizationType.KVM_FULLYVIRT)) {
                found = true;
            }
        }
        assertTrue(found);
        found = false;

        Config.get().setString(ConfigDefaults.PRODUCT_NAME, origConfig);
    }

}
