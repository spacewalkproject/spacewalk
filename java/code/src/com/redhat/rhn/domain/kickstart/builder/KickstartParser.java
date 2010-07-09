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
package com.redhat.rhn.domain.kickstart.builder;

import java.util.LinkedList;
import java.util.List;


/**
 * KickstartParser: Parses a kickstart file into the appropriate sections of lines.
 *
 * @version $Rev$
 */
public class KickstartParser {

    private String ksFileContents;
    private List<String> optionLines;
    private List<String> packageLines;
    private List<String> preScriptLines;
    private List<String> postScriptLines;

    /**
     * Constructor.
     * @param kickstartFileContentsIn Contents of the kickstart file.
     */
    public KickstartParser(String kickstartFileContentsIn) {
        ksFileContents = kickstartFileContentsIn;

        optionLines = new LinkedList<String>();
        packageLines = new LinkedList<String>();
        preScriptLines = new LinkedList<String>();
        postScriptLines = new LinkedList<String>();

        String [] ksFileLines = ksFileContents.split("\\n");

        List<String> currentSectionLines = new LinkedList<String>();
        for (int i = 0; i < ksFileLines.length; i++) {
            String currentLine = ksFileLines[i];
            if (isNewSection(currentLine)) {
                storeSection(currentSectionLines);
                currentSectionLines = new LinkedList<String>();
            }

            currentSectionLines.add(currentLine);
        }
        storeSection(currentSectionLines);
    }

    /**
     * Returns true if the given line indicates the start of a new section.
     * @param currentLine Line to check.
     * @return true if the given line indicates the start of a new section.
     */
    private boolean isNewSection(String currentLine) {
        if (!currentLine.startsWith("%")) {
            return false;
        }

        // %include command is not a new section, thus this check:
        String command = currentLine.split(" ")[0];
        return command.equals("%pre") || command.equals("%post") ||
            command.equals("%packages");
    }

    /**
     * Get the option lines of the kickstart file.
     * @return List of option lines.
     */
    public List<String> getOptionLines() {
        return optionLines;
    }

    /**
     * Get the package lines of the kickstart file.
     * @return Line of package lines.
     */
    public List<String> getPackageLines() {
        return packageLines;
    }

    /**
     * Get the pre lines of the kickstart file.
     * @return List of pre-script lines.
     */
    public List<String> getPreScriptLines() {
        return preScriptLines;
    }

    /**
     * Get the post lines of the kickstart file.
     * @return List of post-script lines.
     */
    public List<String> getPostScriptLines() {
        return postScriptLines;
    }

    /**
     * Check the first line in the given list, if it begins with a % then assign the list
     * to the appropriate section. Otherwise assume it's the first section (kickstart
     * options) which are not proceeded by a % delimiter and store it accordingly.
     *
     * @param currentSectionLines Section lines to store.
     */
    private void storeSection(List<String> currentSectionLines) {
        // Check the first line in the current section, if it doesn't start with a
        // % delimiter, assume it's the kickstart options:
        String firstLineInCurrentSection = currentSectionLines.get(0);
        if (!firstLineInCurrentSection.startsWith("%")) {
            optionLines.addAll(currentSectionLines);
        }
        else {
            String section = firstLineInCurrentSection.split(" ")[0];
            if (section.equals("%packages")) {
                packageLines.addAll(currentSectionLines);
            }
            else if (section.equals("%pre")) {
                preScriptLines.addAll(currentSectionLines);
            }
            else if (section.equals("%post")) {
                postScriptLines.addAll(currentSectionLines);
            }
            else {
                throw new KickstartParsingException("Unknown section: " +
                        section);
            }
        }
    }

}
