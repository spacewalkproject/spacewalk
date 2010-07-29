/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.manager.configuration.file;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigInfo;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.configuration.ConfigurationValidation;


/**
 * SymlinkData
 * @version $Rev$
 */
public class SymlinkData extends DirectoryData {
    private static final String VALIDATION_XSD =
            "/com/redhat/rhn/frontend/action/configuration/validation/" +
                                        "configFileFormForSymlink.xsd";
    private String targetPath;
    /**
     * Constructor
     * @param path the target path of the symlink
     */
    public SymlinkData(String path) {
        super();
        setType(ConfigFileType.symlink());
        targetPath = path;
    }

    /**
     *
     * {@inheritDoc}
     */
    @Override
    public ConfigFileType getType() {
        return ConfigFileType.symlink();
    }

    /**
     * @return the targetPath
     */
    public String getTargetPath() {
        return targetPath;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void validatePath() throws ValidatorException {
        super.validatePath();
        ValidatorResult result = ConfigurationValidation.validatePath(getTargetPath());
        if (!result.isEmpty()) {
            throw new ValidatorException(result);
        }
    }


    /**
    *
    * @return info pertaining to this form.
    */
   @Override
   public ConfigInfo extractInfo() {
       ConfigInfo info = ConfigurationFactory.lookupOrInsertConfigInfo(
                           null, null,
                           null, getSelinuxCtx(), getTargetPath());
       return info;
   }

   /**
    * Entry point to validate the contents of this form..
    * @param onCreate true if we're creating a config-file, false if we're only updating
    * @throws ValidatorException if there are any validation errors.
    */
   @Override
   public void validate(boolean onCreate) throws ValidatorException {
       if (onCreate) {
           validatePath();
       }
       // Struts-validation errors?  Bug out if so
       ValidatorResult result = RhnValidationHelper.validate(this.getClass(),
                                           makeValidationMap(), null,
                                           VALIDATION_XSD);
       ValidatorError ve = validateSELinux();

       if (ve != null) {
           result.addError(ve);
       }

       if (!result.isEmpty()) {
           throw new ValidatorException(result);
       }
   }
}
