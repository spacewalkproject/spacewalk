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

import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * 
 * ErrataOverviewSerializer
 * @version $Rev$
 * @xmlrpc.doc
 *     #struct("errata")
 *          #prop_desc("int", "id", "Errata ID.")
 *          #prop_desc("string", "date", "Date erratum was created.")
 *          #prop_desc("string", "advisory_synopsis", "Summary of the erratum.")
 *          #prop_desc("string", "advisory_type", "Type label such as Security, Bug Fix")
 *          #prop_desc("string", "advisory_name", "Name such as RHSA, etc")
 *      #struct_end()
 */
public class ErrataOverviewSerializer implements XmlRpcCustomSerializer {

    /**
     * 
     * {@inheritDoc}
     */
    public Class getSupportedClass() {        
        return ErrataOverview.class;
    }

    /**
     * 
     * {@inheritDoc}
     * @throws IOException 
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        
        ErrataOverview errata = (ErrataOverview) value;        
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("id", errata.getId());
        helper.add("date", errata.getUpdateDate());
        helper.add("advisory_synopsis", errata.getAdvisorySynopsis());
        helper.add("advisory_type", errata.getAdvisoryType());
        helper.add("advisory_name", errata.getAdvisoryName());
        helper.writeTo(output);
    }

}
