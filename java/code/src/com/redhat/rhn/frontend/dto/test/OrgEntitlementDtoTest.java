/**
 * Copyright (c) 2004-2006 Red Hat, Inc.
 * All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * Red Hat, Inc. ("Confidential Information").  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with Red Hat.
 */
package com.redhat.rhn.frontend.dto.test;

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.dto.OrgEntitlementDto;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.testing.BaseTestCaseWithUser;


public class OrgEntitlementDtoTest extends BaseTestCaseWithUser {

    public void testGetUpperRange() throws Exception {
        Org org = user.getOrg();
        OrgEntitlementDto dto = new OrgEntitlementDto(
                EntitlementManager.getByName(
                        EntitlementManager.MONITORING_ENTITLED), org);
        assertNotNull(dto);
        assertNotNull(dto.getUpperRange());
    }
}
