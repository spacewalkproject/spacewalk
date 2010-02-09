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

import java.io.File;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

/**
 * Implementation of Finder that searches the file system
 *
 * @version $Rev$
 */
class FileFinder implements Finder {

    private File startDir;
    private static Logger log = Logger.getLogger(FileFinder.class);
    private String path;

    FileFinder(File directory, String relativeDir) {
        startDir = directory;
        path = relativeDir;
        if (relativeDir.startsWith("/")) {
            path = path.substring(1);
        }
    }

    /** {@inheritDoc} */
    public List find(String endStr) {
        return findExcluding(null, endStr);
    }

    /** {@inheritDoc} */
    public List findExcluding(String[] excludes, String endStr) {
        List results = new LinkedList();

        if (!startDir.exists()) {
            // Shouldn't ever happen, because the FinderFactory should only
            // return a FileFinder.
            return null;
        }
        String[] fileList = startDir.list();

        if (log.isDebugEnabled()) {
            log.debug("Starting search " + startDir);
            log.debug("File Array: " + Arrays.asList(fileList));
        }
        for (int i = 0; i < fileList.length; i++) {
            File current = new File(startDir, fileList[i]);

            if (current.isDirectory()) {
                List subdirList = new FileFinder(current,
                                  path + File.separator +
                                  fileList[i]).findExcluding(excludes, endStr);
                if (log.isDebugEnabled()) {
                    log.debug("adding: " + subdirList);
                }
                results.addAll(subdirList);
                continue;
            }
            if (fileList[i].endsWith(endStr)) {
                if (excludes != null) {
                    boolean exclude = false;
                    for (int j = 0; j < excludes.length; j++) {
                        String excludesEnds = excludes[j] + "." + endStr;
                        if (fileList[i].endsWith(excludesEnds)) {
                            exclude = true;
                            break;
                        }
                    }

                    if (!exclude) {
                        results.add(path + File.separator + fileList[i]);
                    }
                }
                else {
                    results.add(path + File.separator + fileList[i]);
                }
            }
        }
        return results;
    }
}
