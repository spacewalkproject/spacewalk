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
package com.redhat.rhn.frontend.servlets;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.util.OvalFileAggregator;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.apache.log4j.Logger;
import org.jdom.JDOMException;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet interface for downloading OVAL files
 *
 * @version $Rev $
 */
public class OvalServlet extends HttpServlet {

    private static Logger logger = Logger.getLogger(OvalServlet.class);

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        String[] errataIds = request.getParameterValues("errata");
        if (errataIds == null || errataIds.length == 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        for (int x = 0; x < errataIds.length; x++) {
            try {
                String tmp = URLDecoder.decode(errataIds[x], "UTF-8");
                errataIds[x] = tmp;
            }
            catch (UnsupportedEncodingException e) {
                logger.warn(e.getMessage(), e);
            }
        }
        String format = request.getParameter("format");
        if (format == null || (!format.equalsIgnoreCase("xml") &&
                !format.equals("zip"))) {
            format = "xml";
        }
        else {
            format = format.toLowerCase();
        }
        List erratas = new LinkedList();
        for (int x = 0; x < errataIds.length; x++) {
            List tmp = ErrataManager.lookupErrataByIdentifier(errataIds[x]);
            if (tmp != null && tmp.size() > 0) {
                erratas.addAll(tmp);
            }
        }
        if (erratas.size() == 0) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, errataIds[0]);
            return;
        }
        List ovalFiles = new LinkedList();
        if (erratas.size() == 1) {
            Errata errata = (Errata) erratas.get(0);

            List of =
                ErrataFactory.lookupErrataFilesByErrataAndFileType(errata.getId(), "oval");
            if (of != null && of.size() > 0) {
                ovalFiles.addAll(of);
            }
        }
        else if (erratas.size() > 1) {
            for (Iterator iter = erratas.iterator(); iter.hasNext();) {
                Errata errata = (Errata) iter.next();
                List files =
                    ErrataFactory.lookupErrataFilesByErrataAndFileType(
                            errata.getId(), "oval");
                ovalFiles.addAll(files);
            }
        }
        if (format.equals("xml")) {
            streamXml(ovalFiles, response);
        }
        else {
            prepareZipFile(ovalFiles, response);
        }
    }

    private void prepareZipFile(List ovalFiles,
            HttpServletResponse response) throws IOException {
        File tempFile = File.createTempFile("rhn", "errata", new File("/tmp"));
        List files = ErrataManager.resolveOvalFiles(ovalFiles);
        if (files.size() == 0) {
            return;
        }
        try {
            ZipOutputStream zipOut = new ZipOutputStream(new FileOutputStream(tempFile));
            for (Iterator iter = files.iterator(); iter.hasNext();) {
                File f = (File) iter.next();
                ZipEntry entry = new ZipEntry(f.getName());
                zipOut.putNextEntry(entry);
                writeFileEntry(f, zipOut);
            }
            zipOut.flush();
            zipOut.close();
            streamZipFile(tempFile, response);
        }
        finally {
            if (!tempFile.delete()) {
                tempFile.deleteOnExit();
            }
        }
    }

    private void streamZipFile(File zipFile,
            HttpServletResponse response) throws IOException {
        response.setContentType("application/zip");
        response.addHeader("Content-disposition", "attachment; filename=oval.zip");
        if (zipFile.length() < Integer.MAX_VALUE) {
            response.setContentLength((int) zipFile.length());
        }
        InputStream fileIn = null;
        try {
            fileIn = new FileInputStream(zipFile);
            sendFileContents(fileIn, response);
        }
        finally {
            if (fileIn != null) {
                fileIn.close();
            }
        }
    }

    private void sendFileContents(InputStream contents,
            HttpServletResponse response) throws IOException {
        try {
            OutputStream out = response.getOutputStream();
            byte[] chunk = new byte[4096];
            int readsize = -1;
            while ((readsize = contents.read(chunk)) > -1) {
                out.write(chunk, 0, readsize);
            }
        }
        finally {
            contents.close();
        }
    }

    private void writeFileEntry(File f, ZipOutputStream zipOut) throws IOException {
        byte[] chunk = new byte[4096];
        int readsize = -1;
        InputStream fileIn = null;
        try {
            fileIn = new FileInputStream(f);
            while ((readsize = fileIn.read(chunk)) > -1) {
                zipOut.write(chunk, 0, readsize);
            }
            zipOut.closeEntry();
        }
        finally {
            if (fileIn != null) {
                fileIn.close();
            }
        }
    }

    private void streamXml(List files,
            HttpServletResponse response) throws IOException {
        response.setContentType("text/xml");
        String fileName = null;
        List ovalFiles = ErrataManager.resolveOvalFiles(files);
        switch(ovalFiles.size()) {
            case 0:
                return;
            case 1:
                File ftmp = (File) ovalFiles.get(0);
                if (ftmp == null) {
                    response.sendError(404, (String) files.get(0));
                }
                fileName = ftmp.getName().toLowerCase();
                if (!fileName.endsWith(".xml")) {
                    fileName += ".xml";
                }
                break;
            default:
                fileName = "oval.xml";
                break;
        }
        response.addHeader("Content-disposition", "attachment; filename=" +
                fileName);
        if (ovalFiles.size() == 1) {
            File f = (File) ovalFiles.get(0);
            if (f.length() < Integer.MAX_VALUE) {
                response.setContentLength((int) f.length());
            }
            InputStream fileIn = null;
            try {
                fileIn = new FileInputStream(f);
                sendFileContents(fileIn, response);
            }
            finally {
                if (fileIn != null) {
                    fileIn.close();
                }
            }
        }
        else {
            try {
                String aggregate = aggregateOvalFiles(ovalFiles);
                response.getWriter().print(aggregate);
                response.getWriter().flush();
            }
            catch (Exception e) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                logger.error(e.getMessage(), e);
            }
        }
    }

    private String aggregateOvalFiles(List files)
            throws JDOMException, IOException {
        OvalFileAggregator aggregator = new OvalFileAggregator();
        String retval = null;
        for (Iterator iter = files.iterator(); iter.hasNext();) {
            File f = (File) iter.next();
            if (f == null) {
                continue;
            }
            aggregator.add(f);
        }
        retval = aggregator.finish(false);

        return retval;
    }

    private List screenHiddenErratum(List erratum) {
        List retval = new LinkedList();
        if (erratum == null || erratum.size() == 0) {
            return retval;
        }
        SelectMode isErrataHidden =
            ModeFactory.getMode("Errata_queries", "is_errata_hidden");
        Map params = new HashMap(1);
        for (Iterator iter = erratum.iterator(); iter.hasNext();) {
            Errata e = (Errata) iter.next();
            params.put("errata_id", e.getId());
            DataResult result = isErrataHidden.execute(params);
            if (result.size() == 0) {
                retval.add(e);
            }
        }
        return retval;
    }
}
