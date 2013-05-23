/**
 * Copyright (c) 2013 Red Hat, Inc.
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
package com.redhat.rhn.manager.audit.scap.file;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import org.apache.struts.actions.DownloadAction.StreamInfo;

import com.redhat.rhn.domain.audit.XccdfTestResult;

/**
 * ScapResultFile
 */
public class ScapResultFile implements StreamInfo {
    private XccdfTestResult testResult;
    private String filename;

    /**
     * Constructeur
     * @param testResultIn The XccdfTestResult which is assigned with the given file
     * @param filenameIn The file name
     */
    public ScapResultFile(XccdfTestResult testResultIn, String filenameIn) {
        testResult = testResultIn;
        filename = filenameIn;
    }

    /**
     * Return the file name of this file
     * @return the file name
     */
    public String getFilename() {
        return filename;
    }

    private String getAbsolutePath() {
        return ScapFileManager.getStoragePath(testResult) + "/" + filename;
    }

    /**
     * Query if the format of the given file is HTML.
     * @return answer
     */
    public Boolean getHTML() {
        return filename.endsWith(".html");
    }

    /**
     * {@inheritDoc}
     */
    public String getContentType() {
        if (filename.endsWith(".xml")) {
            return "text/xml";
        }
        else if (getHTML()) {
            return "text/html";
        }
        else {
            return "application/octet-stream";
        }
    }

    /**
     * {@inheritDoc}
     */
    public InputStream getInputStream() throws IOException {
        return new FileInputStream(getAbsolutePath());
    }

    /**
     * Get human readable representation of this class
     * @return string
     */
    public String toString() {
        return this.getClass().getName() +
            "[path=" + getAbsolutePath() +
            "]";
    }
}
