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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;
import com.redhat.rhn.manager.kickstart.BaseKickstartScriptCommand;

import org.apache.struts.action.DynaActionForm;

import java.util.LinkedList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

/**
 * KickstartScriptCreateAction action for creating a new kickstart script
 * @version $Rev: 1 $
 */
public abstract class BaseKickstartScriptAction extends BaseKickstartEditAction {

    public static final String CONTENTS = "contents";
    public static final String LANGUAGE = "language";
    public static final String TYPE = "type";
    public static final String TYPES = "types";
    public static final String NOCHROOT = "nochroot";
    public static final String TEMPLATE = "template";


    /**
     * {@inheritDoc}
     */
    protected ValidatorError processFormValues(HttpServletRequest request,
            DynaActionForm form,
            BaseKickstartCommand cmd) {
        String chroot = "Y";
        Boolean b = new Boolean(true);

        Boolean template = false;
        if (form.get(TEMPLATE) != null) {
            template = (Boolean) form.get(TEMPLATE);
        }

        BaseKickstartScriptCommand kssc = (BaseKickstartScriptCommand) cmd;

        if (b.equals((Boolean)form.get(NOCHROOT))) {
            chroot = "N";
        }

        String scriptValue = getStrutsDelegate().getTextAreaValue(form, CONTENTS);
        int maxLength = Config.get().getInt("web.kickstart_script_max_length", 150000);

        if (scriptValue.length() == 0) {
            return new ValidatorError("kickstart.script.required");
        }
        else if (scriptValue.length() > maxLength) {
            return new ValidatorError("kickstart.script.toolarge",
                    LocalizationService.getInstance().formatNumber(new Long(maxLength)));
        }
        kssc.setScript(form.getString(LANGUAGE),
                scriptValue,
                form.getString(TYPE),
                chroot,
                template);
        return null;
    }

    /**
     * {@inheritDoc}
     */
    protected String getSuccessKey() {
        return "kickstart.script.success";
    }

    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx, DynaActionForm form,
            BaseKickstartCommand cmd) {
        List types = new LinkedList();
        types.add(lvl10n("kickstart.script.pre", KickstartScript.TYPE_PRE));
        types.add(lvl10n("kickstart.script.post", KickstartScript.TYPE_POST));
        ctx.getRequest().setAttribute(TYPES, types);

        BaseKickstartScriptCommand kssc = (BaseKickstartScriptCommand) cmd;
        form.set(CONTENTS, kssc.getContents());
        form.set(LANGUAGE, kssc.getLanguage());
        form.set(TYPE, kssc.getType());
        form.set(NOCHROOT, kssc.getNoChrootVal());
        form.set(TEMPLATE, !kssc.getScript().getRaw());
    }

    /**
     * {@inheritDoc}
     */
    protected String getSuccessForward() {
        return "success";
    }
}
