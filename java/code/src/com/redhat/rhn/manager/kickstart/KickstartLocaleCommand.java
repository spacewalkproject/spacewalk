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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartCommandName;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.TimezoneDto;

import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;

/**
 * KickstartLocaleCommand - for editing locale-related options
 * in a kickstart.
 * @version $Rev$
 */
public class KickstartLocaleCommand extends BaseKickstartCommand {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger
            .getLogger(KickstartLocaleCommand.class);

    /**
     * Constructor
     * @param ksidIn id of the Kickstart to lookup
     * @param userIn userIn who owns the Kickstart
     */
    public KickstartLocaleCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
    }

    /**
     * constructor
     * Construct a command with a KSdata provided. 
     * @param data the kickstart data
     * @param userIn Logged in User
     */
    public KickstartLocaleCommand(KickstartData data, User userIn) {
        super(data, userIn);
    }
    
    /**
     * Get the timezone from the KickstartData object
     *
     * @return timezone
     */
    public String getTimezone() {
        return getKickstartData().getTimezone();
    }

    /**
     * Set the timezone
     * @param timezoneIn The timezone
     */
    public void setTimezone(String timezoneIn) {
        logger.debug("setTimezone(String timezoneIn=" + timezoneIn +
                     ") - start");

        KickstartCommand timezoneCommand = getKickstartData().getCommand("timezone");

        if (timezoneCommand == null) {
            logger.debug("No timezone command yet.  Creating one.");

            timezoneCommand = this.makeTzCommand();
        }

        if (!this.getTimezone().equals(timezoneIn)) {
            logger.debug("Changing timezone from " + this.getTimezone() +
                         " to " + timezoneIn + ".");

            String current = this.getTimezone();

            String args = timezoneCommand.getArguments();
            LinkedList tokens = new LinkedList();

            if (args != null) {
                tokens = (LinkedList) StringUtil.stringToList(args);
                Iterator iter = tokens.iterator();
                while (iter.hasNext()) {
                    if (current.equals((String) iter.next())) {
                        iter.remove();
                    }
                }
            }

            tokens.add(timezoneIn);

            timezoneCommand.setArguments(StringUtil.join(" ", tokens));
            KickstartFactory.saveCommand(timezoneCommand);
        }

        logger.debug("setTimezone(String) - end");
    }

    /**
     * Get a list of valid timezones
     *
     * @return ArrayList of valid timeszones (HashMaps with display/value)
     */ 
    public ArrayList getValidTimezones() {
        DataResult dr = KickstartLister.getInstance()
            .getValidTimezones(getKickstartData().getId().toString());

        Iterator iter = dr.iterator();
        ArrayList ret = new ArrayList();

        while (iter.hasNext()) {
            TimezoneDto old = (TimezoneDto) iter.next();
            HashMap row = new HashMap();
            row.put("display", old.getName());
            row.put("value", old.getLabel());

            ret.add(row);
        }

        return ret;
    }

    /**
     * Determine if the timezone provided is valid for the current configuration.
     *
     * @param timezone The timezone to check
     * @return boolean true if timezone is valid; otherwise, false
     */ 
    public Boolean isValidTimezone(String timezone) {
        
        DataResult dr = KickstartLister.getInstance()
        .getValidTimezones(getKickstartData().getId().toString());

        Iterator iter = dr.iterator();
        while (iter.hasNext()) {
            TimezoneDto tz = (TimezoneDto) iter.next();
            if (tz.getLabel().equals(timezone)) {
                return Boolean.TRUE;
            }
        }
        return Boolean.FALSE;
    }
    
    /*
     * Make a 'timezone' command if one does not already exist
     * @param timezoneCommand The KickstartCommand object for timezone
     */
    private KickstartCommand makeTzCommand() {
        KickstartCommand timezoneCommand = new KickstartCommand();
        KickstartCommandName name =
            KickstartFactory.lookupKickstartCommandName("timezone");
        timezoneCommand.setCommandName(name);
        timezoneCommand.setCreated(new Date());
        timezoneCommand.setModified(new Date());

        timezoneCommand.setKickstartData(getKickstartData());
        getKickstartData().addCommand(timezoneCommand);

        return timezoneCommand;
    }

    /**
     * Will the system hardware clock use UTC
     *
     * @return Boolean Are we using UTC?
     */
    public Boolean isUsingUtc() {
        return getKickstartData().isUsingUtc();
    }
    
    /**
     * Add the --utc flag if it does not already exist in the kickstart's 'timezone' command
     *
     */
    public void useUtc() {
        logger.debug("useUtc() - start");

        this.doNotUseUtc(); // first make sure it is off

        KickstartCommand timezoneCommand = getKickstartData().getCommand("timezone");

        if (timezoneCommand == null) {
            logger.debug("No timezone command yet.  Creating one.");

            timezoneCommand = this.makeTzCommand();
        }

        String args = timezoneCommand.getArguments();
        LinkedList tokens = new LinkedList();
        
        if (args != null) {
            tokens = (LinkedList) StringUtil.stringToList(args);
        }

        tokens.add(0, "--utc");

        timezoneCommand.setArguments(StringUtil.join(" ", tokens));
        KickstartFactory.saveCommand(timezoneCommand);

        logger.debug("useUtc() - end");
    }

    /**
     * Remove the --utc flag
     *
     */
    public void doNotUseUtc() {
        logger.debug("doNotUseUtc() - start");
        KickstartCommand timezoneCommand = getKickstartData().getCommand("timezone");

        if (timezoneCommand == null) {
            logger.debug("No timezone command yet.  Creating one.");

            timezoneCommand = this.makeTzCommand();
        }

        String args = timezoneCommand.getArguments();
        LinkedList tokens = new LinkedList();
        
        if (args != null) {
            tokens = (LinkedList) StringUtil.stringToList(args);
        }

        Iterator iter = tokens.iterator();

        while (iter.hasNext()) {
            String current = (String) iter.next();
                
            if (current.equals("--utc")) {
                iter.remove();
            }
        }

        timezoneCommand.setArguments(StringUtil.join(" ", tokens));
        KickstartFactory.saveCommand(timezoneCommand);

        logger.debug("doNotUseUtc() - end");
    }
}
