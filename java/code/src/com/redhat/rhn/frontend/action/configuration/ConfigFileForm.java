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
package com.redhat.rhn.frontend.action.configuration;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.ScrubbingDynaActionForm;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.configuration.ConfigurationValidation;
import com.redhat.rhn.manager.configuration.file.BinaryFileData;
import com.redhat.rhn.manager.configuration.file.ConfigFileData;
import com.redhat.rhn.manager.configuration.file.DirectoryData;
import com.redhat.rhn.manager.configuration.file.TextFileData;

import org.apache.struts.upload.FormFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.text.DecimalFormat;

import javax.servlet.http.HttpServletRequest;

/**
 * ConfigFileForm
 * @version $Rev$
 */
public class ConfigFileForm extends ScrubbingDynaActionForm {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = -2162768922109257186L;
    // configFileForm elements
    public static final String REV_PATH         = "cffPath";
    public static final String REV_UID          = "cffUid";
    public static final String REV_GID          = "cffGid";
    public static final String REV_PERMS        = "cffPermissions";
    public static final String REV_SELINUX_CTX  = "cffSELinuxCtx";
    public static final String REV_MACROSTART   = "cffMacroStart";
    public static final String REV_MACROEND     = "cffMacroEnd";
    public static final String REV_CONTENTS     = "contents"; //cffContent
    public static final String REV_FILETYPE     = "filetype"; //cffFiletype
    public static final String REV_BINARY       = "binary";
    public static final String REV_UPLOAD       = "cffUpload";

    public static final String REV_EDITABLE      = "editable";
    public static final String REV_DISPLAYABLE   = "displayable";
    public static final String REV_TOOLARGE      = "toolarge";
    
    public static final String DEFAULT_CONFIG_DELIM_START = "{|";
    public static final String DEFAULT_CONFIG_DELIM_END = "|}";

    // This cannot be the right way to find this
    // Here to deal with form-size-limits
    public static final long   MAX_EDITABLE_SIZE = (32L * 1024L);

    /**
     * Set acceptable defaults for our form
     */
    public void setDefaults() {
        set(ConfigFileForm.REV_PERMS, "644");
        set(ConfigFileForm.REV_UID, "root");
        set(ConfigFileForm.REV_GID, "root");
        set(ConfigFileForm.REV_FILETYPE, ConfigFileType.FILE);
        setBinary(false);

        String macroStart = Config.get().getString("web.config_delim_start", 
                DEFAULT_CONFIG_DELIM_START);
        String macroEnd = Config.get().getString("web.config_delim_end", 
                DEFAULT_CONFIG_DELIM_END);
        set(ConfigFileForm.REV_MACROSTART, macroStart);
        set(ConfigFileForm.REV_MACROEND, macroEnd);
    }

    
    /**
     * Validate a file-upload. This checks that:
     * <ul>
     * <li>The file exists
     * <li>The file isn't too large
     * <li>If the file is text, its contents are valid after macro-substitution
     * </ul>
     * @param request the incoming request
     * @return a ValidatorResult..  The list is empty if everything is OK
     */
    public ValidatorResult validateUpload(HttpServletRequest request) {
        ValidatorResult msgs = new ValidatorResult();
        
        FormFile file = (FormFile)get(REV_UPLOAD);
        //make sure there is a file
        if (file == null || 
            file.getFileName() == null || 
            file.getFileName().trim().length() == 0) {
            msgs.addError(new ValidatorError("error.config-not-specified"));
               
        }
        else if (file.getFileSize() == 0) {
            msgs.addError(new ValidatorError("error.config-empty", 
                                                        file.getFileName()));
        }
        //make sure they didn't send in something huge
        else if (file.getFileSize() > ConfigFile.getMaxFileSize()) {
            msgs.addError(new ValidatorError("error.configtoolarge",
                    StringUtil.displayFileSize(ConfigFile.getMaxFileSize(), false)));
        }
        // It exists and isn't too big - is it text?
        else if (!isBinary()) {
            try {
                String content = new String(file.getFileData());
                String startDelim = getString(REV_MACROSTART);
                String endDelim   = getString(REV_MACROEND);
                msgs.append(ConfigurationValidation.validateContent(
                                    content, startDelim, endDelim)); 
            }
            catch (Exception e) {
                msgs.addError(new ValidatorError("error.fatalupload",
                                  StringUtil.displayFileSize(
                                          ConfigFile.getMaxFileSize(), false)));
            }
        }
        
        return msgs;
    }
    
    /**
     * Given the incoming request, fill us in with revision info
     * @param request the request
     * @param cr the revision we're getting data from
     */
    public void updateFromRevision(HttpServletRequest request, ConfigRevision cr) {
        
        RequestContext requestContext = new RequestContext(request);
        
        User u = requestContext.getLoggedInUser();
       
        set(ConfigFileForm.REV_PATH, cr.getConfigFile().getConfigFileName().getPath());
        Long mode = cr.getConfigInfo().getFilemode();
        String modeStr = new DecimalFormat("000").format(mode.longValue());
        set(ConfigFileForm.REV_PERMS, modeStr);
        set(ConfigFileForm.REV_SELINUX_CTX, cr.getConfigInfo().getSelinuxCtx());
        set(ConfigFileForm.REV_UID, cr.getConfigInfo().getUsername());
        set(ConfigFileForm.REV_GID, cr.getConfigInfo().getGroupname());
        set(ConfigFileForm.REV_BINARY, new Boolean(cr.getConfigContent().isBinary()));
        set("submitted", Boolean.TRUE);
        
        if (!cr.getConfigContent().isBinary() && !cr.isDirectory()) {
            set(ConfigFileForm.REV_CONTENTS, cr.getConfigContent().getContentsString());
        }
        
        ConfigActionHelper.setupRequestAttributes(requestContext, cr.getConfigFile(), cr);
        
        request.setAttribute(REV_DISPLAYABLE, new Boolean(canDisplayContent(cr)));
        request.setAttribute(REV_EDITABLE, new Boolean(canEditContent(u, cr)));
        
        Boolean toolarge = new Boolean(
                cr.getConfigContent().getFileSize().longValue() > MAX_EDITABLE_SIZE);
        request.setAttribute(REV_TOOLARGE, toolarge);
    }
    
