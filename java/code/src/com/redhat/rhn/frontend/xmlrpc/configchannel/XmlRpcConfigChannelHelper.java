/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.configchannel;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.serializer.ConfigRevisionSerializer;
import com.redhat.rhn.manager.configuration.ConfigFileBuilder;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.configuration.file.BinaryFileData;
import com.redhat.rhn.manager.configuration.file.ConfigFileData;
import com.redhat.rhn.manager.configuration.file.DirectoryData;
import com.redhat.rhn.manager.configuration.file.TextFileData;

import org.apache.commons.lang.StringUtils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * 
 * XmlRpcConfigChannelHelper
 * @version $Rev$
 */
public class XmlRpcConfigChannelHelper {
    
    private static final XmlRpcConfigChannelHelper HELPER = 
                                        new XmlRpcConfigChannelHelper();

    /**
     * private constructor to make this a singleton 
     */
    private XmlRpcConfigChannelHelper() {
    }
    /**
     * @return Returns the running instance of this helper class
     */
    public static XmlRpcConfigChannelHelper getInstance() {
        return HELPER;
    }
    /**
     * Helper method to lookup a config channel from a config channel label
     * @param user The user looking up the server
     * @param label The label of the config channel we're looking for
     * @return Returns the config channel corresponding to label
     */
    public ConfigChannel lookupGlobal(User user, String label) {
        ConfigurationManager manager = ConfigurationManager.getInstance();
        return manager.lookupConfigChannel(user, label, ConfigChannelType.global());
    }
    
    /**
     * Helper method to lookup a list of config channels from channel labels
     * @param user The user looking up the server
     * @param labels The labels of the config channels we're looking for
     * @return Returns a list of config channels corresponding to labels
     */
    public List<ConfigChannel> lookupGlobals(User user, List<String> labels) {
        List <ConfigChannel> channels = new LinkedList<ConfigChannel>(); 
        for (String label : labels) {
            channels.add(lookupGlobal(user, label));
        }
        return channels;
    }
    
    
    /**
     * Creates a NEW path(file/directory) with the given path or updates an existing path 
     * with the given contents in a given channel.
     * @param loggedInUser logged in user
     * @param channel  the config channel who holds the file.
     * @param path the path of the given text file. 
     * @param isDir true if this is a directory path, false if its to be a file path
     * @param data a map containing properties pertaining to the given path..
     * for directory paths - 'data' will hold values for ->
     *  owner, group, permissions 
     * for file paths -  'data' will hold values for-> 
     *  contents, owner, group, permissions, macro-start-delimiter, macro-end-delimiter 
     * @return returns the new created or updated config revision..
     */    
    
    public ConfigRevision createOrUpdatePath(User loggedInUser, 
                                         ConfigChannel channel,
                                         String path,
                                         boolean isDir,
                                         Map<String, Object> data) {
        ConfigFileData form;
        
        if (!isDir) {
            if (data.get(ConfigRevisionSerializer.CONTENTS) instanceof String) {
                String content = (String)data.get(ConfigRevisionSerializer.CONTENTS);
                form = new TextFileData();
                ((TextFileData)form).setContents(content);
            }
            else {
                byte[] content = (byte[])data.get(ConfigRevisionSerializer.CONTENTS);
                if (content != null) {
                    form = new BinaryFileData(new ByteArrayInputStream(content), 
                                                                    content.length);
                }
                else {
                    form = new BinaryFileData(new ByteArrayInputStream(new byte[0]), 0);
                }
            }
            String startDelim = (String)data.get(ConfigRevisionSerializer.MACRO_START);
            String stopDelim = (String)data.get(ConfigRevisionSerializer.MACRO_END);
            
            if (!StringUtils.isBlank(startDelim)) {
                form.setMacroStart(startDelim);    
            }
            if (!StringUtils.isBlank(stopDelim)) {
                form.setMacroEnd(stopDelim);    
            }
        }
        else {
            form = new DirectoryData();
        }
        
        form.setPath(path);
        form.setOwner((String)data.get(ConfigRevisionSerializer.OWNER));
        form.setGroup((String)data.get(ConfigRevisionSerializer.GROUP));
        form.setPermissions((String)data.get(ConfigRevisionSerializer.PERMISSIONS));
        String selinux = (String)data.get(ConfigRevisionSerializer.SELINUX_CTX);
        form.setSelinuxCtx(selinux == null ? "" : selinux);



        ConfigFileBuilder helper = ConfigFileBuilder.getInstance();
        try {
            return helper.createOrUpdate(form, loggedInUser, channel);    
        }
        catch (ValidatorException ve) {
            String msg = "Following errors were encountered " +
                "when creating the config file.\n" + ve.getMessage();
            throw new FaultException(1023, "ConfgFileError", msg);
            
        }
        catch (IOException ie) {
            String msg = "Error encountered when saving the config file. " +
                                "Please retry. " + ie.getMessage();
            throw new FaultException(1024, "ConfgFileError", msg);
        }
    }    
}
