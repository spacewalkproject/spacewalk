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

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import org.apache.commons.lang.StringUtils;

import java.io.IOException;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * 
 * ChannelSerializer
 * @version $Rev$
 * 
 * @xmlrpc.doc
 *  #struct("channel")
 *      #prop("int", "id")
 *      #prop("string", "name")
 *      #prop("string", "label")
 *      #prop("string", "arch_name")
 *      #prop("string", "summary")
 *      #prop("string", "description")
 *      #prop("string", "checksum_label")
 *      #prop("string", "maintainer_name")
 *      #prop("string", "maintainer_email")
 *      #prop("string", "maintainer_phone")
 *      #prop("string", "support_policy")
 *      #prop("string", "gpg_key_url")
 *      #prop("string", "gpg_key_id")
 *      #prop("string", "gpg_key_fp")
 *      #prop("string", "yumrepo_source_url")
 *      #prop("string", "yumrepo_label")
 *      #prop("dateTime.iso8601", "yumrepo_last_sync")
 *      #prop("string", "end_of_life")
 *      #prop("string", "parent_channel_label")
 *  #struct_end()
 *       
 */
public class ChannelSerializer implements XmlRpcCustomSerializer {
   
    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return Channel.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        Channel c = (Channel) value;
        
        
        helper.add("id", c.getId());
        helper.add("label", c.getLabel());
        helper.add("name", c.getName());
        helper.add("arch_name",
                StringUtils.defaultString(c.getChannelArch().getName()));
        helper.add("summary", StringUtils.defaultString(c.getSummary()));
        helper.add("description",
                StringUtils.defaultString(c.getDescription()));
        helper.add("checksum_label", c.getChecksumTypeLabel());
        helper.add("maintainer_name", c.getMaintainerName());
        helper.add("maintainer_email", c.getMaintainerEmail());
        helper.add("maintainer_phone", c.getMaintainerPhone());
        helper.add("support_policy", c.getSupportPolicy());
        
        helper.add("gpg_key_url",
                StringUtils.defaultString(c.getGPGKeyUrl()));
        helper.add("gpg_key_id",
                StringUtils.defaultString(c.getGPGKeyId()));
        helper.add("gpg_key_fp",
                StringUtils.defaultString(c.getGPGKeyFp()));

        if (c.getContentSources().isEmpty()) {
            helper.add("yumrepo_source_url", "");
            helper.add("yumrepo_label", "");
            helper.add("yumrepo_last_sync", "");
        }
        else {
            ContentSource cs = c.getContentSources().iterator().next();
            helper.add("yumrepo_source_url", cs.getSourceUrl());
            helper.add("yumrepo_label", cs.getLabel());
            if (cs.getLastSynced() != null) {
                helper.add("yumrepo_last_sync", cs.getLastSynced());
            }
            else {
                helper.add("yumrepo_last_sync", "");
            }
        }

        if (c.getEndOfLife() != null) {
            helper.add("end_of_life", c.getEndOfLife().toString());
        }
        else {
            helper.add("end_of_life", "");
        }
        
        Channel parent = c.getParentChannel();
        if (parent != null) {
            helper.add("parent_channel_label", parent.getLabel());
        }
        else {
            helper.add("parent_channel_label", "");
        }

        helper.writeTo(output);
    }
}
