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
package com.redhat.rhn.manager.org;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.manager.kickstart.crypto.CreateCryptoKeyCommand;
import com.redhat.rhn.manager.user.CreateUserCommand;

import org.apache.log4j.Logger;

import java.util.List;

/**
 * CreateOrgCommand - Command to create an org and the first admin in the Org.
 * @version $Rev: 119601 $
 */
public class CreateOrgCommand {

    private String name;
    private String login;
    private String password;
    private String email;
    private Org newOrg;
    private String prefix;

    // first user name info
    private String fname;
    private String lname;
    private boolean usePam;

    private static Logger log = Logger.getLogger(CreateOrgCommand.class);

    /**
     * Constructor to create an org
     * @param nameIn to set on the org
     * @param loginIn to use for 1st user in org
     * @param passwordIn to set for first user
     * @param emailIn to set for first user
     */
    public CreateOrgCommand(String nameIn, String loginIn,
            String passwordIn, String emailIn) {
        this.name = nameIn;
        this.login = loginIn;
        this.password = passwordIn;
        this.email = emailIn;
    }

    /**
     *
     * @return prefix for user
     */
    public String getPrefix() {
        return prefix;
    }

    /**
     *
     * @param prefixIn prefix to set for user
     */
    public void setPrefix(String prefixIn) {
        this.prefix = prefixIn;
    }

    /**
     *
     * @param nameIn for org admin first name
     */
    public void setFirstName(String nameIn) {
        this.fname = nameIn;
    }

    /**
     *
     * @param nameIn for org admin last name
     */
    public void setLastName(String nameIn) {
        this.lname = nameIn;
    }

    /**
     * Check for errors and store Org to db.
     * @return ValidatorError[] array if there are errors
     */
    public ValidatorError[] store() {
        try {
            OrgManager.checkOrgName(this.name);
        }
        catch (ValidatorException ve) {
            return ve.getResult().getErrors().toArray(new ValidatorError[0]);
        }

        // Create org
        Org createdOrg = OrgFactory.createOrg();
        createdOrg.setName(this.name);
        // Create user
        CreateUserCommand cmd = new CreateUserCommand();
        cmd.setLogin(this.login);
        cmd.setMakeOrgAdmin(true);
        cmd.setPassword(this.password);
        cmd.setEmail(email);
        cmd.setUsePamAuthentication(this.usePam);
        cmd.setPrefix(this.prefix);

        if (this.fname != null) {
            cmd.setFirstNames(this.fname);
        }
        else {
            cmd.setFirstNames(
                LocalizationService.getInstance().getMessage("user.unspecified.name"));
            }

        if (this.lname != null) {
            cmd.setLastName(this.lname);
        }
        else {
            cmd.setLastName(
                LocalizationService.getInstance().getMessage("user.unspecified.name"));
            }

        ValidatorError[] errors = cmd.validate();
        if (errors != null && errors.length > 0) {
            return errors;
        }
        else {
            createdOrg = OrgFactory.save(createdOrg);
            cmd.setOrg(createdOrg);
            cmd.storeNewUser();
            this.newOrg = createdOrg;

            // Lookup the SSL crypto key for the default org and copy it to the new:
            Org defaultOrg = OrgFactory.getSatelliteOrg();
            List<CryptoKey> defaultOrgKeys = KickstartFactory.lookupCryptoKeys(defaultOrg);
            CryptoKey ssl = null;
            // Search for the first key of type ssl:
            for (CryptoKey key : defaultOrgKeys) {
                if (key.getCryptoKeyType().equals(KickstartFactory.KEY_TYPE_SSL)) {
                    ssl = key;
                    break;
                }
            }
            if (ssl != null) {
                // TODO
                log.debug("Found a SSL key for the default org to copy: " +
                        ssl.getId());
                CreateCryptoKeyCommand createCryptoKey =
                    new CreateCryptoKeyCommand(createdOrg);
                createCryptoKey.setContents(ssl.getKeyString());
                createCryptoKey.setDescription(ssl.getDescription());
                createCryptoKey.setType("SSL");
                createCryptoKey.store();
            }

            ChannelFamilyFactory.lookupOrCreatePrivateFamily(createdOrg);

            return null;
        }
    }

    /**
     * Get the newly created org.
     * @return Org that was stored to DB
     */
    public Org getNewOrg() {
        return this.newOrg;
    }

    /**
     *
     * @return use Pam auth
     */
    public boolean usePam() {
        return usePam;
    }

    /**
     *
     * @param usePamIn determines whether we use pam auth
     */
    public void setUsePam(boolean usePamIn) {
        this.usePam = usePamIn;
    }

}
