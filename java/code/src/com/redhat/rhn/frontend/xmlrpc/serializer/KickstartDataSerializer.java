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

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * KickstartDataSerializer: Converts a KickstartData object for representation 
 * as an XMLRPC struct.
 * @version $Rev$
 *
 */
public class KickstartDataSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return KickstartData.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        KickstartData kd = (KickstartData)value;

        SerializerHelper helper = new SerializerHelper(builtInSerializer);

        helper.add("id", kd.getId());
        helper.add("org_id", kd.getOrg());
        helper.add("label", kd.getLabel());
        helper.add("comments", kd.getComments());
        helper.add("active", kd.isActive());
        helper.add("postLog", kd.getPostLog());
        helper.add("preLog", kd.getPreLog());
        helper.add("ksCfg", kd.getKsCfg());
        helper.add("created", kd.getCreated());
        helper.add("modified", kd.getModified());
        helper.add("isOrgDefault", kd.isOrgDefault());
        helper.add("kernelParams", kd.getKernelParams());
        helper.add("nonChrootPost", kd.getNonChrootPost());
        helper.add("verboseUp2date", kd.getVerboseUp2date());
        helper.add("packageNames", kd.getKsPackages());
        helper.add("commands", kd.getCommands());
        helper.add("defaultRegTokens", kd.getDefaultRegTokens());
        helper.add("ips", kd.getIps());
        helper.add("options", kd.getOptions());
        helper.add("customOptions", kd.getCustomOptions());
        helper.add("raids", kd.getRaids());
        helper.add("logvols", kd.getLogvols());
        helper.add("volgroups", kd.getVolgroups());
        helper.add("includes", kd.getIncludes());
        helper.add("scripts", kd.getScripts());
        helper.add("ksdefault", kd.getKickstartDefaults());
        helper.add("repos", kd.getRepos());
        helper.add("partitions", kd.getPartitions());
        helper.add("cryptoKeys", kd.getCryptoKeys());
        helper.add("preserveFileLists", kd.getPreserveFileLists());
        helper.add("childChannels", kd.getChildChannels());

        helper.writeTo(output);
    }
}
