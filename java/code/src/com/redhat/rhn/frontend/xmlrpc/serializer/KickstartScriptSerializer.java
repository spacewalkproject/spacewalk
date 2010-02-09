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

import com.redhat.rhn.domain.kickstart.KickstartScript;
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
 * 
 * @xmlrpc.doc
 *      #struct("kickstart script")
 *          #prop("int", "id")
 *          #prop("string", "contents")
 *          #prop_desc("string", "script_type", "Which type of script ('pre' or 'post').")
 *          #prop_desc("string", "interpreter", "The scripting language interpreter to use 
 *                      for this script.  An empty string indicates the default kickstart 
 *                      shell.")
 *          #prop_desc("boolean", "chroot", "True if the script will be executed within the 
 *                  chroot environment.")                      
 *     #struct_end()
 */
public class KickstartScriptSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {        
        return KickstartScript.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        
        KickstartScript script = (KickstartScript) value;        
        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("id", script.getId());
        helper.add("contents", script.getDataContents());
        helper.add("script_type", script.getScriptType());
        
        if (script.getInterpreter() == null) {
            helper.add("interpreter", "");
        }
        else {
            helper.add("interpreter", script.getInterpreter());
        }
        
        if (script.getChroot().equals("Y")) {
            helper.add("chroot", true);
        }
        else {
            helper.add("chroot", false);
        }
        
        helper.writeTo(output);
    }
}
