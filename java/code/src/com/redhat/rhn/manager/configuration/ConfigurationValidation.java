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
package com.redhat.rhn.manager.configuration;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * ConfigurationValidation
 *
 * Holds methods for validating a variety of configuration-related fields/values
 *
 * @version $Rev$
 */
public class ConfigurationValidation {

    private ConfigurationValidation() { }

    /**
     * Validate incoming content.  This attempts to do macro-substitution and complains
     * bitterly if it runs into problems:
     *
     * <ul>
     * <li>Can't find a function-name between the delimiters
     * <li>Don't like the function-name between the delimiters
     * <li>Don't like the arguments passed to the function-name between the delimiters
     * </ul>
     *
     * Returns an error list.  An element is a Map with keys "key", "arg0", "arg1", "arg2".
     * The map values are used to I18N the resulting error message.
     *
     * @param content content of a TEXT config-file
     * @param macroStart start macro
     * @param macroEnd end macro
     * @return ValidatorResult. These will be reasons
     * why this content didn't pass.  if result.isEmpty() - everything is OK
     */
    public static ValidatorResult validateContent(String content,
                                        String macroStart, String macroEnd) {
        ValidatorResult result = new ValidatorResult();


        // If no-file or macros aren't in the file, we're ok
        if (content == null || content.length() == 0) {
            return result;
        }

        boolean hasStart = content.indexOf(macroStart) >= 0;
        boolean hasEnd = content.indexOf(macroEnd) >= 0;

        // If no macros, we're done too
        if (!hasStart && !hasEnd) {
            return result;
        }

        // Macros might contain special reg-ex chars - escape them
        String escStart = ConfigurationValidation.regexEscape(macroStart);
        String escEnd = ConfigurationValidation.regexEscape(macroEnd);

        // Start-delim followed by zero or more whitespace followed by zero or more
        // characters followed by zero or more whitespace followed by end-delim
        String findMacroStr = escStart + "(.*?)" + escEnd;

        // One or more chars NOT parentheses$1,
        // followed by zero or one "( any-chars$3 ) $2",
        // followed by zero or one "= any-chars$5 $4"
        String macroStr = "([^()]+)(\\((.*?)\\))?\\s*(=(.*))?";

        Pattern findMacro = Pattern.compile(findMacroStr,
                Pattern.MULTILINE + Pattern.DOTALL);
        Pattern macroPattern = Pattern.compile(macroStr, Pattern.DOTALL);

        Matcher matchMacro = findMacro.matcher(content);
        while (matchMacro.find()) {
            String seq = matchMacro.group(1).trim();
            if (seq.length() == 0) {
                // Empty macro - skip
                continue;
            }

            Matcher parts = macroPattern.matcher(seq);
            if (parts.matches()) {
                String name = parts.group(1);
                String args = parts.group(3);
                // String deflt = parts.group(5);

                // Can't find a function-name
                if (name == null || name.trim().length() == 0) {
                    result.addError(new ValidatorError(
                                "configmanager.filedetails.content.no-macro-name"));
                }
                // Function-name doesn't look like one we understand
                else if (!name.startsWith("rhn.system.")) {
                    result.addError(new ValidatorError(
                                "configmanager.filedetails.content.bad-macro-name",
                                        name.trim()));
                }

                // Arg-content must be word, whitespace values, or hyphens
                String regex = Config.get().getString(
                        ConfigDefaults.CONFIG_MACRO_ARGUMENT_REGEX, "[\\w\\s-:]*");
                if (args != null && !args.trim().matches(regex)) {
                    result.addError(new ValidatorError(
                                "configmanager.filedetails.content.bad-arg-content",
                                name.trim(), args.trim()));
                }
            }
            else {
                // Something truly odd happened - complain bitterly
                result.addError(new ValidatorError(
                            "configmanager.filedetails.content.bad-macro",
                                    matchMacro.group(0)));
            }
        }
        return result;
    }

    /**
     * Validate config-file pathname.  The rules are pretty basic:
     *
     * <ul>
     * <li>MUST start with '/'
     * <li>CANNOT end with a '/'
     * <li>CANNOT be relative - no '..' anywhere
     * </ul>
     * That's it.
     * @param path pathname to be validated
     * @return a Validator Result.
     */
    public static ValidatorResult validatePath(String path) {
        ValidatorResult result = new ValidatorResult();

        if (path == null || path.length() == 0) {
            result.addError(new ValidatorError(
                                "configmanager.filedetails.path.empty", path));
            return result;
        }

        if (!path.startsWith("/")) {
            result.addError(new ValidatorError(
                           "configmanager.filedetails.path.no-starting-slash", path));
        }

        if (path.endsWith("/")) {
            result.addError(new ValidatorError(
                    "configmanager.filedetails.path.has-ending-slash", path));
        }

        if (path.indexOf("..") != -1) {
            result.addError(new ValidatorError(
                    "configmanager.filedetails.path.has-relative-dirs", path));
        }

        return result;
    }

    /**
     * Validate a user- or group-ID.  Tests that it's a valid Linux u/gid
     * (positive int)
     * @param in string to be tested
     * @return true if valid, false otherwise
     */
    public static boolean validateUGID(String in) {
        boolean valid = false;
        try {
            int i = Integer.parseInt(in);
            valid = (i > 0);
        }
        catch (Exception e) {
            valid = false;
        }
        return valid;
    }

    /**
     * Validate a user- or group-NAME.  Tests that it's a valid Linux name
     * (starts w/alpha, followed by alphanumeric_-)
     * @param in string to be tested
     * @return true if valid, false otherwise
     */
    public static boolean validateUserOrGroup(String in) {
        return (in != null && in.matches("^[a-zA-Z][a-zA-Z0-9_\\-]*$"));
    }

    /**
     * Escape a string that is going to be used to build a regex expression
     * @param inStr string of interest
     * @return string with non-whitespace and non-word characters escaped
     */
    static String regexEscape(String inStr) {
        StringBuffer buff = new StringBuffer("");
        for (int i = 0; i < inStr.length(); i++) {
            if (!inStr.substring(i, i + 1).matches("[\\s\\w]")) {
                buff.append("\\").append(inStr.charAt(i));
            }
            else {
                buff.append(inStr.charAt(i));
            }
        }
        return buff.toString();
    }
}
