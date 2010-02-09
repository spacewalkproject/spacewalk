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
package com.redhat.rhn.common.util;

import java.io.IOException;
import java.io.OutputStream;
import java.util.List;

import javax.servlet.http.HttpServletResponse;

/**
 * ServletExportHandler - util for taking an ExportWriter and writing it 
 * out to a HttpServletResponse.
 * @version $Rev$
 */
public class ServletExportHandler {
    
    private ExportWriter writer;
    
    /**
     * Constructor with passed in ExportWriter
     * @param writerIn ExportWriter to use
     */
    public ServletExportHandler(ExportWriter writerIn) {
        this.writer = writerIn;
    }
    
    /**
     * Write the contents of the ExportWriter to the HttpServletResponse 
     * @param response to write the contents of the ExportWriter to
     * @param pageList List of data to be exported to the Response
     * @throws IOException if there is an error trying to write to the Response
     */
    public void writeExporterToOutput(HttpServletResponse response, 
                                      List pageList) throws IOException {
        String charSet = response.getCharacterEncoding();
        response.setContentType(writer.getMimeType() + ";charset=" + charSet);
        response.setHeader("Content-Disposition", "attachment; filename=download." +
                writer.getFileExtension());
        writer.write(pageList);
        OutputStream out = response.getOutputStream();
        out.write(writer.getContents().getBytes());
        out.flush();
    }

}
