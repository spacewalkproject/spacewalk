/**
 * Copyright (c) 2017 SUSE LLC
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
package com.redhat.rhn.frontend.action.satellite.util;

import com.redhat.rhn.common.conf.Config;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.io.File;
import java.io.IOException;
import java.nio.file.DirectoryIteratorException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Util class to detect which type of CA certificate is used in the system.
 */
public final class CACertPathUtil {

    public static final String CA_CRT_NAME = "RHN-ORG-TRUSTED-SSL-CERT";
    public static final String CA_CRT_RPM_NAME = "rhn-org-trusted-ssl-cert";
    public static final String GLOB_NOARCH_RPM = "*.noarch.rpm";
    public static final String PUB_TREE = "/pub/";
    private static Logger logger = Logger.getLogger(CACertPathUtil.class);

    private CACertPathUtil() {
    }

    /**
     * Detect which type of CA certificate is used in the system (RPM or file).
     *
     * @return If found, returns the complete path of the certificate (RPM has
     * priority).
     */
    public static String processCACertPath() {
        String docroot = Config.get().getString("documentroot") + PUB_TREE;

        Path docrootPath = Paths.get(docroot);
        String certFile = findRpmCACert(docrootPath);

        if (certFile.equals(StringUtils.EMPTY)) {
            certFile = findCACert(docroot);
        }

        logger.debug("Found CA cert file: " + certFile);
        return certFile;
    }

    private static String findRpmCACert(Path docrootPath) {
        String candidateRpmCA = StringUtils.EMPTY;
        try (DirectoryStream<Path> directoryStream =
                Files.newDirectoryStream(docrootPath, CA_CRT_RPM_NAME + GLOB_NOARCH_RPM)) {
            for (Path rpmFile : directoryStream) {
                logger.debug("Found CA RPM file: " + candidateRpmCA);
                if (rpmFile.toString().compareTo(candidateRpmCA) > 0) {
                    candidateRpmCA = rpmFile.toString();
                }
            }
            return candidateRpmCA;
        }
        catch (IOException | DirectoryIteratorException ex) {
            logger.warn("Cannot scan docroot " + docrootPath +
                    " for CA RPM certificate. Exception: " + ex);
        }
        return candidateRpmCA;
    }

    private static String findCACert(String docroot) {
        File certFile = new File(docroot + CA_CRT_NAME);
        if (certFile.exists() && !certFile.isDirectory()) {
            logger.debug("Found CA file: " + certFile);
            return certFile.toString();
        }
        return StringUtils.EMPTY;
    }
}
