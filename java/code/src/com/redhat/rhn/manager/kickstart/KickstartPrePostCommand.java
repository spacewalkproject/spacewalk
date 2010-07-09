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

import org.apache.log4j.Logger;

import java.io.UnsupportedEncodingException;
import java.util.Iterator;

/**
 * KickstartPrePostCommand - for editing the pre and post steps
 * in a kickstart.
 * @version $Rev$
 */
public class KickstartPrePostCommand extends BaseKickstartCommand {

    /**
     * Logger for this class
     */
    private static Logger logger = Logger
            .getLogger(KickstartPrePostCommand.class);

    /**
     * Constructor
     * @param ksidIn id of the Kickstart to lookup
     * @param userIn userIn who owns the Kickstart
     */
    public KickstartPrePostCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
    }

    /**
     * Set the contents of the pre script.
     * @param language or interpreter used
     * @param contentsIn of the actual script
     */
    public void setPreScript(String language, String contentsIn) {
        logger.debug("setPreScript(String language=" + language +
                ", String contentsIn=" + contentsIn + ") - start");

        setScript(language, contentsIn, KickstartScript.TYPE_PRE);
        logger.debug("setPreScript(String, String) - end");
    }

    /**
     * Set the contents of the post script.
     * @param language or interpreter used
     * @param contentsIn of the actual script
     */
    public void setPostScript(String language, String contentsIn) {
        logger.debug("setPostScript(String language=" + language +
                ", String contentsIn=" + contentsIn + ") - start");

        setScript(language, contentsIn, KickstartScript.TYPE_POST);
        logger.debug("setPostScript(String, String) - end");
    }


    /**
     * Set the contents of the pre script.
     * @param language or interpreter used
     * @param contentsIn of the actual script
     */
    private void setScript(String language, String contentsIn, String typeIn) {
        logger.debug("setPreScript(String language=" + language +
                ", String contentsIn=" + contentsIn + ") - start");

        try {
            if (language != null) {
                // Edit existing KickstartScript
                KickstartScript kss = null;
                if (typeIn.equals(KickstartScript.TYPE_PRE)) {
                    kss = ksdata.getPreKickstartScript();
                }
                else if (typeIn.equals(KickstartScript.TYPE_POST)) {
                    kss = ksdata.getPostKickstartScript();
                }
                else {
                    throw new IllegalArgumentException(
                            "Unknown KickstartScript type: " + typeIn);
                }

                if (kss != null) {
                    kss.setInterpreter(language);
                    kss.setData(contentsIn.getBytes("UTF-8"));
                }
                else {
                    // Add new one
                    addKickstartScript(language, contentsIn, typeIn);
                }
            }
            else {
                Iterator i = this.ksdata.getScripts().iterator();
                while (i.hasNext()) {
                    KickstartScript script = (KickstartScript) i.next();
                    if (script.getScriptType().equals(typeIn)) {
                        this.ksdata.getScripts().remove(script);
                    }
                }
                // this.ksdata.setPre(contentsIn.getBytes("UTF-8"));
            }
        }
        catch (UnsupportedEncodingException e) {
            logger.error("setPreScript(String, String)", e);
            throw new RuntimeException("UnsupportedEncodingException" +
                    " while trying to set Pre script", e);
        }
        logger.debug("setPreScript(String, String) - end");
    }


    private void addKickstartScript(String language, String contentsIn,
            String scriptTypeIn)
        throws UnsupportedEncodingException {
        KickstartScript kss = new KickstartScript();
        kss.setKsdata(ksdata);
        kss.setData(contentsIn.getBytes("UTF-8"));
        kss.setInterpreter(language);
        kss.setScriptType(scriptTypeIn);
        this.ksdata.addScript(kss);
    }


    /**
     * Get the language in use by the script.  The #!/bin/sh
     * at the top of the file.
     *
     * @return String of the language chosen
     */
    public String getPreLanguage() {
        KickstartScript kss = ksdata.getPreKickstartScript();
        if (kss != null) {
            return kss.getInterpreter();
        }
        else {
            return null;
        }
    }

    /**
     * Get the contents of the string.
     * @return String contents of the pre script
     */
    public String getPreContents() {
        KickstartScript kss = ksdata.getPreKickstartScript();
        if (kss != null) {
            return kss.getDataContents();
        }
        else {
            // return ksdata.getPreContents();
            return null;
        }
    }

    /**
     * Get the String version of the post script
     * @return String post script
     */
    public String getPostContents() {
        KickstartScript kss = ksdata.getPostKickstartScript();
        if (kss != null) {
            return kss.getDataContents();
        }
        else {
            // return ksdata.getPostContents();
            return null;
        }
    }

    /**
     * Get the interpreter used by the Post script
     * @return String of post interpereter
     */
    public String getPostLanguage() {
        KickstartScript kss = ksdata.getPostKickstartScript();
        if (kss != null) {
            return kss.getInterpreter();
        }
        else {
            return null;
        }
    }

}
