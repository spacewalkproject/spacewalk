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
package com.redhat.rhn.frontend.xmlrpc.kickstart.profile.software;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartPackage;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.kickstart.XmlRpcKickstartHelper;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

/**
 * SoftwareHandler
 * @xmlrpc.namespace kickstart.profile.software
 * @xmlrpc.doc Provides methods to access and modify the software list
 * associated with a kickstart profile.
 * @version $Rev$
 */
public class SoftwareHandler extends BaseHandler {

    /**
     * Get a list of a kickstart profile's software packages.
     * @param sessionKey An active session key
     * @param ksLabel A kickstart profile label
     * @return A list of package names.
     * @throws FaultException
     * @xmlrpc.doc Get a list of a kickstart profile's software packages.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of a kickstart
     * profile.")
     * @xmlrpc.returntype string[] - Get a list of a kickstart profile's
     * software packages.
     */
    public List<String> getSoftwareList(String sessionKey, String ksLabel) {
        
        User user = getLoggedInUser(sessionKey);
        checkKickstartPerms(user);
        KickstartData ksdata = lookupKsData(ksLabel, user.getOrg());
        List<String> list = new ArrayList<String>();
        for (KickstartPackage p : ksdata.getKsPackages()) {
            list.add(p.getPackageName().getName());
        }
        return list;
    }

    /**
     * Set the list of software packages for a kickstart profile.
     * @param sessionKey An active session key
     * @param ksLabel A kickstart profile label
     * @param packageList  A list of package names.
     * @return 1 on success.
     * @throws FaultException
     * @xmlrpc.doc Set the list of software packages for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of a kickstart
     * profile.")
     * @xmlrpc.param #param_desc("string[]", "packageList", "A list of package
     * names to be set on the profile.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setSoftwareList(
            String sessionKey,
            String ksLabel,
            List<String> packageList) {
        
        User user = getLoggedInUser(sessionKey);
        checkKickstartPerms(user);
        KickstartData ksdata = lookupKsData(ksLabel, user.getOrg());
        Set<KickstartPackage> packages = ksdata.getKsPackages();
        packages.clear();
        KickstartFactory.saveKickstartData(ksdata);
        Long pos = new Long(packages.size()); // position package in list
        for (String p : packageList) {
            PackageName pn = PackageFactory.lookupOrCreatePackageByName(p);
            pos++;
            packages.add(new KickstartPackage(ksdata, pn, pos));
        }
        KickstartFactory.saveKickstartData(ksdata);
        return 1;
    }

    /**
     * Append the list of software packages to a kickstart profile.
     * @param sessionKey An active session key
     * @param ksLabel A kickstart profile label
     * @param packageList  A list of package names.
     * @return 1 on success.
     * @throws FaultException
     * @xmlrpc.doc Append the list of software packages to a kickstart profile.  
     * Duplicate packages will be ignored.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of a kickstart
     * profile.")
     * @xmlrpc.param #param_desc("string[]", "packageList", "A list of package
     * names to be added to the profile.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int appendToSoftwareList(String sessionKey, String ksLabel, 
            List<String> packageList) {
        
        User user = getLoggedInUser(sessionKey);
        checkKickstartPerms(user);
        KickstartData ksdata = lookupKsData(ksLabel, user.getOrg());
        Set<KickstartPackage> packages = ksdata.getKsPackages();
        Long pos = new Long(packages.size()); // position package in list
        for (String p : packageList) {
            PackageName pn = PackageFactory.lookupOrCreatePackageByName(p);
            pos++;
            KickstartPackage kp = new KickstartPackage(ksdata, pn, pos);            
            if (!ksdata.hasKsPackage(kp.getPackageName())) {
                packages.add(kp);
            }
        }
        KickstartFactory.saveKickstartData(ksdata);
        return 1;
    }
    
    private void checkKickstartPerms(User user) {
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException(LocalizationService.getInstance()
                    .getMessage("permission.configadmin.needed"));
        }
    }
    
    private KickstartData lookupKsData(String label, Org org) {
        return XmlRpcKickstartHelper.getInstance().lookupKsData(label, org);
    }
}
