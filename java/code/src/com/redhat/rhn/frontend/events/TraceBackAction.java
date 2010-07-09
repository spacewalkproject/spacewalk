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

package com.redhat.rhn.frontend.events;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.MessageAction;
import com.redhat.rhn.common.messaging.MessageExecuteException;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;

import java.net.InetAddress;
import java.util.Date;

/**
 * Implement Action for TraceBackEvents
 *
 * @version $Rev$
 */
public class TraceBackAction extends BaseMailAction implements MessageAction {

    private static Logger log = Logger.getLogger(TraceBackAction.class);

    protected String getSubject(BaseEvent evtIn) {
        // setup subject
        StringBuffer subject = new StringBuffer();
        subject.append(LocalizationService.getInstance().
                getMessage("web traceback subject", evtIn.getUserLocale()));
        // Not sure if getting the local hostname is the correct thing to do
        // here.  But the traceback emails that I've received seem to do this
        try {
            subject.append(InetAddress.getLocalHost().getHostName());
        }
        catch (java.net.UnknownHostException uhe) {
            String message = "TraceBackAction can't find localhost!";
            log.warn(message);
            throw new MessageExecuteException(message);
        }
        subject.append(" (");
        subject.append(LocalizationService.getInstance().formatDate(new Date(),
                evtIn.getUserLocale()));
        subject.append(")");
        return subject.toString();
    }

    protected String[] getRecipients(User userIn) {
        Config c = Config.get();
        String[] retval = null;
        if (c.getString("web.traceback_mail").equals("")) {

            retval = new String[1];
            retval[0] = "root@localhost";
        }
        else {
            retval = c.getStringArray("web.traceback_mail");
        }
        return retval;
    }

}
