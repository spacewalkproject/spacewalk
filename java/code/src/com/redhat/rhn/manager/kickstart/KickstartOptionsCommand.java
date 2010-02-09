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

import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartCommandName;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.kickstart.KickstartOptionValue;

import org.apache.log4j.Logger;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * KickstartDetailsCommand
 * @version $Rev$
 */
public class KickstartOptionsCommand  extends BaseKickstartCommand {
       
    
    private static Logger log = Logger.getLogger(KickstartOptionsCommand.class);
    
    private List<KickstartCommandName> availableOptions;           
    private List requiredOptions;
    
    /**
     * 
     * @param ksid Kickstart Id 
     * @param userIn Logged in User
     */
    public KickstartOptionsCommand(Long ksid, User userIn) {
        super(ksid, userIn);
        this.availableOptions = KickstartFactory.lookupKickstartCommandNames(this.ksdata);
        this.requiredOptions = KickstartFactory.lookupKickstartRequiredOptions();       
    }

    /**
     * 
     * @return List of advanced command options
     */
    public List getAvailableOptions() {
        return this.availableOptions;
    }       
    
    /**
     * 
     * @return l List of advanced option commands to display to user
     */
    public List<KickstartOptionValue> getDisplayOptions() {
        log.debug("getDisplayOptions()");
        
        List<KickstartOptionValue> l = new LinkedList<KickstartOptionValue>();
        Set<KickstartCommand> options = this.ksdata.getOptions();        
        
        for (KickstartCommandName cn : availableOptions) {
            
            log.debug("avail commandname: " + cn.getName());
            
            String name = cn.getName();
            boolean added = false;
            for (KickstartCommand c : options) {
                if (c.getCommandName().getName().equals(name)) {
                    added = true;
                    KickstartOptionValue v = new KickstartOptionValue();
                    v.setName(name);
                    v.setHasArgs(cn.getArgs());
                    v.setRequired(cn.getRequired());
                    
                    String args = c.getArguments();
                    log.debug("   args = " + args);
                    
                    // Default URL's are stored as a path, not a full URL. Because we store
                    // the value directly back in the db we still must render just /path
                    // here, so display a note informing the user of the situation.
                    if (name.equals("url")) {
                        v.setAdditionalNotesKey("kickstart.options.url.note");
                    }
                    
                    v.setArg(args);
                    v.setEnabled(Boolean.TRUE);
                    l.add(v);
                }
            }
            // Add the default value since we don't have one specified.
            if (!added) {
                KickstartOptionValue v = new KickstartOptionValue();
                v.setName(name);
                v.setHasArgs(cn.getArgs());
                v.setRequired(cn.getRequired());
                l.add(v);
            }
            
        }                        
        return l;
    }
    
    /**
     * 
     * @param mapIn the request param map 
     * @return new display list of values for ui
     */
    public List refreshOptions(Map mapIn) {
        List l = new LinkedList();
        
        for (Iterator itr = availableOptions.iterator(); itr.hasNext();) {
            KickstartCommandName cn = (KickstartCommandName) itr.next();
            String name = cn.getName();
            KickstartOptionValue v = new KickstartOptionValue();
            v.setHasArgs(cn.getArgs());
            v.setName(name);
            v.setRequired(cn.getRequired());
            v.setEnabled(Boolean.valueOf(mapIn.containsKey(name)));
            
            String [] s = (String[])mapIn.get(name + "_txt");            
            if ((s != null) && (v.getEnabled().booleanValue())) {
                v.setArg(s[0]);
            }
           
            l.add(v);
        }        
        return l;
    }            

    /**
     * 
     * @return List of required options 
     */
    public List getRequiredOptions() {
        return requiredOptions;
    }

}
