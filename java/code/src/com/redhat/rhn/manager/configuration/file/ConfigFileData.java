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
package com.redhat.rhn.manager.configuration.file;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigInfo;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.frontend.action.configuration.ConfigFileForm;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.configuration.ConfigurationValidation;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;


/**
 * ConfigFileData
 * @version $Rev$
 */
public abstract class ConfigFileData {
    private static long serialVersionUID = -2162768922109257186L;
    private static final String VALIDATION_XSD =
        "/com/redhat/rhn/frontend/action/configuration/validation/configFileForm.xsd";

    private String path;
    private String owner;
    private String group;
    private String permissions;
    private String selinuxCtx;
    private String macroStart;
    private String macroEnd;
    private String revNumber;

    private ConfigFileType type;

    public static final String DEFAULT_CONFIG_DELIM_START = "{|";
    public static final String DEFAULT_CONFIG_DELIM_END = "|}";
    public static final long MAX_FILE_SIZE = Config.get().
                                    getInt(ConfigDefaults.CONFIG_REVISION_MAX_SIZE);
    private static final String DEFAULT_MACRO_START = Config.get().
                                            getString("web.config_delim_start",
                                                            DEFAULT_CONFIG_DELIM_START);
    private static final String DEFAULT_MACRO_END = Config.get().
                                        getString("web.config_delim_end",
                                                DEFAULT_CONFIG_DELIM_END);
    /**
     * Constructor for COnfigFIleData
     */
    public ConfigFileData() {
        setPermissions("644");
        setOwner("root");
        setGroup("root");
        setSelinuxCtx("");
        setType(ConfigFileType.file());
        setMacroStart(DEFAULT_MACRO_START);
        setMacroEnd(DEFAULT_MACRO_END);
    }

    /**
     * @return the path
     */
    public String getPath() {
        return path;
    }

    /**
     * @param filePath the path to set
     */
    public void setPath(String filePath) {
        this.path = filePath;
    }

    /**
     * @return the owner
     */
    public String getOwner() {
        return owner;
    }

    /**
     * @param ownerName the owner to set
     */
    public void setOwner(String ownerName) {
        this.owner = ownerName;
    }

    /**
     * @return the group
     */
    public String getGroup() {
        return group;
    }

    /**
     * @param groupIn the group to set
     */
    public void setGroup(String groupIn) {
        this.group = groupIn;
    }

    /**
     * @return the permissions
     */
    public String getPermissions() {
        return permissions;
    }

    /**
     * @param perms the permissions to set
     */
    public void setPermissions(String perms) {
        this.permissions = perms;
    }

    /**
     * @return the SELinux context
     */
    public String getSelinuxCtx() {
        return selinuxCtx;
    }

    /**
     * @param context the SELinux context to set
     */
    public void setSelinuxCtx(String context) {
        this.selinuxCtx = context;
    }

    /**
     * @return the macroStart
     */
    public String getMacroStart() {
        return macroStart;
    }

    /**
     * @param macroStartDelimiter the macroStart to set
     */
    public void setMacroStart(String macroStartDelimiter) {
        this.macroStart = macroStartDelimiter;
    }

    /**
     * @return the macroEnd
     */
    public String getMacroEnd() {
        return macroEnd;
    }

    /**
     * @param macroEndDelimiter the macroEnd to set
     */
    public void setMacroEnd(String macroEndDelimiter) {
        this.macroEnd = macroEndDelimiter;
    }

    /**
     * @return the binary
     */
    public boolean isBinary() {
        return false;
    }

    /**
     * @return the type
     */
    public ConfigFileType getType() {
        return type;
    }

    /**
     * @param fileType the type to set
     */
    public void setType(ConfigFileType fileType) {
        this.type = fileType;
    }

    /**
     *
     * @return info pertaining to this form.
     */
    public ConfigInfo extractInfo() {
        ConfigInfo info = ConfigurationFactory.lookupOrInsertConfigInfo(
                            getOwner(), getGroup(),
                            Long.valueOf(getPermissions()),
                            getSelinuxCtx(), null);
        return info;
    }

    /**
     * Validate config-file data before commiting changes.  Specifically,
     * do validation that the Struts Validator doesn't know how to do.
     *
     * This checks that:
     * <ul>
     * <li>size is &lt; max
     * <li>owner exists and is a valid Linux username of &lt; 32 chars
     * (or user-id, but it can't tell the diff)
     * <li>group exists nd is a valid Linux groupname of &lt; 32 chars
     * (or group-id, but it can't tell the diff)
     * <li>mode exists and is a valid three-digit file mode
     * <li>delimiter start and end exist, are two chars, and contain no percent signs
     * <li>contents (if text) validate after macro-substitution
     * </ul>
     *
     * @param onCreate true if we're creating a config-file, false if we're only updating
     * @return messages describing all errors found
     * @throws ValidatorException if there are any validation errors.
     */
    private void validateData(boolean onCreate) throws ValidatorException {

        ValidatorResult msgs = new ValidatorResult();
        // Validate user/uid
        if (!ConfigurationValidation.validateUserOrGroup(getOwner()) &&
            !ConfigurationValidation.validateUGID(getOwner())) {
            msgs.addError(error("user-invalid"));
        }

        // Validate group
        if (!ConfigurationValidation.validateUserOrGroup(group) &&
            !ConfigurationValidation.validateUGID(group)) {
            msgs.addError(error("group-invalid"));
        }

        // Validate mode
        if (!getPermissions().matches("^[0-7][0-7][0-7][0-7]?$")) {
            msgs.addError(error("mode-invalid"));
        }

        if (isFile()) {
            if (!StringUtils.isBlank(getMacroStart())) {
                // Validate macro-start
                if (getMacroStart().indexOf('%') != -1) {
                    msgs.addError(error("start-delim-percent"));
                }
            }

            // Validate macro-end
            if (!StringUtils.isBlank(getMacroEnd())) {
                if (getMacroEnd().indexOf('%') != -1) {
                    msgs.addError(error("end-delim-percent"));
                }
            }

            if (getContentSize() > ConfigFile.getMaxFileSize()) {
                msgs.addError("error.configtoolarge",
                        StringUtil.displayFileSize(ConfigFile.getMaxFileSize(), false));
            }
            validateContents(msgs, onCreate);
        }

        ValidatorError ve = validateSELinux();
        if (ve != null) {
            msgs.addError(ve);
        }


        if (!msgs.isEmpty()) {
            throw new ValidatorException(msgs);
        }
    }

