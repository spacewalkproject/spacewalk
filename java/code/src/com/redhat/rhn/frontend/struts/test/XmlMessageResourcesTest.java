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
package com.redhat.rhn.frontend.struts.test;

import com.redhat.rhn.frontend.struts.XmlMessageResources;
import com.redhat.rhn.frontend.struts.XmlMessageResourcesFactory;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * XmlMessageResourcesTest - test the Struts compliant wrapper around our 
 * LocalizationService so we can utilize XML based MessageResources.
 * 
 * @version $Rev$
 */
public class XmlMessageResourcesTest extends RhnBaseTestCase {
    
    public void testGetFactory() {
        XmlMessageResources msg = (XmlMessageResources) 
            XmlMessageResourcesFactory.createFactory().createResources(null);
        assertNotNull(msg);
        assertNotNull(msg.getMessage(java.util.Locale.US, "errors.suffix"));
    }
}

