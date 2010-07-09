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
 * A single diff trace through two files.
 * Represents one trace of a linked list of traces.
 * @version $Rev$
 */
public class Trace {
    private Trace next;
    private Edit edit;

    private int currentLineOld;
    private int currentLineNew;
    private int matches;

    /**
     * @param oldSize The size of the old file.
     * @param newSize The size of the new file.
     */
    public Trace(int oldSize, int newSize) {
        //we are going to go backwards through the files for diffing.
        currentLineOld = oldSize - 1;
        currentLineNew = newSize - 1;
        matches = 0;
        edit = null;
        next = null;
    }

    /**
     * Private constructor used when forking a trace.
     * @param currentLineOldIn The current line for the old file.
     * @param currentLineNewIn The current line for the new file.
     * @param parentIn The edit, which will be shortly a parent for a delete edit.
     * @param matchesIn The number of matches in this trace.
     * @param nextIn The next trace in the linked list.
     */
    private Trace(int currentLineOldIn, int currentLineNewIn, Edit parentIn,
            int matchesIn, Trace nextIn) {
        currentLineOld = currentLineOldIn;
        currentLineNew = currentLineNewIn;
        edit = parentIn;
        matches = matchesIn;
        next = nextIn;
        this.makeDelete();
    }

    /**
     * @return The next trace in the linked list.
     */
    public Trace next() {
        return next;
    }

    /**
     * @param nextIn The next trace in the linked list.
     */
    public void setNext(Trace nextIn) {
        next = nextIn;
    }

    /**
     * @return The number of matched lines in this trace.
     */
    public int getMatches() {
        return matches;
    }

    /**
     * @return whether this trace has terminated.
     */
    public boolean isDone() {
        if (currentLineOld == -1 && currentLineNew == -1) {
            return true;
        }
        return false;
    }

    /**
     * @return The best possible number of matched lines for this trace.
     */
    public int bestPossible() {
        int shortest = currentLineOld > currentLineNew ? currentLineNew : currentLineOld;
        return (matches + shortest + 1); //currentLine* is an index, so we must add one.
    }

    private void fork() {
        Edit copy = edit;
        if (edit != null && edit.getType() == Edit.ADD) {
            copy = edit.copy();
        }
        Trace newTrace = new Trace(currentLineOld, currentLineNew, copy, matches, next);
        next = newTrace;
        makeAdd();
    }

    /**
     * Step once in this trace. The power of this algorithm is the fact that
     * different traces are explored in parallel. This method is recursive while
     * it keeps finding matching lines. This is because finding matching lines makes
     * this trace much more possibly optimal. This behaviour is what Myers called
     * the &quot;furthest reaching D-path&quot;
     * <br/>
     * This step method steps backward through the files. This is for the simple reason
     * that when creating hunks, we want to create them in forward order, but we have to
     * visit the edits backwards from how we diffed them.  Two backwards make a forward,
     * two negatives make a positive, and two wrongs make a right.
     * @param oldFile The old(first, from) file
     * @param newFile The new(second, to) file
     * @return whether this step forked. (needed for incrementation by the step controller)
     */
    public boolean step(String[] oldFile, String[] newFile) {
        //This should never occur, because if this trace is done, it should have
        //already been called the best trace. However, defensive programming tells
        //me that I should not assume this.
        if (isDone()) {
            return false;
        }

        //We've reached the end of at least one file, the only possible trace is
        //exploring the other file.
        //We could just trace the rest of the remaining file here since we know what
        //it will be, but this trace is probably not the optimal trace if we his this
        //condition, so lets not waste effort on it.
        if (currentLineOld == -1) {
            makeAdd();
            return false;
        }
        else if (currentLineNew == -1) {
            makeDelete();
            return false;
        }

        String oldLine = oldFile[currentLineOld];
        String newLine = newFile[currentLineNew];

        if (oldLine.equals(newLine)) {
            makeMatch();
            //recurse when we have a match, because this is more
            //likely the correct trace
            return step(oldFile, newFile);
        }
        else {
            //in order to avoid two equal traces (and therefore explode the
            //possible traces and thus memory used), once we start deleting,
            //we keep deleting. Since all traces that delete and then add
            //can be represented by ones that add and then delete, this is
            //computationally sound.
            if (edit != null && edit.getType() == Edit.DELETE) {
                makeDelete();
                return false;
            }
            else {
                fork();
                return true;
            }
        }
    }