    protected ValidatorError validateSELinux() {
        String sens = "s\\d+";
        String cats = "c\\d+(\\.c\\d+)?";
        String mlsregex = sens + "(:" + cats + "(," + cats + ")*)?";
        // Validate selinux context
        if (!getSelinuxCtx().matches(
                 // \\w is [a-zA-Z_0-9], or [_[:alnum:]]
                 "^\\w*" + // user
                "(:\\w*" + // role
                "(:\\w*" + // type
                "(:" + mlsregex + // low
                "(\\-" + mlsregex + // high
                ")?)?)?)?$")) {
            return new ValidatorError("config-file-form.error.selinux-invalid");
        }
        return null;
    }

    protected abstract void validateContents(ValidatorResult result,
                                                        boolean onCreate);

    private ValidatorError error(String msgKey) {
        return new ValidatorError("config-file-form.error." + msgKey);
    }

    /**
     * @return the contentStream
     */
    public abstract InputStream getContentStream();

    /**
     * @return the contentSize
     */
    public abstract long getContentSize();

    /**
     *
     * @return true if the data in this Calass is a directory
     */
    public boolean isFile() {
        return ConfigFileType.file().equals(getType());
    }

    /**
     * Entry point to validate the contents of this form..
     * @param onCreate true if we're creating a config-file, false if we're only updating
     * @throws ValidatorException if there are any validation errors.
     */
    public void validate(boolean onCreate) throws ValidatorException {
        if (onCreate) {
            validatePath();
        }

        // Struts-validation errors?  Bug out if so
        ValidatorResult result = RhnValidationHelper.validate(this.getClass(),
                                            makeValidationMap(), null,
                                            VALIDATION_XSD);
        if (!result.isEmpty()) {
            throw new ValidatorException(result);
        }
        validateData(onCreate);
    }

    /**
     * Validates the path explicatily ensuring it follows Linux/Unix path
     *  conventions. This is separate form the regular validate method because
     *  there was code that needed to check for things like path existence
     *  that had to be run after ensuring the path looked ok...
     * @throws ValidatorException  if there are any validation errors.
     */
    public void validatePath() throws ValidatorException {
        ValidatorResult result = ConfigurationValidation.validatePath(getPath());
        if (!result.isEmpty()) {
            throw new ValidatorException(result);
        }
    }

    /**
     * Basically returns a map equating ConfigFileForm's form fieldnames
     * to values from config file data.. This is needed by the RHnValidationHelper
     * while matching values against xsds..
     * @return a map with key = ConfigFIleForms keys, & value = ConfigFIleData values..
     */
    protected Map makeValidationMap() {
        Map map = new HashMap();
        map.put(ConfigFileForm.REV_UID, getOwner());
        map.put(ConfigFileForm.REV_GID, getGroup());
        map.put(ConfigFileForm.REV_PERMS, getPermissions());
        map.put(ConfigFileForm.REV_SELINUX_CTX, getSelinuxCtx());
        map.put(ConfigFileForm.REV_SYMLINK_TARGET_PATH, getSelinuxCtx());
        map.put(ConfigFileForm.REV_MACROSTART, getMacroStart());
        map.put(ConfigFileForm.REV_MACROEND, getMacroEnd());
        return map;
    }

    /**
     * Basically Extension point to update the relevant in this data file
     * with the content provided in the revision param. This is mainly
     * used to update things like BinaryFiles/Directories where we want
     * the contents of the previous version copied over to the new content ...
     * @param rev the revision to copy stuff from..
     */
    public abstract void processRevisedContentFrom(ConfigRevision rev);

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        ToStringBuilder builder = new ToStringBuilder(this);
        builder.append("Path", getPath()).
                append("Owner", getOwner()).
                append("Group", getGroup()).
                append("Permissions", getPermissions()).
                append("SELinux Context", getSelinuxCtx()).
                append("Type", getType()).
                append("Macro Start", getMacroStart()).
                append("Macro End", getMacroEnd()).
                append("isBinary", isBinary()).
                append("Size:", getContentSize());
        return builder.toString();
    }


    /**
     * @return Returns the revNumber.
     */
    public String getRevNumber() {
        return revNumber;
    }


    /**
     * @param revNumberIn The revNumber to set.
     */
    public void setRevNumber(String revNumberIn) {
        this.revNumber = revNumberIn;
    }
 }
