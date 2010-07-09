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

import org.apache.commons.lang.StringEscapeUtils;

import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Iterator;

/**
 * Converts a list of hunks from a file diff into an html string that represents
 * the view of a diff.
 * @version $Rev$
 */
public class RhnHtmlDiffWriter implements DiffWriter, DiffVisitor {

    private static final int CHARS_PER_LINE = 40;

    private StringBuffer oldfile;
    private StringBuffer newfile;
    private NumberFormat formatter;

    private boolean onlyChanged;

    /**
     * @param lines The number of lines in the longest file.
     *              Used to find out how many digits a line number should be.
     *              Ex: if lines is 12,  line one should be shown as 01, but
     *                  if lines is 100, line one should be shown as 001.
     */
    public RhnHtmlDiffWriter(int lines) {
        onlyChanged = false;
        oldfile = new StringBuffer();
        newfile = new StringBuffer();
        formatter = new DecimalFormat();
        formatter.setMaximumFractionDigits(0);
        formatter.setMinimumIntegerDigits(Integer.toString(lines).length());
    }

    /**
     * {@inheritDoc}
     */
    public void writeHunk(Hunk hunk) {
        hunk.visit(this);
    }

    /**
     * {@inheritDoc}
     */
    public void accept(ChangeHunk hunk) {
        printStartDiv("changed");
        int numOld = printLines(oldfile, hunk.getOldLines());
        int numNew = printLines(newfile, hunk.getNewLines());

        //Line up the changes.
        if (numOld > numNew) {
            printBlankLines(newfile, numOld - numNew);
        }
        else {
            printBlankLines(oldfile, numNew - numOld);
        }
        printEndDiv();
    }

    /**
     * {@inheritDoc}
     */
    public void accept(DeleteHunk hunk) {
        printStartDiv("deleted");
        int numlines = printLines(oldfile, hunk.getOldLines());

        //to line up the two files in the html, print blank lines for
        //each deleted line.
        printBlankLines(newfile, numlines);

        printEndDiv();
    }

    /**
     * {@inheritDoc}
     */
    public void accept(MatchHunk hunk) {
        if (!onlyChanged) {
            printLines(oldfile, hunk.getOldLines());
            printLines(newfile, hunk.getNewLines());
        }
        else {
            //So the changes don't butt up against eachother.
            oldfile.append("<br />");
            newfile.append("<br />");
        }
    }

    /**
     * {@inheritDoc}
     */
    public void accept(InsertHunk hunk) {
        printStartDiv("inserted");
        int numlines = printLines(newfile, hunk.getNewLines());

        //to line up the two files in the html, print blank lines for
        //each inserted line.
        printBlankLines(oldfile, numlines);

        printEndDiv();
    }

    private int printLines(StringBuffer buffy, FileLines block) {
        Iterator i = block.getLines().iterator();
        int numWritten = 0;
        int linenum = block.getFromLine();
        while (i.hasNext()) {
            String line = (String)i.next();
            buffy.append(formatter.format(linenum));
            buffy.append("&nbsp;");
            while (line.length() > CHARS_PER_LINE) {
                //We want to escape all of the html inside the file
                //This utility function doesn't escape spaces, so I'll do that
                //myself, ... the easy way.
                buffy.append(StringEscapeUtils
                        .escapeHtml(line.substring(0, CHARS_PER_LINE))
                        .replaceAll(" ", "&nbsp;"));
                buffy.append("<br />");
                for (int p = 0; p < formatter.getMinimumIntegerDigits() + 1; p++) {
                    buffy.append("&nbsp;");
                }
                line = line.substring(CHARS_PER_LINE);
                numWritten++;
            }
            buffy.append(StringEscapeUtils.escapeHtml(line)
                    .replaceAll(" ", "&nbsp;"));
            buffy.append("<br />");
            numWritten++;
            linenum++;
        }
        return numWritten;
    }

    private void printBlankLines(StringBuffer buffy, int number) {
        for (int i = 0; i < number; i++) {
            buffy.append("&nbsp;<br />");
        }
    }

    private void printStartDiv(String cssClass) {
        oldfile.append("<div class=\"" + cssClass + "\">");
        newfile.append("<div class=\"" + cssClass + "\">");
    }

    private void printEndDiv() {
        oldfile.append("</div>");
        newfile.append("</div>");
    }




    /**
     * @return The resulting html String.  Valid only after running report.
     */
    public String getResult() {
        StringBuffer result = new StringBuffer();
        result.append("<div class=\"oldfile\">");
        result.append(oldfile);
        result.append("</div>");
        result.append("<div class=\"newfile\">");
        result.append(newfile);
        result.append("</div>");
        return result.toString();
    }


    /**
     * @param onlyChangedIn The onlyChanged to set.
     */
    public void setOnlyChanged(boolean onlyChangedIn) {
        onlyChanged = onlyChangedIn;
    }

}
