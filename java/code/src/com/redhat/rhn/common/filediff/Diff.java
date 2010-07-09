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

import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * Manages the action of diffing files and displaying the result using
 * an API of recipes.  Differ is the actual file diff tool and implementers
 * of DiffVisitor and DiffWriter are used to write results.
 * @version $Rev$
 */
public class Diff {

    private String[] firstfile;
    private String[] secondfile;
    private int maxLength;

    /**
     * @param firstfileIn The old(from) file as a String array.
     * @param secondfileIn The new(to) file as a String array.
     */
    public Diff(String[] firstfileIn, String[] secondfileIn) {
        firstfile = firstfileIn;
        secondfile = secondfileIn;
        maxLength = firstfile.length > secondfile.length ?
                firstfile.length : secondfile.length;
    }

    /**
     * @param onlyChanged whether the results should only changed lines.
     * @return An html string for the difference between the two files.
     * @see RhnHtmlDiffWriter
     */
    public String htmlDiff(boolean onlyChanged) {
        //do the file diff
        List hunks = diffFiles();
        if (hunks == null) {
            return null;
        }

        //create the view of the diff.
        RhnHtmlDiffWriter writer = new RhnHtmlDiffWriter(maxLength);
        writer.setOnlyChanged(onlyChanged);
        writeHunks(hunks, writer);
        return writer.getResult();
    }

    /**
     * @param pathOne The path of the from(old, first) file
     * @param pathTwo The path of the to(new, second) file
     * @param fromDate The modified timestamp for the from (old, first) file
     * @param toDate The modified timestamp for the to(new, second) file
     * @return A diff in unified output format.  Able to be used by GNU patch.
     * @see RhnPatchDiffWriter
     */
    public String patchDiff(String pathOne, String pathTwo,
            Date fromDate, Date toDate) {
        //do the file diff
        List hunks = diffFiles();
        if (hunks == null) {
            return null;
        }

        RhnPatchDiffWriter writer =
            new RhnPatchDiffWriter(pathOne, pathTwo, fromDate, toDate);
        writeHunks(hunks, writer);
        return writer.getResult();
    }

    /**
     * Performs the file diff.
     * @return A list of Hunks.
     * @see Hunk
     */
    public List diffFiles() {
        Differ differ = new Differ(firstfile.length, secondfile.length);
        return differ.diff(firstfile, secondfile);
    }

    private void writeHunks(List hunks, DiffWriter writer) {
        Iterator i = hunks.iterator();
        while (i.hasNext()) {
            writer.writeHunk((Hunk)i.next());
        }
    }

}
