/**
 * Copyright (c) 2011--2012 Red Hat, Inc.
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
package com.redhat.rhn.testing;

import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Hashtable;

import javax.servlet.http.HttpServletRequest;

import org.apache.struts.Globals;
import org.apache.struts.upload.CommonsMultipartRequestHandler;
import org.apache.struts.upload.FormFile;

import servletunit.HttpServletRequestSimulator;


/**
 * RhnPostMockStrutsTestCase
 * @version $Rev$
 */
public class RhnPostMockStrutsTestCase extends RhnMockStrutsTestCase {

    /**
     * override the setupUp method
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        request.setMethod(HttpServletRequestSimulator.POST);
        UploadsHandler.clear();
    }

    /**
     * Adds an uploaded text file to the form.
     *
     * @param parameterName upload form parameter name
     * @param fileName the file name
     * @param contents the file contents
     */
    public void addUploadedFile(String parameterName, final String fileName,
            final String contents) {

        request.setContentType("multipart/form-data");
        request.setAttribute(Globals.MULTIPART_KEY, UploadsHandler.class.getName());

        final FormFile ff = new FormFile() {
            public void destroy() {
            }

            public String getContentType() {
                return "text/plain";
            }

            public byte[] getFileData() throws FileNotFoundException, IOException {
                return contents.getBytes();
            }

            public String getFileName() {
                return fileName;
            }

            public int getFileSize() {
                return contents.length();
            }

            public InputStream getInputStream() throws FileNotFoundException, IOException {
                return new ByteArrayInputStream(contents.getBytes());
            }

            public void setContentType(String contentType) {
            }

            public void setFileName(String fileName) {
            }

            public void setFileSize(int fileSize) {
            }
        };

        UploadsHandler.addUpload(parameterName, ff);
    }

    /**
     * An utility class to handle multipart requests.
     */
    public static final class UploadsHandler extends CommonsMultipartRequestHandler {
        /** The request. */
        private HttpServletRequest request = null;

        /**
         * Hashtable of uploaded file elements.
         */
        private static Hashtable<String, FormFile> uploadedFileElements =
                new Hashtable<String, FormFile>();

        /**
         * Adds an uploaded file.
         * @param parameterName the parameter name
         * @param file the file
         */
        public static void addUpload(String parameterName, FormFile file) {
            uploadedFileElements.put(parameterName, file);
        }

        /**
         * Clears uploaded files.
         */
        public static void clear() {
            uploadedFileElements.clear();
        }


        /**
         * Handles a request.
         * @param requestIn the request
         */
        @Override
        public void handleRequest(HttpServletRequest requestIn) {
            request = requestIn;
        }


        /**
         * Returns all request elements, including uploaded files.
         *
         * @return the all elements
         */
        @SuppressWarnings("unchecked")
        @Override
        public Hashtable<String, Object> getAllElements() {
            Hashtable<String, Object> result =
                    new Hashtable<String, Object>(uploadedFileElements);
            result.putAll(request.getParameterMap());
            return result;
        }

        /**
         * Cleans up if problems arise.
         */
        @Override
        public void rollback() {
            // nothing to do since this is just a stub
        }
    }
}
