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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.dto.BaseDto;

import org.apache.commons.beanutils.BeanUtils;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.Writer;
import java.lang.reflect.InvocationTargetException;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * CSVWriter - util class for writing objects into CSV
 * @version $Rev$
 */
public class CSVWriter extends BufferedWriter implements ExportWriter {
    private List <String> columns;
    private Writer contents;
    private String headerText;

    /**
     * Constructor
     * @param out Writer to send CSV to
     */
    public CSVWriter(Writer out) {
        super(out);
        this.contents = out;
        this.headerText = null;
    }

    /**
     * Set columns
     * @param columnsIn List of Strings containing the names of the columns
     */
    public void setColumns(List<String> columnsIn) {
        columns = new LinkedList<String>();
        for (String column : columnsIn) {
            columns.add(column.trim());
        }
    }

    /**
     * Sets an optional header string.
     * @param headerIn This will become the
     * first line of the export CSV contents.
     */
    public void setHeaderText(String headerIn) {
        headerText = headerIn;
    }

    /**
     * @return String Description of exported data with commas appended
     * to correspond to the number of columns being exported.  Needed so
     * it doesn't break applications which will be parsing this data.
     *
     */
    public String getHeaderText() {
        String hdrStr = headerText;
        if (hdrStr != null) {
            for (int i = 0; i < columns.size() - 1; i++) {
                hdrStr += ",";
            }
        }
        return hdrStr;
    }

    /**
     * Write the header to the stream
     */
    public void writeHeader() {
        write(columns);
    }

    /**
     * {@inheritDoc}
     */
    public void write(List listIn) {
        try {
            this.writeList(listIn);
        }
        catch (IOException e) {
            throw new RuntimeException("IOException caught trying to write the list: " + e);
        }
    }


    /**
     * Write a List to the stream
     * @param values you want to write
     * @throws IOException if there is error
     */
    private void writeList(List values) throws IOException {
        Iterator itr = values.iterator();

        // Write out the column headers
        if (columns != null) {
            Iterator citer = columns.iterator();
            while (citer.hasNext()) {
                String cname = (String) citer.next();
                if (LocalizationService.
                        getInstance().hasMessage("exportcolumn." + cname)) {
                    write(LocalizationService.
                            getInstance().getMessage("exportcolumn." + cname));
                }
                else {
                    write(LocalizationService.
                            getInstance().getMessage(cname));
                }

                if (citer.hasNext()) {
                    writeSeparator();
                }
            }
            newLine();
        }
        // Iterate over the values
        while (itr.hasNext()) {
            Object value = itr.next();
            // If its a List of Strings
            if (value instanceof String) {
                write((String) value);
                if (itr.hasNext()) {
                    writeSeparator();
                }
            }
            // If its a list of Maps or Dtos
            else if (value instanceof Map || value instanceof BaseDto) {
                if (columns == null || !columns.iterator().hasNext()) {
                    throw new IllegalArgumentException("Tried to csv export without" +
                            " setting up the list of columns first");
                }
                Iterator citer = columns.iterator();
                while (citer.hasNext()) {
                    String columnKey = (String) citer.next();
                    Object colVal = getObjectValue(value, columnKey);
                    if (colVal != null) {
                        write(colVal.toString());
                    }
                    if (citer.hasNext()) {
                        writeSeparator();
                    }
                }
                if (itr.hasNext()) {
                    newLine();
                }
            }
            else {
                throw new IllegalArgumentException("Must pass in a List of Strings, " +
                        "Maps or AbstractDto classes");
            }
        }
        // Its always good to end a file with
        // a newline.
        newLine();
    }

    /**
     * Util function to get the value for the current row/column in the List.
     */
    private Object getObjectValue(Object row, String columnKey) {
        if (row instanceof Map) {
            Map rowmap = (Map) row;
            return rowmap.get(columnKey);
        }
        else if (row instanceof BaseDto) {
            String ovalue = null;
            try {
                ovalue = BeanUtils.getProperty(row, columnKey);
            }
            catch (IllegalAccessException e) {
                throw new IllegalArgumentException("Can't access method in DTO: get" +
                        columnKey + "(), IllegalAccessException:" + e.toString());
            }
            catch (InvocationTargetException e) {
                throw new IllegalArgumentException("Can't access method in DTO: get" +
                        columnKey + "(),  InvocationTargetException:" + e.toString());
            }
            catch (NoSuchMethodException e) {
                throw new IllegalArgumentException("Can't call method in DTO class: " +
                        row.getClass().getName() + "." + "get" +
                        columnKey + "(), NoSuchMethodException: " + e.toString());
            }
            return ovalue;
        }
        return null;
    }
    /**
     * Write a string to the Writer
     * {@inheritDoc}
     */
    public void write(String s) throws IOException {
        // If the string does not contain a comma, just write it out
        if (s.indexOf(",") == -1 && s.indexOf("\"") == -1) {
            super.write(s);
            return;
        }

        // If the string does have a comma, then write it out
        // surrounded by quotation marks.  Any quotation mark in the
        // string must be doubled.
        super.write("\"");
        int from = 0;
        for (;;) {
            int to = s.indexOf("\"", from);
            if (to == -1) {
                super.write(s, from, s.length() - from);
                break;
            }

            super.write(s, from, to - from);
            super.write("\"\"");

            from = to + 1;
        }
        super.write("\"");
    }

    /**
     * Write the separator to the Writer
     * @throws IOException if there is a Writer error
     */
    public void writeSeparator() throws IOException {
        super.write(",");
    }

    /**
     * {@inheritDoc}
     */
    public String getContents() {
        try {
            this.flush();
        }
        catch (IOException e) {
            throw new IllegalStateException("Caught IOException while " +
                    "trying to flush contents for output: " + e);
        }
        if (headerText != null) {
            return getHeaderText() + System.getProperty("line.separator") +
                this.contents.toString();
        }
        return this.contents.toString();
    }

    /**
     * {@inheritDoc}
     */
    public String getMimeType() {
        return "text/csv";
    }

    /**
     * {@inheritDoc}
     */
    public String getFileExtension() {
        return "csv";
    }
}
