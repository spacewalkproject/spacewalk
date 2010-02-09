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
package com.redhat.rhn.domain.action.config;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.action.ActionFormatter;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;

import org.apache.commons.lang.StringEscapeUtils;

import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

/**
 * ConfigActionFormatter
 * @version $Rev$
 */
public class ConfigActionFormatter extends ActionFormatter {
    
    
    /**
     * Create a new config action formatter
     * @param actionIn The action.
     */
    public ConfigActionFormatter(ConfigAction actionIn) {
        super(actionIn);
    }
    
    /**
     * Creates an html display for the config action notes.
     * Shows a single revision per line.
     * @return The html notes string 
     */
    protected String getNotesBody() {
        StringBuffer buffy = new StringBuffer();
        ConfigAction action = (ConfigAction)getAction();
        Iterator configs = action.getConfigRevisionActions().iterator();
        
        //There could (and most likely will be) multiple config revision actions per
        // revision (one per system).  Therefore, we will keep track of ones we have
        // already displayed.
        Set dealtWith = new HashSet();
        while (configs.hasNext()) {
            ConfigRevision revision =
                ((ConfigRevisionAction) configs.next()).getConfigRevision();
            if (!dealtWith.contains(revision.getId())) {
                buffy.append(displayRevision(revision));
                dealtWith.add(revision.getId());
            }
        }
        
        return buffy.toString();
    }
    
    private String displayRevision(ConfigRevision revision) {
        ConfigFile file = revision.getConfigFile();
        StringBuffer buffy = new StringBuffer();
        Object[] args = new Object[5];
        args[0] = "/rhn/configuration/file/FileDetails.do?cfid=" + file.getId() +
            "&crid=" + revision.getId();
        args[1] = revision.getRevision();
        args[2] = StringEscapeUtils.escapeHtml(file.getConfigFileName().getPath());
        args[3] = "/rhn/configuration/ChannelOverview.do?ccid=" +
            file.getConfigChannel().getId();
        args[4] = file.getConfigChannel().getName();
        buffy.append(LocalizationService.getInstance()
                .getMessage("config.actionnote", args));
        
        buffy.append("<br />");
        return buffy.toString();
    }

}
