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
package com.redhat.rhn.frontend.dto.kickstart;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.dto.BaseDto;

import org.apache.commons.lang.StringUtils;

/**
 * DTO for a com.redhat.rhn.domain.kickstart.KickStartScript
 * @version $Rev: 50942 $
 */
public class ScriptDto extends BaseDto {

    private Long id;
    private String scriptType;
    private String chroot;
    private String interpreter;
    private int position;
    private static final String BASH = "bash";
    private static final String PRE = "Pre";
    private static final String POST = "Post";
    private static final String CHROOTPOST = "Nochroot Post";

    /**
     *
     * @return chroot
     */
    public String getChroot() {
        return chroot;
    }

    /**
     *
     * @param chrootIn to set
     */
    public void setChroot(String chrootIn) {
        this.chroot = chrootIn;
    }

    /**
     *
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }

    /**
     *
     * @param idIn to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     *
     * @return interpreter for this script
     */
    public String getInterpreter() {
        if (StringUtils.isBlank(interpreter)) {
            return BASH;
        }
        return interpreter;
    }

    /**
     *
     * @param interpreterIn to set
     */
    public void setInterpreter(String interpreterIn) {
        this.interpreter = interpreterIn;
    }

    /**
     *
     * @return script type for this script
     */
    public String getScriptType() {
        if (scriptType.equals("post")) {
            if (this.chroot.toLowerCase().equals("n")) {
                return CHROOTPOST;
            }
            else {
                return POST;
            }
        }
        else {
            return PRE;
        }
    }

    /**
     *
     * @param scriptTypeIn to set
     */
    public void setScriptType(String scriptTypeIn) {
        this.scriptType = scriptTypeIn;
    }

    /**
     *
     * @return position in listview
     */
    public String getPosition() {
        return LocalizationService.getInstance().formatNumber(new Integer(position));
    }

    /**
     *
     * @param positionIn to set
     */
    public void setPosition(int positionIn) {
        this.position = positionIn;
    }

}
