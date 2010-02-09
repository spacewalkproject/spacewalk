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
import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.SmtpMail;
import com.redhat.rhn.domain.user.User;

/**
 * BaseMailAction - basic abstract class to encapsulate some common Action logic.
 * @version $Rev$
 */
public abstract class BaseMailAction {
    
    protected abstract String getSubject(BaseEvent evt);
    
    protected abstract String[] getRecipients(User user);
    
    /**
     * Execute the TraceBack
     * @param msg EventMessage to executed.
     */
    public void execute(EventMessage msg) {
        BaseEvent aevt = (BaseEvent) msg;
        Mail mailer = getMail();
        mailer.setRecipients(getRecipients(aevt.getUser()));
        mailer.setSubject(getSubject(aevt));
        mailer.setBody(msg.toText());
        mailer.send();
    }
    
    /**
    * Get the mailer associated with this class
    */
    protected Mail getMail() {
        String clazz = Config.get().getString(
                "web.mailer_class");
        if (clazz == null) {
            return new SmtpMail();
        }
        else {
            try {
                Class cobj = Class.forName(clazz);
                return (Mail) cobj.newInstance();
            }
            catch (Exception e) {
                return new SmtpMail();
            }
        }
    }


}
