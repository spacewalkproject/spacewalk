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

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.frontend.action.kickstart.KickstartDetailsEditAction;
import com.redhat.rhn.frontend.action.kickstart.KickstartIpRangeAction;
import com.redhat.rhn.frontend.action.kickstart.KickstartIpRangeDeleteAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.IpAddress;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;

/**
 * KickstartIpRangeActionTest
 * @version $Rev: 1 $
 */
public class KickstartIpRangeActionTest extends RhnMockStrutsTestCase {
    
    protected KickstartData ksdata;
    protected KickstartIpRange ip1;
    protected KickstartIpRange ip2;
    
    public void setUp() throws Exception {
        super.setUp();
        this.ksdata = KickstartDataTest.createKickstartWithChannel(user.getOrg());        
        this.ksdata.setOrg(user.getOrg());
        TestUtils.saveAndFlush(ksdata);        
                
        addRequestParameter(RequestContext.KICKSTART_ID, this.ksdata.getId().toString());
    }
    
    public void testRange() throws Exception {
        setRequestPathInfo("/kickstart/KickstartIpRangeEdit");
        
        ip1 = new KickstartIpRange();
        ip2 = new KickstartIpRange();

        ip1.setKsdata(ksdata);
        ip2.setKsdata(ksdata);
        ip1.setOrg(ksdata.getOrg());
        ip2.setOrg(ksdata.getOrg());
        ip1.setMin(3232236034L); // 192.168.1.1
        ip1.setMax(3232236282L); 
        ip2.setMin(3232236547L);
        ip2.setMax(3232236794L);
        ip1.setCreated(new Date());
        ip2.setCreated(new Date());
        ip1.setModified(new Date());
        ip2.setModified(new Date());
        
        ksdata.addIpRange(ip1);
        ksdata.addIpRange(ip2);
        TestUtils.saveAndFlush(ksdata);
                
        actionPerform();
        assertNotNull(request.getAttribute(KickstartIpRangeAction.RANGES));
        assertEquals(2, ksdata.getIps().size());
    }  
    
    public void testNoRange() throws Exception {
        setRequestPathInfo("/kickstart/KickstartIpRangeEdit");        
        actionPerform();
        assertNotNull(request.getAttribute(KickstartIpRangeAction.RANGES));
        assertEquals(0, ksdata.getIps().size());
    }
    
