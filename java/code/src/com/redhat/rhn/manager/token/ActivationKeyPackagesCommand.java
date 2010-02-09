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
package com.redhat.rhn.manager.token;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.token.TokenPackage;
import com.redhat.rhn.domain.token.TokenPackageFactory;

import org.apache.log4j.Logger;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;

/**
 * ActivationKeyPackagesCommand - command for handling activation key
 * packages.
 *
 * @version $Rev$
 */
public class ActivationKeyPackagesCommand {

    private static final String NEWLINE = "\n";
    private static final String DOT = ".";

    private static Logger log = Logger.getLogger(ActivationKeyPackagesCommand.class);

    private ActivationKey activationKey;

    /**
     * Constructor
     * @param keyIn the Activation Key this command will operate on
     */
    public ActivationKeyPackagesCommand(ActivationKey keyIn) {
        this.activationKey = keyIn;
    }

    /**
     * Generate a string representation of the packages associated
     * with the activation key.
     * @return String representation of package information
     */
    public String populatePackages() {
        StringBuffer buf = new StringBuffer();

        // in order to ensure that packages are displayed in order, we'll obtain them
        // using the TokenPackageFactory
        List<TokenPackage> packages = TokenPackageFactory.lookupPackages(
                activationKey.getToken());

        if (packages != null) {
            for (TokenPackage name : packages) {

                buf.append(name.getPackageName().getName());

                if (name.getPackageArch() != null) {
                    buf.append(DOT);
                    buf.append(name.getPackageArch().getLabel());
                }
                buf.append(NEWLINE);
            }
        }
        return buf.toString();
    }

    /**
     * Parse the packages in the string provided and update the
     * activation key with the results.
     * @param packagesIn the packages that will be parsed
     * @return validationError return error resulting from parse.  Currently,
     * always returns null.
     */
    public ValidatorError parseAndUpdatePackages(String packagesIn) {

        Set<TokenPackage> tokenPackages = new HashSet<TokenPackage>();

        if (log.isDebugEnabled()) {
            log.debug("parseAndUpdatePackages() : packagesIn: " + packagesIn);
        }

        for (StringTokenizer strtok = new StringTokenizer(packagesIn, NEWLINE); strtok
                .hasMoreTokens();) {
            String token = strtok.nextToken();
            if (token != null) {
                token = token.trim();

                if (token.length() == 0) {
                    continue;
                }

                // check if the token includes a valid arch label.  if it does,
                // it will be stored with the package.
                int lastDot = token.lastIndexOf(DOT);
                String name = token;
                String arch = "";
                PackageArch packageArch = null;
                if (lastDot > 0) {
                    arch = token.substring(lastDot + 1);
                    packageArch = PackageFactory.lookupPackageArchByLabel(arch);
                    if (packageArch != null) {
                        name = token.substring(0, lastDot);
                    }
                }

                PackageName packageName = PackageFactory.lookupOrCreatePackageByName(name);

                TokenPackage tokenPackage = new TokenPackage();
                tokenPackage.setToken(activationKey.getToken());
                tokenPackage.setPackageName(packageName);
                tokenPackage.setPackageArch(packageArch);
                tokenPackages.add(tokenPackage);
            }
        }

        activationKey.clearPackages();

        if (log.isDebugEnabled()) {
            log.debug("parseAndUpdatePackages() : adding tokenPackages: " + tokenPackages);
        }

        activationKey.getPackages().addAll(tokenPackages);

        return null;
    }

    /**
     * Save the ActivationKey data to DB
     * @return ValdiatorError if there was an error.  Currently always returns null
     */
    public ValidatorError store() {
        ActivationKeyFactory.save(activationKey);
        return null;
    }
}
