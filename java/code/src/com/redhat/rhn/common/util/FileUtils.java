/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import org.apache.log4j.Logger;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.Writer;


/**
 * Simple file utilities to read/write strings to a file on disk.
 *
 *@version $Rev$
 */
public class FileUtils {

    private static Logger log = Logger.getLogger(FileUtils.class);
    
    private FileUtils() {
    }
    
    /**
     * Save a String to a file on disk using specified path.
     * 
     * WARNING:  This deletes the original file before it writes.
     * 
     * @param contents to save to file on disk
     * @param path to save file to.
     */
    public static void writeStringToFile(String contents, String path) {
        try {
            File ksfile = new File(path);
            if (ksfile.exists()) {
                ksfile.delete();
            }
            ksfile.createNewFile();
            Writer output = new BufferedWriter(new FileWriter(ksfile));
            try {
              output.write(contents);
            }
            finally {
              output.close();
            }
        } 
        catch (Exception e) {
            log.error("Error trying to write KS file to disk: [" + path + "]", e);
            throw new RuntimeException(e);
        }
    }
    
    
    /**
     * Read a file off disk into a String and return it.
     * 
     * Expect weird stuff if the file is not textual.
     * 
     * @param path of file to read in
     * @return String containing file.
     */
    public static String readStringFromFile(String path) {
        log.debug("readStringFromFile: " + path);
        
        File f = new File(path);
        BufferedReader input;
        try {
            input = new BufferedReader(new FileReader(f));
        }
        catch (FileNotFoundException e) {
            throw new RuntimeException("File not found: " + path);
        }
        StringBuilder contents = new StringBuilder();
        String line = null;
        try {
            while ((line = input.readLine()) != null) {
                contents.append(line);
                contents.append(System.getProperty("line.separator"));
            }
        }
        catch (IOException e) {
            throw new RuntimeException(e);
        }
        if (log.isDebugEnabled()) {
            log.debug("contents: " + contents);
        }
        return contents.toString();
    }
    
    /**
     * Read a file off disk into a byte array with specified range
     * 
     * This can use lots of memory if you read a large file
     * 
     * @param fileToRead File to read part of into byte array
     * @param start index of read
     * @param end index of read
     * @return byte[] array from file.
     */
    public static byte[] readByteArrayFromFile(File fileToRead, long start, long end) {
        log.debug("readByteArrayFromFile: " + fileToRead.getAbsolutePath() + 
                " start: " + start + " end: " + end);
        InputStream is;
        try {
            is = new FileInputStream(fileToRead);
        }
        catch (FileNotFoundException fnf) {
            log.error("Could not read from: " + fileToRead.getAbsolutePath());
            throw new RuntimeException(fnf);
        }
        int size = (int) (end - start);
        log.debug("size of array: " + size);
        // Create the byte array to hold the data
        byte[] bytes = new byte[size];
    
        // Read in the bytes
        int offset = 0;
        int numRead = 0;
        try {
            // Skip ahead 
            is.skip(start);
            // start reading
            while (offset < bytes.length && 
                    (numRead) >= 0) {
                numRead = is.read(bytes, offset, 
                        bytes.length - offset);
                offset += numRead;
            }
            is.close();
        }
        catch (IOException e) {
            log.error("Could not read from: " + fileToRead.getAbsolutePath());
            throw new RuntimeException(e);
            
        }
        return bytes;
    }
}
