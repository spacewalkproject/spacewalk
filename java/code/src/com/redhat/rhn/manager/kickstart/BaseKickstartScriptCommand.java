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

import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.io.UnsupportedEncodingException;

/**
 * KickstartScriptCommand
 * @version $Rev$
 */
public class BaseKickstartScriptCommand extends BaseKickstartCommand {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger
            .getLogger(BaseKickstartScriptCommand.class);


    protected KickstartScript script;

    /**
     * Constructor
     * @param ksidIn Kickstart Script id
     * @param userIn owner of script
     */
    public BaseKickstartScriptCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
    }


    /**
     * @return the script
     */
    public KickstartScript getScript() {
        return script;
    }

    /**
     * Set the contents and interpereter of the Script
     * @param language to use for the script
     * @param contentsIn of the script itself
     * @param typeIn of script (KickstartScript.TYPE_POST or KickstartScript.TYPE_PRE)
     * @param chrootIn value of chroot ("Y" or "N")
     * @param templatize whether to templatize the script or not
     */
    public void setScript(String language, String contentsIn,
                               String typeIn, String chrootIn, boolean templatize) {
        if (!typeIn.equals(KickstartScript.TYPE_POST) &&
                !typeIn.equals(KickstartScript.TYPE_PRE)) {
            throw new IllegalArgumentException("Unknown script type: " + typeIn);
        }

        try {
            this.script.setData(contentsIn.getBytes("UTF-8"));
        }
        catch (UnsupportedEncodingException e) {
            logger.error("setPreScript(String, String)", e);
            throw new RuntimeException("UnsupportedEncodingException" +
                    " while trying to set Pre script", e);

        }

        if (StringUtils.isBlank(language)) {
            language = null;
        }
        else {
            language = language.trim();
        }

        this.script.setInterpreter(language);
        this.script.setScriptType(typeIn);
        this.script.setChroot(chrootIn);
        this.script.setRaw(!templatize); //template is the ! of raw
    }

    /**
     * Get the contents of the Script as a String
     * @return String contents.
     */
    public String getContents() {
        return this.script.getDataContents();
    }

    /**
     * Get the interpereter or language used by this script
     * /usr/bin/perl, /bin/csh, etc..
     * @return String
     */
    public String getLanguage() {
        return this.script.getInterpreter();
    }

    /**
     * Get the type of Script this is.  See KickstartScript.TYPE_PRE, TYPE_POST.
     * Defaults to KickstartScript.TYPE_PRE
     *
     * @return String representation of the type.
     */
    public String getType() {
        if (this.script.getScriptType() != null) {
            return this.script.getScriptType();
        }
        else {
            return KickstartScript.TYPE_PRE;
        }
    }

    /**
     * gets whether the script is raw or not.
     * @return true or false
     */
    public boolean getRaw() {
        if (this.script != null) {
            return this.script.getRaw();
        }
        else {
            return true;
        }
    }

    /**
     * @return Boolean value that determines whether
     * or not the checkbox associated with nochroot
     * should be checked
     */
    public Boolean getNoChrootVal() {
       if (this.script.getChroot().equals("Y")) {
           return new Boolean(false);
       }
       return new Boolean(true);
    }
}
