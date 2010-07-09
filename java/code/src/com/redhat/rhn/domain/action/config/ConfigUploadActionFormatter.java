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
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.frontend.html.HtmlTag;

import org.apache.commons.lang.StringEscapeUtils;

import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;


/**
 * ConfigUploadActionFormatter
 * @version $Rev$
 */
public class ConfigUploadActionFormatter extends ActionFormatter {

    /**
     * Create a new config upload action formatter
     * @param actionIn The action.
     */
    public ConfigUploadActionFormatter(ConfigUploadAction actionIn) {
        super(actionIn);
    }

    /**
     * Creates an html display for the config upload action notes.
     * Shows the destination channels followed by the filenames.
     * @return The html notes string
     */
    protected String getNotesBody() {
        StringBuffer buffy = new StringBuffer();
        ConfigUploadAction action = (ConfigUploadAction)getAction();

        /* display the list of destination config channels and then
         * the list of config file names. These aren't exactly mutually
         * exclusive lists; some filenames could go to certain channels
         * and not others, but it would be difficult to show those
         * relationships, it can't happen scheduled from the web UI,
         * and these really are *just* notes.
         */
        displayChannels(buffy, action.getRhnActionConfigChannel());
        displayFileNames(buffy, action.getRhnActionConfigFileName());
        return buffy.toString();
    }

    private String renderChannel(ConfigChannel channel) {
        HtmlTag a = new HtmlTag("a");
        a.setAttribute("href", "/rhn/configuration/ChannelOverview.do?ccid=" +
                channel.getId().toString());
        a.addBody(StringEscapeUtils.escapeHtml(channel.getDisplayName()));
        return a.render();
    }

    private String renderHeading(String transKey) {
        HtmlTag strong = new HtmlTag("strong");
        strong.addBody(LocalizationService.getInstance()
                .getMessage(transKey));
        return (strong.render() + "<br />");
    }

    private String renderFileName(ConfigFileName name) {
        //paths can have pretty much any character including newlines,
        //spaces, and control characters. Escaping html here is only
        //going to work happily for file names that make some kind of sense.
        return (StringEscapeUtils.escapeHtml(name.getPath()) + "<br />");
    }

    private void displayChannels(StringBuffer buffy, Set channelSet) {
        /* most of the time, there is only going to be one channel because it
         * will usually be one server's sandbox channel.
         * Therefore, deal with one channel as a special case
         * I say this because as I write this, there is no way through the web UI
         * to schedule a config upload action for multiple servers.
         */
        if (channelSet.size() == 1) {
            ConfigChannel channel = ((ConfigChannelAssociation)
                    channelSet.toArray()[0]).getConfigChannel();

            //Display will be:
            //Destination Configuration Channel: blah
            //where blah is the channel display name with link

            buffy.append(LocalizationService.getInstance()
                    .getMessage("config.upload.onechannel", renderChannel(channel)));
            buffy.append("<br />");
        }
        else if (channelSet.size() > 1) {

            buffy.append(renderHeading("config.upload.channels"));

            Iterator channels = channelSet.iterator();
            //since you can only upload files into local channels (only sandbox right now),
            //there shouldn't be multiple entries of the same channel.
            while (channels.hasNext()) {
                ConfigChannel channel = ((ConfigChannelAssociation)
                        channels.next()).getConfigChannel();
                buffy.append(renderChannel(channel));
                buffy.append("<br />");
            }
        }
        //else don't display desination info (invalid config upload action!)
    }

    private void displayFileNames(StringBuffer buffy, Set fileNameSet) {
        buffy.append(renderHeading("config.upload.filenames"));

        //There could be multiple config file name actions per file name
        //(one per system).  Therefore, we will keep track of ones we have
        // already displayed.
        Set dealtWith = new HashSet();
        Iterator filenames = fileNameSet.iterator();
        while (filenames.hasNext()) {
            ConfigFileName path =
                ((ConfigFileNameAssociation) filenames.next()).getConfigFileName();
            if (!dealtWith.contains(path.getId())) {
                buffy.append(renderFileName(path));
                dealtWith.add(path.getId());
            }
        }
    }

}