    private void makeAdd() {
        makeEdit(Edit.ADD);
        currentLineNew--;
    }

    private void makeDelete() {
        makeEdit(Edit.DELETE);
        currentLineOld--;
    }

    private void makeMatch() {
        makeEdit(Edit.MATCH);
        matches++;
        currentLineNew--;
        currentLineOld--;
    }

    private void makeEdit(char c) {
        if (edit != null && edit.getType() == c) {
            edit.increment();
        }
        else {
            edit = new Edit(c, edit);
        }
    }

    /**
     * Since the diff was performed backwards, "popping" the resulting edits from
     * the backwards tree gives them in forward order.
     * @param oldFile The old(first, from) file
     * @param newFile The new(second, to) file
     * @return A list of hunks representing the edit to make oldFile into newFile.
     */
    public List createHunks(String[] oldFile, String[] newFile) {
        //start at the beginning of both files.
        currentLineOld = 0;
        currentLineNew = 0;
        int linesOld = 0;
        int linesNew = 0;
        List retval = new ArrayList();

        Edit current = edit;
        while (current != null) {
            Hunk hunk;
            //first create the hunk.
            if (current.getType() == Edit.MATCH) {
                hunk = new MatchHunk();
                linesOld = current.getNumber();
                linesNew = current.getNumber();
            }
            else if (current.getType() == Edit.ADD) {
                hunk = new InsertHunk();
                linesOld = 0;
                linesNew = current.getNumber();
            }
            else { //Delete hunk
                /* When diffing, we keep deleting once we started, which means that
                 * going the opposite direction, there may be adds after deletes, but
                 * not deletes after adds.
                 * A change hunk is an add hunk and a delete hunk side by side. Here
                 * is where we do that logic.
                 */
                if (current.getParent() != null &&
                        current.getParent().getType() == Edit.ADD) {
                    hunk = new ChangeHunk();
                    linesOld = current.getNumber();
                    //this causes us to skip an edit. However, change hunks by
                    //definition take two edits, so this is what we want.
                    current = current.getParent();
                    linesNew = current.getNumber();
                }
                else {
                    hunk = new DeleteHunk();
                    linesOld = current.getNumber();
                    linesNew = 0;
                }
            }

            //now that we have a hunk put in the lines from the file.
            fillInHunk(hunk, oldFile, newFile, linesOld, linesNew);
            retval.add(hunk); //add hunk to return list
            current = current.getParent(); //increment
        } //while
        return retval;
    }

    private void fillInHunk(Hunk hunk, String[] oldFile, String[] newFile,
            int oldNum, int newNum) {
        hunk.setNewLines(createFileLines(newFile, currentLineNew, newNum));
        hunk.setOldLines(createFileLines(oldFile, currentLineOld, oldNum));

        //increment the current indexes, so that we don't visit the same lines.
        currentLineOld = currentLineOld + oldNum;
        currentLineNew = currentLineNew + newNum;
    }

    private FileLines createFileLines(String[] file, int fromLine, int numLines) {
        FileLines retval = new FileLines();
        retval.setFromLine(fromLine + 1); //fromLine is an index, so it is one too small
        retval.setToLine(fromLine + numLines + 1); //fromLine is still an index
        for (int i = fromLine; i < fromLine + numLines; i++) {
            retval.addLine(file[i]);
        }

        return retval;
    }
}
