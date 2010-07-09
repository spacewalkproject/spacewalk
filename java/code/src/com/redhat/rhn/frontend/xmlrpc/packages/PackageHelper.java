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
package com.redhat.rhn.frontend.xmlrpc.packages;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.translation.Translator;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

import org.apache.commons.lang.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * PackageHelper
 * @version $Rev$
 */
public class PackageHelper {

    /**
     * Private constructor
     */
    private PackageHelper() {
    }

    /**
     * Utility method to convert a package to a map.
     * @param pkg The package to convert
     * @param user The user requesting the package conversion (used in calculating the
     * providing_channels attribute)
     * @return Returns a map representation of a package
     */
    public static Map packageToMap(Package pkg, User user) {

        Map pkgMap = new HashMap();

        // deal with the providing channels first
        DataResult dr = PackageManager.providingChannels(user, pkg.getId());
        List channelLabels = new ArrayList();
        for (Iterator itr = dr.iterator(); itr.hasNext();) {
            Map map = (Map) itr.next();
            channelLabels.add(map.get("label"));
        }
        pkgMap.put("providing_channels", channelLabels);

        // now deal with the actual package object.
        if (pkg.getPackageName() == null) {
            addEntry(pkgMap, "name", "");
        }
        else {
            addEntry(pkgMap, "name",
                    StringUtils.defaultString(pkg.getPackageName().getName()));
        }
        if (pkg.getPackageEvr() == null) {
            addEntry(pkgMap, "epoch", "");
            addEntry(pkgMap, "version", "");
            addEntry(pkgMap, "release", "");
        }
        else {
            PackageEvr evr = pkg.getPackageEvr();
            addEntry(pkgMap, "epoch", StringUtils.defaultString(evr.getEpoch()));
            addEntry(pkgMap, "version", StringUtils.defaultString(evr.getVersion()));
            addEntry(pkgMap, "release", StringUtils.defaultString(evr.getRelease()));
        }

        if (pkg.getPackageArch() == null) {
            addEntry(pkgMap, "arch_label", "");
        }
        else {
            addEntry(pkgMap, "arch_label", pkg.getPackageArch().getLabel());
        }
        addEntry(pkgMap, "id", pkg.getId());
        addEntry(pkgMap, "build_host",
                      StringUtils.defaultString(pkg.getBuildHost()));
        addEntry(pkgMap, "description",
                      StringUtils.defaultString(pkg.getDescription()));
        addEntry(pkgMap, "checksum",
                      StringUtils.defaultString(pkg.getChecksum().getChecksum()));
        addEntry(pkgMap, "checksum_type",
                      StringUtils.defaultString(
                              pkg.getChecksum().getChecksumType().getLabel()));
        addEntry(pkgMap, "vendor",
                      StringUtils.defaultString(pkg.getVendor()));
        addEntry(pkgMap, "summary",
                      StringUtils.defaultString(pkg.getSummary()));
        addEntry(pkgMap, "cookie",
                      StringUtils.defaultString(pkg.getCookie()));
        addEntry(pkgMap, "license",
                      StringUtils.defaultString(pkg.getCopyright()));
        addEntry(pkgMap, "file",
                      StringUtils.defaultString(pkg.getFile()));
        addEntry(pkgMap, "path",
                StringUtils.defaultString(pkg.getPath()));
        addEntry(pkgMap, "build_date",
                      Translator.date2String(pkg.getBuildTime()));
        addEntry(pkgMap, "last_modified_date",
                      Translator.date2String(pkg.getLastModified()));

        Long sz = pkg.getPackageSize();
        addEntry(pkgMap, "size", (sz == null) ? "" : String.valueOf(sz));

        sz = pkg.getPayloadSize();
        addEntry(pkgMap, "payload_size", (sz == null) ? "" : String.valueOf(sz));

        return pkgMap;
    }

    private static void addEntry(Map map, String key, Object value) {
        map.put(key, value);
    }
}