    /**
     * You can DISPLAY content IFF
     *   - It's not a directory
     *   - It's not binary
     *   - It's not "too damn big"
     * @param cr file of interest
     * @return true IFF the above conditions are true
     */
    protected boolean canDisplayContent(ConfigRevision cr) {
        return (!cr.isDirectory() &&
                !cr.getConfigContent().isBinary() && 
                cr.getConfigContent().getFileSize().longValue() < MAX_EDITABLE_SIZE);
    }
    
    /**
     * You can edit a file IFF:
     *   - You're a config-admin, and this is a GLOBAL channel
     *   - You're a system-admin, and this is a LOCAL or SANDBOX channel
     * @param user logged-in user making the request
     * @param cr revision to be edited
     * @return true IFF user has write-access to the file
     */
    protected boolean canEditContent(User user, ConfigRevision cr) {
        ConfigurationManager mgr = ConfigurationManager.getInstance();
        ConfigChannel cc = cr.getConfigFile().getConfigChannel();
        
        if (cc.isGlobalChannel()) {
            return (user.hasRole(RoleFactory.CONFIG_ADMIN));
        }
        else {
            return (mgr.accessToChannel(user.getId(), cc.getId())); 
        }
    }

    /**
     * CONTENTS. MACROSTART, and MACROEND field -cannot- be scrubbed -
     * but the rest MUST be scrubbed
     * {@inheritDoc}
     */
    protected boolean isScrubbable(String name, Object value) {
        if (REV_CONTENTS.equals(name) ||
            REV_MACROSTART.equals(name) ||
            REV_MACROEND.equals(name)) {
            return false;
        }
        else {
            return super.isScrubbable(name, value);
        }
    }
    
    private boolean isUpload() {
        return get(REV_UPLOAD) != null;
    }
    
    /**
     * 
     * @return true if content is binary false other wise
     */
    private boolean isBinary() {
        return Boolean.TRUE.equals(get(REV_BINARY));
    }
    
    /**
     * Returns the config file type of the content
     * @return dir/file...
     */
    private ConfigFileType extractFileType() {
        String ft = getString(ConfigFileForm.REV_FILETYPE);
        return ConfigFileType.lookup(ft);
    }
 

    
    /**
     * sets if the file is a binary or text.
     * @param isBinary true if this file is a binary
     */
    private void setBinary(boolean isBinary) {
        set(REV_BINARY, Boolean.valueOf(isBinary));
    }
    
    /**
     * 
     * @return true if this holds a dir, returns false if it holds a file..
     */
    private boolean isDirectory() {
        return ConfigFileType.dir().equals(extractFileType());
    }
    
    private String getContents() {
        return StringUtil.webToLinux(getString(ConfigFileForm.REV_CONTENTS));
    }
    /**
     * 
     * @return a ConfigFileData representation of this Form
     */
    public ConfigFileData toData() {
        ConfigFileData data;
        if (isDirectory()) {
            data = new DirectoryData();
        }
        else if (isBinary()) {
            if (isUpload()) {
                FormFile file = (FormFile) get(REV_UPLOAD);
                try {
                    data = new BinaryFileData(file.getInputStream(), 
                                                        file.getFileSize());
                }
                catch (IOException e) {
                    String msg = "Unable to read the uploaded binary file stream";
                    throw new RuntimeException(msg, e);
                }
            }
            else {
                data = new BinaryFileData(new ByteArrayInputStream(new byte[0]), 0);
            }
        }
        else {
            if (isUpload()) {
                FormFile file = (FormFile) get(REV_UPLOAD);
                StrutsDelegate del = StrutsDelegate.getInstance();
                data = new TextFileData(del.extractString(file));                
            }
            else {
                data = new TextFileData(getContents());
            }
            data.setMacroStart(getString(REV_MACROSTART));
            data.setMacroEnd(getString(REV_MACROEND));
        }
        data.setPath(getString(REV_PATH));
        data.setGroup(getString(REV_GID));
        data.setOwner(getString(REV_UID));
        data.setPermissions(getString(REV_PERMS));
        data.setSelinuxCtx(getString(REV_SELINUX_CTX));
        data.setType(extractFileType());
        return data;
    }

    /**
     * Returns a ConfigFileData representation of this Form, similar to toData()
     * however in addition it replicates the contents of the passed in revision 
     * rev to the ConfigFIleData.. This is mainly used in the FileDetailAction
     * where want the contents of a "non-displayable" file replicated on to the
     * newer revision... 
     * @param rev the revision to replicate the content stream.
     * @return the newly updated revision..
     */
    public ConfigFileData toRevisedData(ConfigRevision rev) {
        ConfigFileData data = toData();
        boolean toBeBinary = (Boolean)get(REV_BINARY) == null ? 
                rev.getConfigContent().isBinary() : 
                 isBinary();        
        if (!canDisplayContent(rev) || toBeBinary) {
            data.processRevisedContentFrom(rev);
        }
        return data;
        
    }
}
