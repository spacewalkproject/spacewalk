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
 * Converts a list of hunks from a file diff to a unified output format
 * for use with the Unix patch tool.
 * @version $Rev$
 */
public class RhnPatchDiffWriter implements DiffVisitor, DiffWriter {

    private static final int DEFAULT_CONTEXT_LINES = 3;
    private static final char FROM_LABEL = '-';
    private static final char TO_LABEL = '+';
    private static final char MATCH_LABEL = ' ';
    private static final String HUNK_LABEL = "@@";

    //diff the entire result
    private StringBuffer diff;
    private int contextLines;

    //stores the current edit, which can consist of multiple hunks with context lines.
    private EditPoint currentEdit;

    //needed when the last hunk is not a MatchHunk
    private int oldEndLine;
    private int newEndLine;

    /**
     * @param fromPath The from(old, first) file's path
     * @param toPath The to(new, second) file's path
     * @param fromDate The from(old, first) file's last modified date.
     * @param toDate The to(new, second) file's last modified date.
     */
    public RhnPatchDiffWriter(String fromPath, String toPath, Date fromDate, Date toDate) {
        diff = new StringBuffer();


        String dateString = fromDate.toString(); //TODO: format the date
        writeHeader(FROM_LABEL, fromPath, dateString);
        dateString = toDate.toString();
        writeHeader(TO_LABEL, toPath, dateString);
        contextLines = DEFAULT_CONTEXT_LINES;
        currentEdit = null;
    }

    private void writeHeader(char label, String path, String date) {
        //show the label three times
        for (int i = 0; i < 3; i++) {
            diff.append(label);
        }
        diff.append(" ");
        diff.append(path);
        diff.append("\t"); //just doing what GNU diff does.
        diff.append(date);
        diff.append("\n");
    }

    /**
     * {@inheritDoc}
     */
    public void writeHunk(Hunk hunkIn) {
        hunkIn.visit(this);
    }

    /**
     * {@inheritDoc}
     */
    public void accept(ChangeHunk hunk) {
        processEditHunk(hunk);
    }

    /**
     * {@inheritDoc}
     */
    public void accept(DeleteHunk hunk) {
        processEditHunk(hunk);
    }

    /**
     * {@inheritDoc}
     */
    public void accept(InsertHunk hunk) {
        processEditHunk(hunk);
    }

    private void processEditHunk(Hunk hunk) {
        //This should only ever happen if this edit hunk is the very first hunk.
        if (currentEdit == null) {
            int newStartLine = hunk.getNewLines().getFromLine();
            int oldStartLine = hunk.getOldLines().getFromLine();
            currentEdit = new EditPoint(oldStartLine, newStartLine);
        }

        //according to GNU patch, the order doesn't matter, but GNU diff
        //always shows the 'from' lines first, so I do the same.
        addEditLines(hunk.getOldLines().getLines(), FROM_LABEL);
        addEditLines(hunk.getNewLines().getLines(), TO_LABEL);

        //remember in case this hunk goes to the end of the file.
        oldEndLine = hunk.getOldLines().getToLine();
        newEndLine = hunk.getNewLines().getToLine();
    }

    private void addEditLines(List lines, char edit) {
        //adding lines to the edit.
        Iterator i = lines.iterator();
        while (i.hasNext()) {
            currentEdit.addLine((String)i.next(), edit);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void accept(MatchHunk hunk) {
        int startLine = hunk.getOldLines().getFromLine();
        int endLine = hunk.getOldLines().getToLine();
        int numLines = endLine - startLine;

        //Get the matching lines.
        Iterator lines = hunk.getOldLines().getLines().iterator();

        int counter = 0;
        if (currentEdit != null) { //There was an edit hunk before us.
            //Add context after a previous edit.
            while (lines.hasNext() && counter < contextLines) {
                currentEdit.addLine((String)lines.next(), MATCH_LABEL);
                counter++;
            }
        }

        //if this is a separation of two hunks.
        if (currentEdit != null && numLines > 2 * contextLines) {
            //writes one entire edit.
            writeLines(hunk.getOldLines().getFromLine() + counter,
                    hunk.getNewLines().getFromLine() + counter);
        }

        //skip all the lines outside of our context.
        while ((numLines - counter) > contextLines) {
            lines.next();
            counter++;
        }

        if (lines.hasNext() && currentEdit == null) {
            int fromStart = startLine + counter;
            int toStart = hunk.getNewLines().getFromLine() + counter;
            currentEdit = new EditPoint(fromStart, toStart);
        }
        while (lines.hasNext()) {
            //add context before an edit.
            currentEdit.addLine((String)lines.next(), MATCH_LABEL);
        }
    }

    private void writeLines(int fromEnd, int toEnd) {
        diff.append(currentEdit.write(fromEnd, toEnd, HUNK_LABEL, FROM_LABEL, TO_LABEL));
        currentEdit = null;
    }

    /**
     * @return The patch diff.
     */
    public String getResult() {
        //so, we may have not written the last change to the buffer, do it now.
        if (currentEdit != null) {
            diff.append(currentEdit.write(oldEndLine, newEndLine,
                    HUNK_LABEL, FROM_LABEL, TO_LABEL));
        }
        return diff.toString();
    }

    private class EditPoint {
        private int fromStart;
        private int toStart;
        private boolean writable;
        private StringBuffer lines;

        /**
         * @param fromLine Starting line for from file
         * @param toLine Starting line for to file
         */
        public EditPoint(int fromLine, int toLine) {
            fromStart = fromLine;
            toStart = toLine;
            lines = new StringBuffer();
            writable = false;
        }

        public String write(int fromEnd, int toEnd, String edit, char from, char to) {
            if (!writable) { //don't write something that is purely matching lines.
                return new String();
            }
            StringBuffer retval = new StringBuffer();
            retval.append(edit);
            retval.append(" ");
            retval.append(from);
            writeLines(fromStart, fromEnd, retval);
            retval.append(" ");
            retval.append(to);
            writeLines(toStart, toEnd, retval);
            retval.append(" ");
            retval.append(edit);
            retval.append("\n");
            retval.append(lines);
            return retval.toString();
        }

        private void writeLines(int from, int to, StringBuffer buffy) {
            buffy.append(from);
            if (from + 1 != to) { //more than one line shown.
                buffy.append(",");
                buffy.append(to - from); //the number of lines from file shown.
            }
        }

        public void addLine(String line, char type) {
            if (type != MATCH_LABEL) {
                writable = true;
            }
            lines.append(type);
            lines.append(line);
            lines.append("\n");
        }
    }

}
