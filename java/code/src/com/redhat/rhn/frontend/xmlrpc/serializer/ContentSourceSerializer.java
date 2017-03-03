/**
 * Copyright (c) 2009--2016 Red Hat, Inc.
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

import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

/**
 *
 * ContentSourceSerializer
 * @version $Rev$
 *
 * @xmlrpc.doc
 *  #struct("channel")
 *      #prop("int", "id")
 *      #prop("string", "label")
 *      #prop("string", "sourceUrl")
 *      #prop("string", "type")
 *      #array("sslContentSources")
 *          #struct()
 *              #prop("string", "sslCaDesc")
 *              #prop("string", "sslCertDesc")
 *              #prop("string", "sslKeyDesc")
 *          #struct_end()
 *      #array_end()
 *  #struct_end()
 *
 */
public class ContentSourceSerializer extends RhnXmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ContentSource.class;
    }

    /**
     * {@inheritDoc}
     */
    protected void doSerialize(Object value, Writer output, XmlRpcSerializer serializer)
        throws XmlRpcException, IOException {
        SerializerHelper helper = new SerializerHelper(serializer);
        ContentSource repo = (ContentSource) value;

        helper.add("id", repo.getId());
        helper.add("label", repo.getLabel());
        helper.add("sourceUrl", repo.getSourceUrl());
        helper.add("type", repo.getType().getLabel());
        helper.add("sslContentSources", repo.getSslSets());

        helper.writeTo(output);
    }
}
