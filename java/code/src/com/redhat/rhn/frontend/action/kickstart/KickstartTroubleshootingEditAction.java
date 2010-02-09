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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.KickstartTroubleshootingCommand;

import org.apache.commons.lang.BooleanUtils;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashMap;

import javax.servlet.http.HttpServletRequest;

/**
 * Handles display and update of Kickstart -> System Details -> Troubleshooting
 * 
 * @version $Rev $
 */
public class KickstartTroubleshootingEditAction extends BaseKickstartEditAction {

    public static final String BOOTLOADER_OPTIONS = "bootloaders";
    public static final String KERNEL_PARAMS = "kernelParams";
    public static final String BOOTLOADER = "bootloader";
    public static final String UPDATE_METHOD
        = "kickstart.troubleshooting.jsp.updatekickstart";
    public static final String NONCHROOTPOST = "nonChrootPost";
    public static final String VERBOSEUP2DATE = "verboseUp2date";

    /**
     * 
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx, DynaActionForm form, 
            BaseKickstartCommand cmdIn) {
        KickstartTroubleshootingCommand cmd = (KickstartTroubleshootingCommand) cmdIn;

        ArrayList bootloaders = getBootLoaders(cmd);
        ctx.getRequest().setAttribute(BOOTLOADER_OPTIONS, bootloaders);

        form.set(BOOTLOADER, cmd.getBootloaderType());
        form.set(KERNEL_PARAMS, cmd.getKernelParams());
        form.set(NONCHROOTPOST, cmd.getNonChrootPost());
        form.set(VERBOSEUP2DATE, cmd.getVerboseUp2date());
    }

    /**
     * 
     * {@inheritDoc}
     */
    protected ValidatorError processFormValues(HttpServletRequest request,
            DynaActionForm form, 
            BaseKickstartCommand cmd) {

        ValidatorError retval = null;

        KickstartTroubleshootingCommand tscmd = (KickstartTroubleshootingCommand) cmd;
        tscmd.setBootloaderType(form.getString(BOOTLOADER));

        String kernelParams = form.getString(KERNEL_PARAMS);
        if (kernelParams.length() > 128) {
            retval = new ValidatorError("kickstart.troubleshooting." +
                                        "validation.kernelparams.too_long");
        }

        tscmd.setKernelParams(form.getString(KERNEL_PARAMS));

        tscmd.getKickstartData().setNonChrootPost(
                BooleanUtils.toBoolean((Boolean) form.get(NONCHROOTPOST)));

        tscmd.getKickstartData().setVerboseUp2date(
                BooleanUtils.toBoolean((Boolean) form.get(VERBOSEUP2DATE)));

        return retval;
    }

    /**
     * 
     * {@inheritDoc}
     */
    protected String getSuccessKey() {
        return "kickstart.troubleshooting.success";
    }

    /**
     * 
     * {@inheritDoc}
     */
    protected BaseKickstartCommand getCommand(RequestContext ctx) {
        return new KickstartTroubleshootingCommand(
                ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                ctx.getCurrentUser());
    }

    /**
     * Returns formatted and ordered list of bootloaders. (Just GRUB
     * and LILO for the forseeable future)
     * @return List of bootloaders.
     */
    private ArrayList getBootLoaders(KickstartTroubleshootingCommand cmd) {
        /* return [ { display => "GRUB", value => "grub" },
                    { display => "LILO", value => "lilo " },
                  ];
        */

        HashMap grub = new HashMap();
        grub.put("display", "GRUB");
        grub.put("value", "grub");

        ArrayList displayList = new ArrayList();

        displayList.add(grub);
        if (!cmd.getKickstartData().isRhel5OrGreater()) {
            HashMap lilo = new HashMap();
            lilo.put("display", "LILO");
            lilo.put("value", "lilo");

            displayList.add(lilo);
        }

        return displayList;
    }
   
}
