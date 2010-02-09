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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.domain.user.User;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

/**
 * KickstartIpCommand
 * @version $Rev$
 */

public class KickstartIpCommand extends BaseKickstartCommand {
    private static final long MAX_OCTET = 255;
    private static final long MIN_OCTET = 0;
    /**
     * 
     * @param ksidIn Kickstart Id 
     * @param userIn User
     */
    public KickstartIpCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
    }
    
    /**
     * 
     * @return List representing ip ranges by this Kickstart, ksdata
     */
    public List getDisplayRanges() {
        List l = new LinkedList();
        
        Long id = this.ksdata.getId();
        
        Set s = this.ksdata.getIps();
        
        for (Iterator i = s.iterator(); i.hasNext();) {
            KickstartIpRange ipr = (KickstartIpRange) i.next();
            IpAddress min = new IpAddress(ipr.getMin());
            IpAddress max = new IpAddress(ipr.getMax());            
            IpAddressRange iar = new IpAddressRange(min, max, id);
            l.add(iar);            
        }                
        return l;
    }
    
    /**
     * 
     * @param octet1In min IpRange as octet of longs
     * @param octet2In max IpRange as octet of longs
     * @return success or failure
     */
    public boolean addIpRange(long [] octet1In, long [] octet2In) {
        IpAddress ip1 = new IpAddress(octet1In);
        IpAddress ip2 = new IpAddress(octet2In);
        IpAddressRange range = new IpAddressRange(ip1, ip2, this.ksdata.getId());
        
        // make sure org does not have same ip range
        if (!isDuplicate(range)) {            
            KickstartIpRange ipr = new KickstartIpRange();
            ipr.setMin(ip1.getNumber());
            ipr.setMax(ip2.getNumber());
            ipr.setKsdata(this.ksdata);
            ipr.setOrg(this.user.getOrg());            
            this.ksdata.addIpRange(ipr);
            store();
            return true;
        }
        else {            
            return false; 
        }                
    }
    
    /**
     * 
     * @param octet1In Long array min octet
     * @param octet2In Long array max octet
     * @return true if no duplicates found and successful add
     */
    public boolean addIpRange(Long [] octet1In, Long [] octet2In) {                
        return addIpRange(convertLongArr(octet1In), convertLongArr(octet2In));
    }
    
    /**
     * Validate the IP address are within the valid range.
     * @param oct1In min ip octets
     * @param oct2In max ip octets
     * @return whether this range is valid (octets are 0-255)
     */
    public boolean validateIpRange(long[] oct1In, long[] oct2In) {
        return (validateIp(oct1In) && validateIp(oct2In));
    }

    /**
     * Validate the IP address are within the valid range.
     * @param oct1In min ip octets
     * @param oct2In max ip octets
     * @return whether this range is valid (octets are 0-255)
     */
    public boolean validateIpRange(Long [] oct1In, Long[] oct2In) {
        return (validateIp(convertLongArr(oct1In)) && validateIp(convertLongArr(oct2In)));
    }
    
    /**
     * 
     * @param ksidIn Kickstart Id
     * @param min Min IpRange
     * @param max Max IpRange
     * @return sucess or failure
     */
    public boolean deleteRange(Long ksidIn, String min, String max) {
        Set s = this.ksdata.getIps();        
        for (Iterator i = s.iterator(); i.hasNext();) {
            KickstartIpRange ipr = (KickstartIpRange) i.next();        
            if (ipr.getKsdata().getId().equals(ksidIn) && 
                    ipr.getMax().toString().equals(max) &&
                    ipr.getMin().toString().equals(min)) {                
                s.remove(ipr);
                store();
                return true;
            }
            
        }
        return false;
    }
    
    /**
     * helper utility to validate octets (0-255)
     * @param ipIn 
     * @return true if valid
     */
    private boolean validateIp(long [] ipIn) {
        boolean retval = true;         
        for (int i = 0; (i < ipIn.length) && retval; i++) {
            retval = (ipIn[i] >= MIN_OCTET) && (ipIn[i] <= MAX_OCTET);            
        }        
        return retval;
    }
    
    /**
     * 
     * @param arrIn Long array coming in
     * @return coverted long array
     */
    private long [] convertLongArr(Long[] arrIn) {
        long [] retval =  {arrIn[0].longValue(),
                arrIn[1].longValue(),
                arrIn[2].longValue(),
                arrIn[3].longValue()};
        return retval;
    }
    
    /**
     * 
     * @param iprIn IpAddressRange to check for duplicates 
     * @return if duplicates found matched against org
     */
    private boolean isDuplicate(IpAddressRange iprIn) {
        
        boolean found = false;        
        long max = iprIn.getMax().getNumber();
        long min = iprIn.getMin().getNumber();        
        List l = KickstartFactory.lookupRangeByOrg(this.ksdata.getOrg());        
        for (Iterator itr = l.iterator(); (itr.hasNext() && !found);) {
            KickstartIpRange ksr = (KickstartIpRange) itr.next();
            found = ((ksr.getMax() <= max) && (ksr.getMax() >= min)) || 
                ((ksr.getMin() <= max) && (ksr.getMin() >= min));            
        }                
        
        return found;
    }
}