    public void testSubmit() throws Exception {
        setRequestPathInfo("/kickstart/KickstartIpRangeEdit");
        addRequestParameter(KickstartDetailsEditAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(KickstartIpRangeAction.OCTET1A, "192");
        addRequestParameter(KickstartIpRangeAction.OCTET1B, "168");
        addRequestParameter(KickstartIpRangeAction.OCTET1C, "1");
        addRequestParameter(KickstartIpRangeAction.OCTET1D, "1");
        addRequestParameter(KickstartIpRangeAction.OCTET2A, "192");
        addRequestParameter(KickstartIpRangeAction.OCTET2B, "168");
        addRequestParameter(KickstartIpRangeAction.OCTET2C, "1");
        addRequestParameter(KickstartIpRangeAction.OCTET2D, "9");        
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
        String[] keys = {"kickstart.iprange_add.success"};
        verifyActionMessages(keys);
    }
    
    public void testValidateFailure() throws Exception {        
        setRequestPathInfo("/kickstart/KickstartIpRangeEdit");
        addRequestParameter(KickstartDetailsEditAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(KickstartIpRangeAction.OCTET1A, "192");
        addRequestParameter(KickstartIpRangeAction.OCTET1B, "168");
        addRequestParameter(KickstartIpRangeAction.OCTET1C, "1");
        addRequestParameter(KickstartIpRangeAction.OCTET1D, "300");
        addRequestParameter(KickstartIpRangeAction.OCTET2A, "192");
        addRequestParameter(KickstartIpRangeAction.OCTET2B, "168");
        addRequestParameter(KickstartIpRangeAction.OCTET2C, "1");
        addRequestParameter(KickstartIpRangeAction.OCTET2D, "9");        
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
        String[] keys = {"kickstart.iprange_validate.failure"};
        verifyActionErrors(keys);
    }
    
    public void testConflictFailure() throws Exception {                
        
        long [] range1 = {192, 168, 2, 1};
        long [] range2 = {192, 168, 2, 9};
        IpAddress ipa1 = new IpAddress(range1);
        IpAddress ipa2 = new IpAddress(range2);
        
        KickstartIpRange ipr = new KickstartIpRange();
        ipr.setCreated(new Date());
        ipr.setModified(new Date());
        ipr.setKsdata(this.ksdata);
        ipr.setOrg(ksdata.getOrg());
        ipr.setMax(ipa2.getNumber());
        ipr.setMin(ipa1.getNumber());        
        this.ksdata.addIpRange(ipr); 
        
        KickstartFactory.saveKickstartData(this.ksdata);
                
        // now try to submit same range 
        setRequestPathInfo("/kickstart/KickstartIpRangeEdit");
        addRequestParameter(KickstartDetailsEditAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(KickstartIpRangeAction.OCTET1A, "192");
        addRequestParameter(KickstartIpRangeAction.OCTET1B, "168");
        addRequestParameter(KickstartIpRangeAction.OCTET1C, "2");
        addRequestParameter(KickstartIpRangeAction.OCTET1D, "1");
        addRequestParameter(KickstartIpRangeAction.OCTET2A, "192");
        addRequestParameter(KickstartIpRangeAction.OCTET2B, "168");
        addRequestParameter(KickstartIpRangeAction.OCTET2C, "2");
        addRequestParameter(KickstartIpRangeAction.OCTET2D, "9");                 
        
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
        String[] keys = {"kickstart.iprange_conflict.failure"};
        verifyActionErrors(keys);               
    }
    
    public void testDeleteSuccess() throws Exception {
        long [] range1 = {192, 168, 3, 1};
        long [] range2 = {192, 168, 3, 9};
        IpAddress ipa1 = new IpAddress(range1);
        long ip1num = ipa1.getNumber();
        IpAddress ipa2 = new IpAddress(range2);
        long ip2num = ipa2.getNumber();
        
        KickstartIpRange ipr = new KickstartIpRange();
        ipr.setCreated(new Date());
        ipr.setModified(new Date());
        ipr.setKsdata(this.ksdata);
        ipr.setOrg(ksdata.getOrg());
        ipr.setMax(ipa2.getNumber());
        ipr.setMin(ipa1.getNumber());        
        this.ksdata.addIpRange(ipr);                 
        TestUtils.saveAndFlush(ksdata);        
        
        setRequestPathInfo("/kickstart/KickstartIpRangeDelete");
        addRequestParameter(KickstartIpRangeDeleteAction.MAX, String.valueOf(ip2num));
        addRequestParameter(KickstartIpRangeDeleteAction.MIN, String.valueOf(ip1num));
  
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
        String[] keys = {"kickstart.iprange_delete.success"};
        verifyActionMessages(keys);                       
    }
    
    public void testDeleteFailure() throws Exception {
        long [] range1 = {192, 168, 4, 1};
        long [] range2 = {192, 168, 4, 9};
        IpAddress ipa1 = new IpAddress(range1);       
        IpAddress ipa2 = new IpAddress(range2);        
        
        KickstartIpRange ipr = new KickstartIpRange();
        ipr.setCreated(new Date());
        ipr.setModified(new Date());
        ipr.setKsdata(this.ksdata);
        ipr.setOrg(ksdata.getOrg());
        ipr.setMax(ipa2.getNumber());
        ipr.setMin(ipa1.getNumber());        
        this.ksdata.addIpRange(ipr);         
        KickstartFactory.saveKickstartData(this.ksdata);
        
        setRequestPathInfo("/kickstart/KickstartIpRangeDelete");
        addRequestParameter(KickstartIpRangeDeleteAction.MAX, "0");
        addRequestParameter(KickstartIpRangeDeleteAction.MIN, "10"); 

        actionPerform();        
        String[] keys = {"kickstart.iprange_delete.failure"};
        verifyActionErrors(keys);                       
    }        
}

