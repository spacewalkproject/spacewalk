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
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerSnapshot;
import com.redhat.rhn.domain.server.SnapshotTag;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;
import java.util.HashSet;
import java.util.Set;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * ServerSerializer: Converts a Server object for representation as an XMLRPC struct.
 * Includes full server details, which may be more data than some calls would like.
 * @version $Rev$
 * 
 * 
 * @xmlrpc.doc
 *  #struct("server snapshot")
 *      #prop("int", "id")
 *      #prop_desc("string", "reason", "the reason for the snapshot's existence")
 *      #prop($date, "created")                            
 *      #prop_array("channels", "string", "labels of channels associated with the 
 *              snapshot")
 *      #prop_array("groups", "string", "Names of server groups associated with 
 *              the snapshot")         
 *      #prop_array("entitlements", "string", "Names of system entitlements associated 
 *              with the snapshot")
 *       #prop_array("config_channels", "string", "Labels of config channels the snapshot 
 *                  is associated with.")
 *      #prop_array("tags", "string", "Tag names associated with this snapshot.")
 *      #prop_desc("string", "Invalid_reason", "If the snapshot is invalid, this is the 
 *                  reason (optional).")
 *  #struct_end()
 */
public class ServerSnapshotSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return ServerSnapshot.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {
        
        ServerSnapshot snap = (ServerSnapshot)value;

        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("id", snap.getId());
        helper.add("reason", snap.getReason());
        helper.add("created", snap.getCreated());
        
        
        Set<String> channels = new HashSet<String>();
        for (Channel chan : snap.getChannels()) {
            channels.add(chan.getLabel());
        }
        helper.add("channels", channels);
        
        Set<String> entGroups = new HashSet<String>();
        Set<String> mgmtGroups = new HashSet<String>();
        for (ServerGroup grp : snap.getGroups()) {
            if (grp instanceof EntitlementServerGroup) {
                entGroups.add(grp.getName());
            }
            else {
                mgmtGroups.add(grp.getName());
            }
        }
        helper.add("groups", mgmtGroups);
        helper.add("entitlements", entGroups);
        
        Set<String> cfgChans = new HashSet<String>();
        for (ConfigChannel grp : snap.getConfigChannels()) {
            cfgChans.add(grp.getLabel());
        }
        helper.add("config_channels", cfgChans);
        
        if (snap.getInvalidReason() != null) {
            helper.add("Invalid_reason", snap.getInvalidReason().getName());
        }
        
        Set<String> tags = new HashSet();
        for (SnapshotTag tag : snap.getTags()) {
            tags.add(tag.getName().getName());
        }
        helper.add("tags", tags);
        
        helper.writeTo(output);
    }
    
    
}
