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
package com.redhat.rhn.domain.token;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageName;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Session;

import java.util.List;

/**
 * TokenPackageFactory
 * @version $Rev$
 */
public class TokenPackageFactory extends HibernateFactory {

    private static TokenPackageFactory singleton = new TokenPackageFactory();
    private static Logger log = Logger.getLogger(TokenPackageFactory.class);

    /**
     * Lookup token packages by token.  The result return will be ordered
     * by package name.  This can be useful in displaying the results in the
     * UI.
     * @param tokenIn the token the packages are associated with
     * @return list of token packages found
     */
    public static List<TokenPackage> lookupPackages(Token tokenIn) {
        if (tokenIn == null) {
            return null;
        }

        Session session = null;
        List<TokenPackage> retval = null;
        try {
            session = HibernateFactory.getSession();

            retval = (List<TokenPackage>) session.getNamedQuery(
                "TokenPackage.lookupByToken")
                .setEntity("token", tokenIn)
                //Retrieve from cache if there
                .setCacheable(true).list();
        }
        catch (HibernateException e) {
            log.error("Hibernate exception: " + e.toString());
            throw e;
        }
        return retval;
    }

    /**
     * Lookup token packages by package name.  If there are multiple
     * packages defined for different architectures, multiple packages
     * will be returned.
     * @param tokenIn the token the packages are associated with
     * @param nameIn the name of the package being looked for
     * @return list of token packages found
     */
    public static List<TokenPackage> lookupPackages(Token tokenIn, PackageName nameIn) {
        if ((tokenIn == null) || (nameIn == null)) {
            return null;
        }

        Session session = null;
        List<TokenPackage> retval = null;
        try {
            session = HibernateFactory.getSession();

            retval = (List<TokenPackage>) session.getNamedQuery("TokenPackage.lookupByName")
                .setEntity("token", tokenIn)
                .setEntity("name", nameIn)
                //Retrieve from cache if there
                .setCacheable(true).list();
        }
        catch (HibernateException e) {
            log.error("Hibernate exception: " + e.toString());
            throw e;
        }
        return retval;
    }

    /**
     * Lookup a token package by package name and architecture.
     * @param tokenIn the token the packages are associated with
     * @param nameIn the name of the package requested
     * @param archIn the architecture of the package requested
     * @return list of token packages found
     */
    public static TokenPackage lookupPackage(Token tokenIn, PackageName nameIn,
            PackageArch archIn) {

        if ((tokenIn == null) || (nameIn == null) || (archIn == null)) {
            return null;
        }

        Session session = null;
        TokenPackage retval = null;
        try {
            session = HibernateFactory.getSession();
            retval = (TokenPackage) session.getNamedQuery(
                "TokenPackage.lookupByNameAndArch")
                .setEntity("token", tokenIn)
                .setEntity("name", nameIn)
                .setEntity("arch", archIn)
                //Retrieve from cache if there
                .setCacheable(true)
                .uniqueResult();
        }
        catch (HibernateException e) {
            log.error("Hibernate exception: " + e.toString());
            throw e;
        }
        return retval;
    }

    /**
     * {@inheritDoc}
     */
    protected Logger getLogger() {
        return log;
    }
}
