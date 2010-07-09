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
package com.redhat.rhn.domain.rhnpackage.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;

import java.util.List;

/**
 * Simple class to create many packages in parallel
 * PackageCreateTestThread
 * @version $Rev$
 */
class PackageCreateTestThread implements Runnable {

    private String pkgName;
    private List accum;

    public PackageCreateTestThread(String packageName, List accumulator) {
        pkgName = packageName;
        accum = accumulator;
    }

    public void run() {
        try {
            for (int packageCount = 0; packageCount < 100; packageCount++) {
                PackageFactory.lookupOrCreatePackageByName(pkgName);
                HibernateFactory.commitTransaction();
                HibernateFactory.closeSession();
            }
        }
        finally {
            accum.add(pkgName);
            synchronized (accum) {
                accum.notify();
            }
        }
    }

}
