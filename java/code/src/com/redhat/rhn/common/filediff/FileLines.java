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
package com.redhat.rhn.common.filediff;

import java.util.ArrayList;
import java.util.List;

/**
 * A block of lines from a single file.
 * @version $Rev$
 */
public class FileLines {

    private List lines;
    private int fromLine;
    private int toLine;

    /**
     * Can only be created in this package.
     */
    protected FileLines() {
        lines = new ArrayList();
    }


    /**
     * @param fromLineIn The fromLine to set.
     */
    public void setFromLine(int fromLineIn) {
        fromLine = fromLineIn;
    }


    /**
     * @param toLineIn The toLine to set.
     */
    public void setToLine(int toLineIn) {
        toLine = toLineIn;
    }


    /**
     * @return Returns the fromLine.
     */
    public int getFromLine() {
        return fromLine;
    }


    /**
     * @return Returns the toLine.
     */
    public int getToLine() {
        return toLine;
    }


    /**
     * @return Returns the lines.
     */
    public List getLines() {
        return lines;
    }

    /**
     * @param line The line to append to the list of lines.
     */
    public void addLine(String line) {
        lines.add(line);
    }

}
