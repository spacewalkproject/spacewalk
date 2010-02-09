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


/**
 * Hunk - A collection of lines from a diff that represent a single
 * type of edit.
 * @version $Rev$
 */
public abstract class Hunk {
    
    private FileLines oldLines;
    private FileLines newLines;
    
    
    /**
     * @return Returns the newLines.
     */
    public FileLines getNewLines() {
        return newLines;
    }



    
    /**
     * @param newLinesIn The newLines to set.
     */
    public void setNewLines(FileLines newLinesIn) {
        newLines = newLinesIn;
    }



    
    /**
     * @return Returns the oldLines.
     */
    public FileLines getOldLines() {
        return oldLines;
    }



    
    /**
     * @param oldLinesIn The oldLines to set.
     */
    public void setOldLines(FileLines oldLinesIn) {
        oldLines = oldLinesIn;
    }



    /**
     * Standard visitor pattern.
     * @param visitor The accepting object.
     */
    public abstract void visit(DiffVisitor visitor);

}
