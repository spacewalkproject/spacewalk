/**
 * Copyright (c) 2009--2018 Red Hat, Inc.
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

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.hibernate.HibernateFactory;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
     * @param loggedInUser The current user
     * @param ksLabel A kickstart profile label
     * @return A list of package names.
     * @throws FaultException fault exception
     * @xmlrpc.doc Get a list of a kickstart profile's software packages.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of a kickstart
     * profile.")
     * @xmlrpc.returntype string[] - Get a list of a kickstart profile's
     * software packages.
     */
    public List<String> getSoftwareList(User loggedInUser, String ksLabel) {

        checkKickstartPerms(loggedInUser);
        KickstartData ksdata = lookupKsData(ksLabel, loggedInUser.getOrg());
        List<String> list = new ArrayList<String>();
        for (KickstartPackage p : ksdata.getKsPackages()) {
            list.add(p.getPackageName().getName());
        }
        return list;
    }

    /**
     * Set the list of software packages for a kickstart profile.
     * @param loggedInUser The current user
     * @param ksLabel A kickstart profile label
     * @param packageList  A list of package names.
     * @return 1 on success.
     * @throws FaultException fault exception
     * @xmlrpc.doc Set the list of software packages for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of a kickstart
     * profile.")
     * @xmlrpc.param #param_desc("string[]", "packageList", "A list of package
     * names to be set on the profile.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setSoftwareList(
            User loggedInUser,
            String ksLabel,
            List<String> packageList) {

        checkKickstartPerms(loggedInUser);
        KickstartData ksdata = lookupKsData(ksLabel, loggedInUser.getOrg());
        Set<KickstartPackage> packages = ksdata.getKsPackages();
        packages.clear();
        KickstartFactory.saveKickstartData(ksdata);
        //We need to flush session to make the change cascade into DB
        HibernateFactory.getSession().flush();
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
     * Set the list of software packages for a kickstart profile.
     * @param loggedInUser The current user
     * @param ksLabel A kickstart profile label
     * @param packageList  A list of package names.
     * @param ignoremissing The boolean value setting --ignoremissing in %packages line
     * when true
     * @param nobase The boolean value setting --nobase in the %packages line when true
     * @return 1 on success.
     * @throws FaultException fault exception
     * @xmlrpc.doc Set the list of software packages for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of a kickstart
     * profile.")
     * @xmlrpc.param #param_desc("string[]", "packageList", "A list of package
     * names to be set on the profile.")
     * @xmlrpc.param #param_desc("boolean", "ignoremissing", "Ignore missing packages
     * if true")
     * @xmlrpc.param #param_desc("boolean", "nobase", "Don't install @Base package group
     * if true")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setSoftwareList(
            User loggedInUser,
            String ksLabel,
            List<String> packageList,
            Boolean ignoremissing,
            Boolean nobase) {

        checkKickstartPerms(loggedInUser);
        KickstartData ksdata = lookupKsData(ksLabel, loggedInUser.getOrg());
        ksdata.setNoBase(nobase);
        ksdata.setIgnoreMissing(ignoremissing);
        KickstartFactory.saveKickstartData(ksdata);
        return setSoftwareList(loggedInUser, ksLabel, packageList);
    }

    /**
     * Append the list of software packages to a kickstart profile.
     * @param loggedInUser The current user
     * @param ksLabel A kickstart profile label
     * @param packageList  A list of package names.
     * @return 1 on success.
     * @throws FaultException fault exception
     * @xmlrpc.doc Append the list of software packages to a kickstart profile.
     * Duplicate packages will be ignored.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of a kickstart
     * profile.")
     * @xmlrpc.param #param_desc("string[]", "packageList", "A list of package
     * names to be added to the profile.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int appendToSoftwareList(User loggedInUser, String ksLabel,
            List<String> packageList) {

        checkKickstartPerms(loggedInUser);
        KickstartData ksdata = lookupKsData(ksLabel, loggedInUser.getOrg());
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

    /**
     * @param loggedInUser The current user
     * @param ksLabel Kickstart profile label
     * @param params Map containing software parameters
     * @return 1 if successful, exception otherwise.
     * @xmlrpc.doc Sets kickstart profile software details.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "Label of the kickstart profile")
     * @xmlrpc.param
     *          #struct("Kickstart packages info")
     *              #prop_desc("string", "noBase", "Install @Base package group")
     *              #prop_desc("string", "ignoreMissing", "Ignore missing packages")
     *          #struct_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setSoftwareDetails(User loggedInUser, String ksLabel, Map params) {
        KickstartData ksData = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                ksLabel, loggedInUser.getOrg().getId());
        if (params.containsKey("noBase")) {
            ksData.setNoBase((Boolean)params.get("noBase"));
        }
        if (params.containsKey("ignoreMissing")) {
            ksData.setIgnoreMissing((Boolean)params.get("ignoreMissing"));
        }
        return 1;
    }

    /**
     * @param loggedInUser The current user
     * @param ksLabel Kickstart profile label
     * @return Map of KS profile software parameters noBase, ignoreMissingPackages
     * @xmlrpc.doc Gets kickstart profile software details.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "Label of the kickstart profile")
     * @xmlrpc.returntype
     *          #struct("Kickstart packages info")
     *              #prop_desc("string", "noBase", "Install @Base package group")
     *              #prop_desc("string", "ignoreMissing", "Ignore missing packages")
     *          #struct_end()
     */
    public Map<String, Boolean> getSoftwareDetails(User loggedInUser, String ksLabel) {
        KickstartData ksData = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                ksLabel, loggedInUser.getOrg().getId());
        Map<String, Boolean> returnValues = new HashMap<String, Boolean>();
        returnValues.put("noBase", ksData.getNoBase());
        returnValues.put("ignoreMissing", ksData.getIgnoreMissing());
        return returnValues;
    }
}
