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
package com.redhat.rhn.taskomatic.task.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.taskomatic.task.PackageCleanup;
import com.redhat.rhn.taskomatic.task.RhnJob;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.io.File;
import java.sql.Statement;

public class PackageCleanupTest extends RhnBaseTestCase {

    protected void setUp() throws Exception {
        HibernateFactory.getSession().doWork(connection -> {
            try (Statement statement = connection.createStatement()) {
                statement.execute("INSERT INTO rhnPackageFileDeleteQueue(path) " +
                        "VALUES ('test-pkg-delete-me.rpm')"
                );
            }
        });
        new File("/tmp/test-pkg-delete-me.rpm").createNewFile();
    }

    public void testPackageCleanup() throws Exception {
        RhnJob task = new PackageCleanup();
        task.execute(null);
    }
}
