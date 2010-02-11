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
package com.redhat.rhn.frontend.xmlrpc.serializer;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * 
 * ErrataSerializer
 * @version $Rev$
 * 
 * @xmlrpc.doc
 *      #struct("errata")
 *          #prop_desc("int", "id", "Errata Id")
 *          #prop_desc("string", "date", "Date erratum was created.")
 *          #prop_desc("string", "advisory_type", "Type of the advisory.")
 *          #prop_desc("string", "advisory_name", "Name of the advisory.") 
 *          #prop_desc("string", "advisory_synopsis", "Summary of the erratum.")  
 *     #struct_end()
 */
public class ErrataSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {        
        return Errata.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        
        Errata errata = (Errata) value;        
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("id", errata.getId());

        // Short format of the date to match ErrataOverviewSerializer:
        helper.add("date", LocalizationService.getInstance().formatShortDate(
                    errata.getUpdateDate()));

        helper.add("advisory_synopsis", errata.getSynopsis());
        helper.add("advisory_name", errata.getAdvisoryName());
        helper.add("advisory_type", errata.getAdvisoryType());
        helper.writeTo(output);
    }
}
