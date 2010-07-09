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

package com.redhat.rhn.frontend.struts;

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.log4j.Logger;
import org.apache.struts.util.MessageResources;
import org.apache.struts.util.MessageResourcesFactory;

import java.util.Locale;

/**
 * XmlMessageResources - Class that extends Strut's mechanisms
 * for providing localized text for the HTML frontend.  This
 * class fetches messages from RHN's
 * {@link com.redhat.rhn.common.localization.LocalizationService LocalizationService}:
 * Any calls within RHN's web UI frontend will need to have
 * corresponding keys in the XML resources file used by
 * LocalizationService.
 *
 * @version $Rev$
 */

public class XmlMessageResources extends MessageResources  {

    private static Logger log = Logger.getLogger(XmlMessageResources.class);

    /**
     * Construct a new XmlMessageResources according to the specified parameters.
     * @param factory The MessageResourcesFactory that created us
     * @param config The configuration parameter for this MessageResources
     */
    public XmlMessageResources(MessageResourcesFactory factory,
                                    String config) {

        super(factory, config);
        log.info("Initializing, config='" + config + "'");

    }

    /**
     * Construct a new XmlMessageResources according to the specified parameters.
     * @param factory The MessageResourcesFactory that created us
     * @param config The configuration parameter for this MessageResources
     * @param returnNull The returnNull property we should initialize with
     */
    public XmlMessageResources(MessageResourcesFactory factory,
                                    String config, boolean returnNull) {

        super(factory, config, returnNull);
        log.info("Initializing, config='" + config +
                 "', returnNull=" + returnNull);

    }

    /** {@inheritDoc} */
    public String getMessage(Locale locale, String key) {
        if (log.isDebugEnabled()) {
            log.debug("getMessage() : locale (ignored): " + locale + " key: " + key);
        }
        // Force the LocalizationService to determine the Locale vs
        // letting what Struts thinks is the Locale be used.  Notice
        // how we call getMessage with *just* the key because we want
        // the L10NService to figure out the Locale.  I made
        // this change because even if you configure your browser to send
        // de_DE struts didn't seem to pick this up and ended up still sending
        // en_US.  Also, if we want to centralize the logic and have the LS
        // also check something like an actual setting associated with the User
        // then this would be required as well.
        this.formats.clear();
        return LocalizationService.getInstance().getMessage(key);
    }

}

