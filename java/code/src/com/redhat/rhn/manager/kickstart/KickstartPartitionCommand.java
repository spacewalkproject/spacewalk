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
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartCommandName;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;

/**
 * KickstartPrePostCommand - for editing the pre and post steps
 * in a kickstart.
 * @version $Rev$
 */
public class KickstartPartitionCommand extends BaseKickstartCommand {
    
    private static Logger log = Logger.getLogger(KickstartPartitionCommand.class);
    
    private static final String SWAP = "swap";
    private static final String LVMSWAP = "swap.";
    private static final String SPACE = " ";
    private static final String NEWLINE = "\n";
    private static final String WHITESPACE = "\\s";
    private static final String RAID = "raid";
    private static final String RAIDS = "raids";
    private static final String PARTITIONS = "partitions";
    private static final String PARTITION = "partition";
    private static final String LOGVOLS = "logvols";
    private static final String LOGVOL = "logvol";    
    private static final String INCLUDE = "include";
    private static final String VOLGROUPS = "volgroups";
    private static final String VOLGROUP = "volgroup";
    private static final String CUSTOM_PARTITION = "custom_partition";
    private static final String EMPTY_STRING = "";
    
    private KickstartCommandName raidName;
    private KickstartCommandName partitionName;
    private KickstartCommandName logVolName;
    private KickstartCommandName includeName;
    private KickstartCommandName volGroupName;
    private KickstartCommandName custom;
    
    private LinkedHashMap partitions = new LinkedHashMap(Collections.EMPTY_MAP);
    private LinkedHashMap includes = new LinkedHashMap(Collections.EMPTY_MAP);
    private LinkedHashMap logvols = new LinkedHashMap(Collections.EMPTY_MAP);
    private LinkedHashMap volgroups = new LinkedHashMap(Collections.EMPTY_MAP);
    private LinkedHashMap raids = new LinkedHashMap(Collections.EMPTY_MAP);
    
    private List partitionSet = new ArrayList();
    private Set includeSet = new HashSet();
    private Set logvolSet = new HashSet();
    private Set volGroupSet = new HashSet();
    private Set raidSet = new HashSet();
    private Set customSet = new HashSet();
    
    private int partSwaps = 0;
    private int raidSwaps = 0;
    
    /**
     * Constructor
     * @param ksidIn id of the Kickstart to lookup
     * @param userIn userIn who owns the Kickstart
     */
    public KickstartPartitionCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
        raidName = KickstartFactory.lookupKickstartCommandName(RAIDS);
        partitionName = KickstartFactory.lookupKickstartCommandName(PARTITIONS);
        logVolName = KickstartFactory.lookupKickstartCommandName(LOGVOLS);
        includeName = KickstartFactory.lookupKickstartCommandName(INCLUDE);
        volGroupName = KickstartFactory.lookupKickstartCommandName(VOLGROUPS);
        custom = KickstartFactory.lookupKickstartCommandName(CUSTOM_PARTITION);
        if (custom == null) {
            custom = KickstartFactory.createCustomPartCommandName();
        }
    }
    
    /**
     * 
     * @return String representation of partition information
     */                    
    public String populatePartitions() {
        StringBuffer buf = new StringBuffer(); 
        // order listed in RHEL System Admin Guide
        // /docs/manuals/enterprise/RHEL-4-Manual/sysadmin-guide/s1-kickstart2-options.html
        buf.append(getPartition(this.ksdata.getPartitions(), PARTITION));
        buf.append(getPartition(this.ksdata.getRaids(), RAID));                
        buf.append(getPartition(this.ksdata.getVolgroups(), VOLGROUP));
        buf.append(getPartition(this.ksdata.getLogvols(), LOGVOL));
        buf.append(getPartition(this.ksdata.getIncludes(), "%" + INCLUDE));        
        buf.append(getPartition(this.ksdata.getCustomPartitionOptions(),
                CUSTOM_PARTITION));
        return buf.toString();
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
                else {
                    handleCustom(token);
                }
            }
            catch (ParseException e) {
                return new ValidatorError("kickstart.partition.duplicate", key);
            }
        }
        
        ksdata.setLogvols(logvolSet);
        ksdata.setVolgroups(volGroupSet);
        ksdata.setPartitions(partitionSet);
        ksdata.setIncludes(includeSet);
        ksdata.setRaids(raidSet);
        ksdata.setCustomPartitionOptions(customSet);
        return null;
    }
    

    private void handleCustom(String token) {
        KickstartCommand ksCommand = new KickstartCommand();
        ksCommand.setCommandName(custom);
        ksCommand.setCreated(new Date());
        ksCommand.setModified(ksCommand.getCreated());
        ksCommand.setArguments(token);
        ksCommand.setKickstartData(this.ksdata);
        customSet.add(ksCommand);
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
        KickstartCommand ksCommand = new KickstartCommand();
        ksCommand.setCommandName(partitionName);
        ksCommand.setCreated(new Date());
        ksCommand.setModified(ksCommand.getCreated());
        ksCommand.setArguments(partIn);
        ksCommand.setKickstartData(this.ksdata);
        partitionSet.add(ksCommand);
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
        KickstartCommand ksCommand = new KickstartCommand();
        ksCommand.setCommandName(includeName);
        ksCommand.setCreated(new Date());
        ksCommand.setModified(ksCommand.getCreated());
        ksCommand.setArguments(includeIn);
        ksCommand.setKickstartData(this.ksdata);
        includeSet.add(ksCommand);        
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
        KickstartCommand ksCommand = new KickstartCommand();
        ksCommand.setCommandName(logVolName);
        ksCommand.setCreated(new Date());
        ksCommand.setModified(ksCommand.getCreated());
        ksCommand.setArguments(logvolIn);
        ksCommand.setKickstartData(this.ksdata);
        logvolSet.add(ksCommand);        
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
        KickstartCommand ksCommand = new KickstartCommand();
        ksCommand.setCommandName(raidName);
        ksCommand.setCreated(new Date());
        ksCommand.setModified(ksCommand.getCreated());
        ksCommand.setArguments(raidIn);
        ksCommand.setKickstartData(this.ksdata);
        raidSet.add(ksCommand);        
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
        KickstartCommand ksCommand = new KickstartCommand();
        ksCommand.setCommandName(volGroupName);
        ksCommand.setCreated(new Date());
        ksCommand.setModified(ksCommand.getCreated());
        ksCommand.setArguments(volgroupIn);
        ksCommand.setKickstartData(this.ksdata);
        volGroupSet.add(ksCommand);        
    }
                
    /**
     * 
     * @param setIn Set of Kickstart Commands
     * @param prefixIn The Command name prefix
     * @return StringBuffer representation of partition info
     */
    private StringBuffer getPartition(Collection setIn, String prefixIn) {
        
        StringBuffer retval = new StringBuffer();
        
        if (setIn.size() == 0) {
            return retval;
        }
                        
        for (Iterator itr = setIn.iterator(); itr.hasNext();) {
           KickstartCommand c = (KickstartCommand)itr.next();
           String args = c.getArguments();

           if (!prefixIn.equals(CUSTOM_PARTITION)) {
               retval.append(prefixIn + SPACE);
           }

           // check legacy perl hack (e.g. swap1...swapN)
           if (args.startsWith(SWAP) && !args.startsWith(LVMSWAP)) {
              String[] tmp = args.split(WHITESPACE);
              tmp[0] = SWAP;              
              retval.append(StringUtils.join(tmp, SPACE));
           }
           else {
               retval.append(args);
           }
           retval.append(NEWLINE);
        }
        retval.append(NEWLINE);
        return retval;                    
    }                
}
