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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.text.ParseException;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.StringTokenizer;

/**
 * KickstartPrePostCommand - for editing the pre and post steps
 * in a kickstart.
 * @version $Rev$
 */
public class KickstartPartitionCommand extends BaseKickstartCommand {

    private static Logger log = Logger.getLogger(KickstartPartitionCommand.class);

    private static final String SWAP = "swap";
    private static final String SPACE = " ";
    private static final String NEWLINE = "\n";
    private static final String WHITESPACE = "\\s";
    private static final String RAID = "raid";
    private static final String LOGVOL = "logvol";
    private static final String INCLUDE = "include";
    private static final String VOLGROUP = "volgroup";
    private static final String EMPTY_STRING = "";


    private LinkedHashMap partitions = new LinkedHashMap(Collections.EMPTY_MAP);
    private LinkedHashMap includes = new LinkedHashMap(Collections.EMPTY_MAP);
    private LinkedHashMap logvols = new LinkedHashMap(Collections.EMPTY_MAP);
    private LinkedHashMap volgroups = new LinkedHashMap(Collections.EMPTY_MAP);
    private LinkedHashMap raids = new LinkedHashMap(Collections.EMPTY_MAP);

    private int partSwaps = 0;
    private int raidSwaps = 0;
    /**
     * Constructor
     * @param ksidIn id of the Kickstart to lookup
     * @param userIn userIn who owns the Kickstart
     */
    public KickstartPartitionCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
    }

    /**
     *
     * @param partitionsIn String from dynaform
     * @return ValidatorError if validation error exists
     */
    public ValidatorError parsePartitions(String partitionsIn) {
        if (log.isDebugEnabled()) {
            log.debug("parsePartitions() : partitionsIn: " + partitionsIn);
        }
        for (StringTokenizer strtok = new StringTokenizer(partitionsIn, NEWLINE); strtok
                .hasMoreTokens();) {
            String token = strtok.nextToken();
            if (token == null || token.length() == 0) {
                continue;
            }
            String[] tokens = token.split(WHITESPACE);
            if (tokens == null || tokens.length == 0) {
                continue;
            }

            String key = "";
            if (tokens.length > 1) {
                key = tokens[1]; // mount point is the key
            }
            String stripped = StringUtils.trim(token.replaceFirst(tokens[0],
                    EMPTY_STRING));
            if (log.isDebugEnabled()) {
                log.debug("Token: " + token);
            }
            try {
                if (token.startsWith("part")) {
                    handlePartitions(key, stripped);
                }
                else if (token.startsWith(RAID)) {
                    handleRaids(key, stripped);
                }
                else if (token.startsWith(VOLGROUP)) {
                    handleVolGroups(key, stripped);
                }
                else if (token.startsWith("%" + INCLUDE) || token.startsWith(INCLUDE)) {
                    handleIncludes(key, stripped);
                }
                else if (token.startsWith(LOGVOL)) {
                    handleLogVols(key, stripped);
                }
            }
            catch (ParseException e) {
                return new ValidatorError("kickstart.partition.duplicate", key);
            }
        }
        ksdata.setPartitionData(partitionsIn);

        return null;
    }


    /**
     *
     * @param keyIn mount point coming in
     * @param partIn partition string coming in
     * @throws ParseException if we have duplicate mount points in the set
     */
    private void handlePartitions(String keyIn, String partIn) throws ParseException {
        // we can have multiple swaps...follow perl pattern of storing swap, swap1..swapN

        if (keyIn.startsWith(SWAP)) {
            if (partSwaps > 0) {
                partIn.replaceFirst(SWAP, SWAP + partSwaps);
                keyIn = SWAP + partSwaps;
            }
            partSwaps++;
        }
        else if (partitions.containsKey(keyIn)) {
            throw new ParseException(keyIn, 0);
        }
        partitions.put(keyIn, partIn);
    }

    /**
     *
     * @param keyIn mount point coming in
     * @param includeIn include string coming in
     * @throws ParseException if we have duplicate mount points in the set
     */
    private void handleIncludes(String keyIn, String includeIn) throws ParseException {
        if (includes.containsKey(keyIn)) {
            throw new ParseException(keyIn, 0);
        }
        includes.put(keyIn, includeIn);
    }

    /**
     *
     * @param keyIn mount point coming in
     * @param logvolIn string coming in
     * @throws ParseException if we have duplicate mount points in the set
     */
    private void handleLogVols(String keyIn, String logvolIn) throws ParseException {
        if (logvols.containsKey(keyIn)) {
            throw new ParseException(keyIn, 0);
        }
        logvols.put(keyIn, logvolIn);
    }

    /**
     *
     * @param keyIn mount point coming in
     * @param raidIn raid string coming in
     * @throws ParseException if we have duplicate mount points in the set
     */
    private void handleRaids(String keyIn, String raidIn) throws ParseException {
        // we can have multiple swaps...follow perl pattern of storing swap, swap1..swapN
        if (raidIn.startsWith(SWAP + SPACE)) {
            if (raidSwaps > 0) {
                raidIn.replaceFirst(SWAP, SWAP + raidSwaps);
                keyIn = SWAP + raidSwaps;
            }
            raidSwaps++;
        }
        else if (raids.containsKey(keyIn)) {
            throw new ParseException(keyIn, 0);
        }
        raids.put(keyIn, raidIn);
    }

    /**
     *
     * @param keyIn mount point coming in
     * @param volgroupIn volgroup coming in
     * @throws ParseException if we have duplicate mount points in the set
     */
    private void handleVolGroups(String keyIn, String volgroupIn) throws ParseException {
        if (volgroups.containsKey(keyIn)) {
            throw new ParseException(keyIn, 0);
        }
        volgroups.put(keyIn, volgroupIn);
    }
}
