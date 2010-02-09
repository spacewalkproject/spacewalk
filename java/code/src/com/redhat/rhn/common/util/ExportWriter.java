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

import java.util.List;

/**
 * ExportWriter - interface that describes the ability to take in a List and reformat
 * it to some other format.  You write the list to the ExportWriter with write() and then
 * fetch the contents when you are finished (or while processing) with getContents().
 * @version $Rev$
 */
public interface ExportWriter {

    /**
     * Set the list of Columns to include in the export.  Must be a List of
     * java.lang.Strings
     * @param columnsIn List of columns you want defined in the output of the export. 
     */
    void setColumns(List<String> columnsIn);
    
    /**
     * Write the List of values to the contents of this Writer.
     * 
     * @param listIn that you want writen to the contents
     */
    void write(List listIn);
    
    /**
     * Get the String version of the values written so far.
     * @return String version of the values
     */
    String getContents();
    
    
    /** 
     * Get the mime type of the output
     * @return String mime type
     */
    String getMimeType();

    /**
     * Get the extension of the file to be exported.
     * @return String extension.
     */
    String getFileExtension();
    
    
}
