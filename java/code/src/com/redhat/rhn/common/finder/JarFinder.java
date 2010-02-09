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

package com.redhat.rhn.common.finder;

import org.apache.log4j.Logger;

import java.io.IOException;
import java.net.JarURLConnection;
import java.net.URL;
import java.util.Enumeration;
import java.util.LinkedList;
import java.util.List;
import java.util.jar.JarFile;
import java.util.zip.ZipEntry;

/**
 * An interface to find classes that implement a given interface.
 *
 * @version $Rev$
 */
class JarFinder implements Finder {

    private static Logger log = Logger.getLogger(JarFinder.class);
    private URL url;

    JarFinder(URL packageUrl) {
        url = packageUrl;
    }

    /** {@inheritDoc} */
    public List find(String endStr) {
        return findExcluding(null, endStr);
    }

    /** {@inheritDoc} */
    public List findExcluding(String[] excludes, String endStr) {
        try {
            JarURLConnection conn = (JarURLConnection)url.openConnection();
            String starts = conn.getEntryName();
            JarFile jfile = conn.getJarFile();

            List result = new LinkedList();

            Enumeration e = jfile.entries();
            while (e.hasMoreElements()) {
                ZipEntry entry = (ZipEntry)e.nextElement();
                String entryName = entry.getName();

                if (log.isDebugEnabled()) {
                    log.debug("Current entry: " + entryName);
                }

                if (entryName.startsWith(starts) &&
                    !entry.isDirectory()) {
                    // Now we know that we have a file from the jar.  We need
                    // to parse the file to get the actual filename so that we
                    // can exclude the appropriate files.
                    if (entryName.endsWith(endStr)) {
                        if (excludes != null) {
                            boolean exclude = false;
                            for (int j = 0; j < excludes.length; j++) {
                                String excludesEnds = excludes[j] + "." + endStr;
                                if (entryName.endsWith(excludesEnds)) {
                                    exclude = true;
                                    break;
                                }
                            }
                            if (!exclude) {
                                result.add(entryName);
                            }
                        }
                        else {
                            result.add(entryName);
                        }
                    }
                }
            }
            return result;
        }
        catch (IOException e) {
            throw new IllegalArgumentException("Couldn't open jar file " + url);
        }
    }
}
