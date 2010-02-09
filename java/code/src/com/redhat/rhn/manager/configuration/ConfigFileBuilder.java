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
package com.redhat.rhn.manager.configuration;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigContent;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigFileState;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.configuration.file.ConfigFileData;

import java.io.IOException;


/**
 * ConfigFileCreationHelper
 * @version $Rev$
 */
public class ConfigFileBuilder {
    private static final ConfigFileBuilder HELPER = 
                                            new ConfigFileBuilder();
     
    private ConfigFileBuilder() {
    }
    
    
    /**
     * @return an instance of this class
     */
    public static ConfigFileBuilder getInstance() {
        return HELPER;
    }
    
    /**
     * Validates the passed in channel using the info provided
     * @param cff the COnfigFileForm associated to the request
     * @param user the logged in user
     * @param channel the config channel.
     * @return returns a ValidatorResult 
     */
    private void validateForCreate(ConfigFileData cff, 
                          User user, ConfigChannel channel) throws ValidatorException {
        
        cff.validatePath();
                // File exists?  Report and bolt
        String path = cff.getPath();
        if (fileExists(user, path, channel)) {
            ValidatorResult result = new ValidatorResult();
            result.addError(new ValidatorError("config.error.file-exists", path));
            throw new ValidatorException(result);
        }
        cff.validate(true);
    }

    /**
     * 
     * @param user the logged in user
     * @param form the config file form
     * @param cc the config channel
     * @return True if file exists false other wise
     */
    private boolean fileExists(
            User user, String path, ConfigChannel cc) {
        ConfigFile file = null;
        
        if (path != null && path.trim().length() > 0) {
            file = ConfigurationManager.getInstance().
                lookupConfigFile(user, cc.getId(), path);
        }
            
        return (file != null);
    }
    
    /**
     * Creates a new config file using the information provided 
     * in the config file form.
     * @param cff the config file from holding input data
     * @param user the logged in user.
     * @param channel the channel to create file in.
     * @return the newest revision of the created config file..
     * @throws IOException in the case of issues with content stream reading.
     * @throws ValidatorException in the case of invalid data passed in.
     */
    public ConfigRevision create(ConfigFileData cff, 
                        User user, ConfigChannel channel) 
                                throws IOException, ValidatorException {
        validateForCreate(cff, user, channel);
        // Yay! We actually might be able to create this file!
        ConfigFile cf = channel.createConfigFile(ConfigFileState.normal(),
                                                        cff.getPath());
        return makeNewRevision(user, cff, cf, true);
    }

    /**
     * Creates a new New config revision of a config file using the passed in data. 
     * @param user the logged in user
     * @param form the config file form
     * @param cf the the config file to populate and commit
     * @return the newly createed config revision.
     * @throws IOException in the case of error in reading content stream.
     */
    private ConfigRevision makeNewRevision(User user, ConfigFileData form,
            ConfigFile cf, boolean onCreate) {

        ConfigurationManager manager = ConfigurationManager.getInstance();
        ConfigRevision revision;

        if (onCreate) {
            revision = ConfigurationFactory.newConfigRevision();
            ConfigContent content = ConfigurationFactory
                    .createNewContentFromStream(form.getContentStream(),
                            form.getContentSize(), form.isBinary());
            revision.setConfigContent(content);
            revision.setChangedById(user.getId());                
        }
        else {
            revision = manager.createNewRevision(
                    user, form.getContentStream(), cf,
                        form.getContentSize());
            revision.getConfigContent().setBinary(form.isBinary());
        }
        revision.setConfigInfo(form.extractInfo());
        revision.setConfigFileType(form.getType());
        revision.setConfigFile(cf);
        revision.setDelimStart(form.getMacroStart());
        revision.setDelimEnd(form.getMacroEnd());

        // Committing the revision commits the file for us (which commits the
        // Channel, so everybody's pointers get updated...)
        ConfigurationFactory.commit(revision);
        return revision;
    }

    
    /**
     * Updates a config file 
     * depending on the data in the given  configFileForm.. 
     * @param form the ConfigFileData form containing the input data
     * @param user the logged in user.
     * @param file the config file to update.
     * @return the create revision of the file.
     * @throws ValidatorException in the case of invalid data.
     */
    public ConfigRevision update(ConfigFileData form, 
                            User user, ConfigFile file)
                                        throws ValidatorException {
        ValidatorResult result;
        if (form.isDirectory() && !file.getLatestConfigRevision().isDirectory()) {
            result = new ValidatorResult();
            result.addError(new ValidatorError("error.config-cannot-change-file2dir",
                                                        form.getPath()));
            throw new ValidatorException(result);
        }
        else if (!form.isDirectory() && file.getLatestConfigRevision().isDirectory()) {
            result = new ValidatorResult();
            result.addError(new ValidatorError("error.config-cannot-change-dir2file",
                                                        form.getPath()));
            throw new ValidatorException(result);
        }
        else {
            form.validate(false);    
        }

        return makeNewRevision(user, form, file, false);
    }
    
    /**
     * Creates Or Updates a config file 
     * depending on the data in the given  configFileForm.. 
     * i.e. if a  file with the given path exists, it updates the 
     * file with that path. Else it creates a new file of the path.. 
     * @param form the config file form with the input data
     * @param user the logged in user.
     * @param cc the config channel of the file
     * @return the create revision of the file.
     * @throws IOException in the case of issues due to parsing of contents.
     * @throws ValidatorException in the case of invalid data.
     */
    public ConfigRevision createOrUpdate(ConfigFileData form, 
                                            User user, ConfigChannel cc)
                                        throws IOException, ValidatorException {
        String path = form.getPath();
        ConfigurationManager manager = ConfigurationManager.getInstance();
        ConfigFile file = manager.lookupConfigFile(user, cc.getId(), path);
        if (file == null) {
            return create(form, user, cc);                
        }
        return update(form, user, file);
    }
    

}
