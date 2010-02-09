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

import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartCommandName;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartDefaults;
import com.redhat.rhn.domain.kickstart.SELinuxMode;
import com.redhat.rhn.domain.user.User;

import java.util.Date;

/**
 * SystemDetailsCommand
 * 
 * @version $Rev $
 */
public class SystemDetailsCommand extends BaseKickstartCommand {
    /**
     * constructor
     * @param ksidIn kickstart id
     * @param userIn logged in user
     */
    public SystemDetailsCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
    }

    /**
     * constructor
     * Construct a command with a KSdata provided. 
     * @param data the kickstart data
     * @param userIn Logged in User
     */
    public SystemDetailsCommand(KickstartData data, User userIn) {
        super(data, userIn);
    }
    
    /**
     * Sets the se linux mode of the kick start profile.. 
     * @param mode the selinux mode enforcing/permissive/disabled 
     */
    public void setMode(SELinuxMode mode) {
        KickstartCommand cmd = new KickstartCommand();
        cmd.setCreated(new Date());
        cmd.setCommandName(findCommandName(KickstartData.SELINUX_MODE_COMMAND));
        cmd.setArguments("--" + mode.getValue());
        cmd.setKickstartData(ksdata);
        ksdata.removeCommand(KickstartData.SELINUX_MODE_COMMAND, false);
        ksdata.getCommands().add(cmd);
    }
    
    /**
     * Updates the root password in the network profile.
     * @param rootPw the new password
     * @param rootPwConfirm password confirmation ..
     */
    public void updateRootPassword(String rootPw, String rootPwConfirm) {
        validatePasswordChange(rootPw, rootPwConfirm);
        KickstartCommandName commandName = null;
        KickstartCommand cmd = null;
        if (rootPw != null && rootPw.length() > 0) {
            if (rootPw.equals(rootPwConfirm)) {
                ksdata.removeCommand("rootpw", true);
                commandName = findCommandName("rootpw");
                cmd = new KickstartCommand();
                cmd.setCreated(new Date());
                cmd.setKickstartData(ksdata);
                cmd.setCommandName(commandName);
                cmd.setArguments(MD5Crypt.crypt(rootPw));
                ksdata.getCommands().add(cmd);
            }
        }
    }
 
    private  void validatePasswordChange(String rootPw, String rootPwConfirm) {
        ValidatorResult vr = new ValidatorResult(); 
        int passwdMin = 1;
        if (rootPw == null || rootPw.length() == 0 || rootPwConfirm == null || 
                rootPwConfirm.length()  == 0) {
            vr.addError("kickstart.systemdetails.passwords.jsp.minerror");
        }
        else if (!rootPw.equals(rootPwConfirm)) {
            vr.addError("kickstart.systemdetails.root.password.jsp.error");
        }
        else if (rootPw.length() < passwdMin || rootPwConfirm.length() < passwdMin) {
            vr.addError("kickstart.systemdetails.passwords.jsp.minerror");
        }
        if (!vr.isEmpty()) {
            throw new ValidatorException(vr);
        }        
    }
    
    /**
     * Enables config management flag in this profile
     * @param enable true to enable config management, false to disable config mgmt  
     */
    public void enableConfigManagement(boolean enable) {
        KickstartDefaults defaults = ksdata.getKickstartDefaults();
        if (defaults == null) {
            defaults = new KickstartDefaults();
            defaults.setCreated(new Date());
        }
        defaults.setCfgManagementFlag(enable);
    }
    
    /**
     * Enables/Disables the ability to do remote commands in this profile
     * @param enable true to enable,  false to diable remote commands.  
     */
    public void enableRemoteCommands(boolean enable) {
        KickstartDefaults defaults = ksdata.getKickstartDefaults();
        if (defaults == null) {
            defaults = new KickstartDefaults();
            defaults.setCreated(new Date());
        }
        defaults.setRemoteCommandFlag(enable);        
    }  
}
