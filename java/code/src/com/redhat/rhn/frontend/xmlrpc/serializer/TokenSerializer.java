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
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.token.TokenPackage;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.IOException;
import java.io.Writer;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
* ActivationKeySerializer
* @version $Rev$
*
* @xmlrpc.doc
*   #struct("token serializer")
*     #prop("string", "description")
*     #prop("int", "usage_limit")
*     #prop("string", "base_channel_label")
*     #prop_array("child_channel_labels", "string", "childChannelLabel")
*     #prop_array("entitlements", "string", "entitlementLabel")
*     #prop_array("server_group_ids", "string", "serverGroupId")
*     #prop_array("package_names", "string", "packageName")
*     #prop_array_begin("packages")
*       #struct("package")
*         #prop_desc("name", "string", "packageName")
*         #prop_desc("arch", "string", "archLabel - optional")
*       #struct_end()
*     #prop_array_end()
*     #prop("boolean", "universal_default")
*   #struct_end()
*/
public class TokenSerializer implements XmlRpcCustomSerializer {

   /**
    * {@inheritDoc}
    */
   public Class getSupportedClass() {
       return Token.class;
   }

   /** {@inheritDoc} */
   public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
       throws XmlRpcException, IOException {
       SerializerHelper helper = new SerializerHelper(builtInSerializer);
       populateTokenInfo((Token)value, helper);
       helper.writeTo(output);
   }
   /**
    * Populates token information in to serializer format.
    * Since 95% of activation key serializer also uses this format
    *  it seemed prudent to make this a default access static method..
    * @param token the token to get the information to populate
    * @param helper the serializer helper that will be populated.
    */
   static  void populateTokenInfo(Token token,  SerializerHelper helper) {
       // Locate the base channel, and store the others in a list of child channels:
       List<String> childChannelLabels = new LinkedList<String>();
       String baseChannelLabel = null;
       for (Channel c : token.getChannels()) {
           if (c.isBaseChannel()) {
               baseChannelLabel = c.getLabel();
           }
           else {
               childChannelLabels.add(c.getLabel());
           }
       }
       if (baseChannelLabel == null) {
           baseChannelLabel = "none";
       }

       // Prepare a list of relevant entitlement labels, make sure to filter the
       // non-addon entitlements:
       List<String> entitlementLabels = new LinkedList<String>();
       for (ServerGroupType sgt : token.getEntitlements()) {
           if (!sgt.isBase()) {
               entitlementLabels.add(sgt.getLabel());
           }
       }

       List<Integer> serverGroupIds = new LinkedList<Integer>();
       for (ServerGroup group : token.getServerGroups()) {
           serverGroupIds.add(new Integer(group.getId().intValue()));
       }

       List<String> packageNames = new LinkedList<String>();
       List<Map<String, String>> packages = new LinkedList<Map<String, String>>();
       for (TokenPackage pkg : token.getPackages()) {
           packageNames.add(pkg.getPackageName().getName());

           Map<String, String> pkgMap = new HashMap<String, String>();
           pkgMap.put("name", pkg.getPackageName().getName());

           if (pkg.getPackageArch() != null) {
               pkgMap.put("arch", pkg.getPackageArch().getLabel());
           }
           packages.add(pkgMap);
       }
       helper.add("description", token.getNote());

       Integer usageLimit = new Integer(0);
       if (token.getUsageLimit() != null) {
           usageLimit = new Integer(token.getUsageLimit().intValue());
       }
       helper.add("usage_limit", usageLimit);

       helper.add("base_channel_label", baseChannelLabel);
       helper.add("child_channel_labels", childChannelLabels);
       helper.add("entitlements", entitlementLabels);
       helper.add("server_group_ids", serverGroupIds);
       helper.add("package_names", packageNames);
       helper.add("packages", packages);

       Boolean universalDefault =  Boolean.valueOf(token.isOrgDefault());
       helper.add("universal_default", universalDefault);
   }
}
