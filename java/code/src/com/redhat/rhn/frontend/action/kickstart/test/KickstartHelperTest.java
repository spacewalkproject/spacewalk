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

import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartInstallType;
import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartSessionTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.kickstart.KickstartHelper;
import com.redhat.rhn.frontend.servlets.RhnHttpServletRequest;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

import java.util.Map;

public class KickstartHelperTest extends BaseTestCaseWithUser {

    private KickstartHelper helper;
    private KickstartData ksdata;
    private RhnHttpServletRequest request;
    private RhnMockHttpServletRequest mockRequest;

    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        ksdata = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        // ksdata = KickstartDataTest.createKickstartWithChannel(user.getOrg());
        mockRequest = new RhnMockHttpServletRequest();
        mockRequest.setupGetRemoteAddr("127.0.0.1");
        request = new RhnHttpServletRequest(mockRequest);
        helper = new KickstartHelper(request);
    }

    public void testKsPathparse() {
        // URL:
        String url = "http://rhn.redhat.com/ks/cfg/org/" +
            user.getOrg().getId().toString() +
                "/label/" + ksdata.getLabel();
        request.setAttribute(RequestContext.REQUESTED_URI, url);
        Map options = helper.parseKickstartUrl(url);
        assertNotNull(options);
        assertNotNull(options.get("org_id"));
        assertNotNull(options.get("label"));
        assertNotNull(options.get("ksdata"));
        assertNotNull(options.get("host"));
        assertNotNull(options.get("session"));

    }

    public void testKsViewLabel() {
        // URL:
        String url = "http://rhn.redhat.com/ks/cfg/org/" +
            user.getOrg().getId().toString() +
                "/view_label/" + ksdata.getLabel();
        request.setAttribute(RequestContext.REQUESTED_URI, url);
        Map options = helper.parseKickstartUrl(url);
        assertNotNull(options.get("ksdata"));
        //  This is the key test
        assertNull(options.get("session"));
    }

    public void testIpRangeLabel() throws Exception {


        KickstartIpRange range = new KickstartIpRange();
        range.setMaxString("127.0.0.2");
        range.setMinString("127.0.0.1");
        range.setKsdata(ksdata);
        range.setOrg(user.getOrg());
        ksdata.getIps().add(range);

        // URL:
        String url = "http://rhn.redhat.com/ks/cfg/org/" +
            user.getOrg().getId().toString() +
                "/mode/ip_range";
        request.setAttribute(RequestContext.REQUESTED_URI, url);
        helper = new KickstartHelper(request);
        Map options = helper.parseKickstartUrl(url);

        assertEquals(ksdata, options.get("ksdata"));
        //  This is the key test


        assertNotNull(options.get("session"));
    }

    public void testValidateKickstartChannel() throws Exception {
        Channel base = ChannelTestUtils.createBaseChannel(user);
        Channel tools = ChannelTestUtils.createChildChannel(user, base);
        ksdata.getTree().setChannel(base);
        ksdata.getTree().setInstallType(KickstartFactory.
                lookupKickstartInstallTypeByLabel(KickstartInstallType.RHEL_4));
        assertFalse(ksdata.isRhel5());
        assertFalse(helper.verifyKickstartChannel(ksdata, user));

        PackageManagerTest.addPackageToChannel("rhn-kickstart", tools);
        assertFalse(helper.verifyKickstartChannel(ksdata, user));
        ksdata.getTree().setInstallType(KickstartFactory.
                lookupKickstartInstallTypeByLabel(KickstartInstallType.RHEL_5));
        assertTrue(helper.verifyKickstartChannel(ksdata, user, false));
    }


    public void testKsSessionPathparse() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        KickstartSession session =
            KickstartSessionTest.createKickstartSession(ksdata, user);
        KickstartFactory.saveKickstartSession(session);
        session = (KickstartSession) reload(session);
        assertNotSame(session.getState(), KickstartFactory.SESSION_STATE_CONFIG_ACCESSED);

        String encodedSession = SessionSwap.encodeData(session.getId().toString());
        // URL: /kickstart/ks/session/2xb7d56e8958b0425e762cc74e8705d8e7
        String url = "http://rhn.redhat.com/session/ks/session/" + encodedSession;
        request.setAttribute(RequestContext.REQUESTED_URI, url);
        Map options = helper.parseKickstartUrl(url);
        assertNotNull(options);
        assertNotNull(options.get("org_id"));
        assertNotNull(options.get("ksdata"));
        assertNotNull(options.get("session"));
        assertNotNull(options.get("host"));
        assertEquals(session.getState(), KickstartFactory.SESSION_STATE_CONFIG_ACCESSED);
    }


    public void testKsNoOrg() {
        String url = "http://somesat.redhat.com/ks/cfg/label/" +
            ksdata.getLabel();
        request.setAttribute(RequestContext.REQUESTED_URI, url);
        Map options = helper.parseKickstartUrl(url);
        assertNotNull(options);
    }

    public void testProxyFetch() throws Exception {

        String proxyheader = "1006681409::1151513167.96:21600.0:VV/xFNEmCYOuHx" +
                "EBAs7BEw==:fjs-0-08.rhndev.redhat.com,1006681408::1151513034." +
                "3:21600.0:w2lm+XWSFJMVCGBK1dZXXQ==:fjs-0-11.rhndev.redhat.com" +
                ",1006678487::1152567362.02:21600.0:t15lgsaTRKpX6AxkUFQ11A==:f" +
                "js-0-12.rhndev.redhat.com";

        // mockRequest.setupAddHeader(KickstartHelper.XRHNPROXYAUTH, proxyheader);
        mockRequest.setupGetHeader(KickstartHelper.XRHNPROXYAUTH, proxyheader);
        helper = new KickstartHelper(request);
        assertEquals("fjs-0-08.rhndev.redhat.com", helper.getKickstartHost());

    }


}
