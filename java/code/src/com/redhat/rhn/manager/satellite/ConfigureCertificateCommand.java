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
package com.redhat.rhn.manager.satellite;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.RandomStringUtils;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;

/**
 * Updates the satellite certificate using the <code>rhn-satellite-activate</code>
 * utility.
 */
public class ConfigureCertificateCommand
    extends BaseConfigureCommand implements SatelliteConfigurator {

    private String certificateText;
    private String certificateFileName;
    private boolean ignoreVersionMismatch;

    /**
     * Constructor.
     *
     * @param userIn who is going to execute this Command
     */
    public ConfigureCertificateCommand(User userIn) {
        super(userIn);
    }

    /**
     * Store the certificate to the local satellite.  This will 'Activate'
     * the satellite in an attempt to validate the cert.
     *
     * @return errors encountered while storing
     */
    public ValidatorError[] storeConfiguration() {
        Executor e = getExecutor();
        ValidatorError[] errors = new ValidatorError[1];
        String errorKey = "certificate.config.error.";

        try {
            writeStringToFile();
        }
        catch (FileNotFoundException e1) {
            e1.printStackTrace();
            errors[0] = new ValidatorError(errorKey + "88");
            return errors;
        }

        List<String> args = new ArrayList<String>();
        args.add("/usr/bin/sudo");
        args.add("/usr/bin/rhn-satellite-activate");
        args.add("--rhn-cert");
        args.add(getCertificateFileName());
        if (ConfigDefaults.get().isDisconnected()) {
            args.add("--disconnected");
        }
        if (ignoreVersionMismatch) {
            args.add("--ignore-version-mismatch");
        }

        String[] process = args.toArray(new String[args.size()]);
        int exitcode = e.execute(process);

        if (!deleteCertTempFile(this.certificateFileName)) {
            errors[0] = new ValidatorError(errorKey + "89");
            return errors;
        }
        if (exitcode != 0) {
            errorKey = errorKey + exitcode;
            if (!LocalizationService.getInstance().hasMessage(errorKey)) {
                errorKey = "certificate.config.error.127";
            }
            errors[0] = new ValidatorError(errorKey);
            return errors;
        }
        else {
            return null;
        }
    }

    protected void writeStringToFile() throws FileNotFoundException {
        String tmpDir = System.getProperty("java.io.tmpdir");

        this.certificateFileName = tmpDir + "/cert_text" +
            RandomStringUtils.randomAlphanumeric(13) + ".cert";

        FileOutputStream out = new FileOutputStream(this.certificateFileName);
        PrintStream printer = new PrintStream(out);
        try {
            printer.println(this.certificateText);
        }
        finally {
            printer.close();
        }
    }

    protected boolean deleteCertTempFile(String fileName) {
        File f = new File(fileName);
        return f.delete();
    }

    /**
     * Set the text of the cert.
     *
     * @param certTextIn to set
     */
    public void setCertificateText(String certTextIn) {
        this.certificateText = certTextIn;
    }

    /** @return Returns the certificateText. */
    public String getCertificateText() {
        return this.certificateText;
    }

    /** @return Returns the certificateFileName. */
    public String getCertificateFileName() {
        return certificateFileName;
    }

    /**
     * Indicates if the certificate activation should ignore version mismatches.
     *
     * @param ignoreVersionMismatchIn indicates if the activation will ignore
     *                                version mismatches
     */
    public void setIgnoreVersionMismatch(boolean ignoreVersionMismatchIn) {
        this.ignoreVersionMismatch = ignoreVersionMismatchIn;
    }
}
