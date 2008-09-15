/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.common.cert;

import org.jdom.Element;
import org.jdom.JDOMException;

/**
 * An interface to describe how a field is to be extracted
 * from the DOM representation of the XML satellite certificate
 * @version $Rev$
 */
interface FieldExtractor {

    void extract(Certificate target, Element field) throws JDOMException;
    
    boolean isRequired();
    
    String getFieldName();
    
}
