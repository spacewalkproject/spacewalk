/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

/**
 *
 * ErrataOverviewSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *      #struct("kickstart script")
 *          #prop("int", "id")
 *          #prop("string", "name")
 *          #prop("string", "contents")
 *          #prop_desc("string", "script_type", "Which type of script ('pre' or 'post').")
 *          #prop_desc("string", "interpreter", "The scripting language interpreter to use
 *                      for this script.  An empty string indicates the default kickstart
 *                      shell.")
 *          #prop_desc("boolean", "chroot", "True if the script will be executed within the
 *                  chroot environment.")
 *          #prop_desc("boolean", "erroronfail", "True if the script will throw an error if
 *                  it fails.")
 *          #prop_desc("boolean", "template", "True if templating using cobbler is enabled")
 *          #prop_desc("boolean", "beforeRegistration", "True if script will run before the
 *                  server registers and performs server actions.")
 *     #struct_end()
 */
public class KickstartScriptSerializer extends RhnXmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return KickstartScript.class;
    }

    /**
     * {@inheritDoc}
     */
    protected void doSerialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {

        KickstartScript script = (KickstartScript) value;
        SerializerHelper helper = new SerializerHelper(serializer);

        helper.add("id", script.getId());
        helper.add("name", script.getScriptName());
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

        helper.add("erroronfail", script.getErrorOnFail());

        helper.add("template", !script.getRaw());

        helper.add(
                "beforeRegistration",
                script.getScriptType().equals(KickstartScript.TYPE_PRE) ||
                        script.getPosition() < 0L);

        helper.writeTo(output);
    }
}
