/**
 * Copyright (c) 2009--2017 Red Hat, Inc.
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
package com.redhat.rhn.manager.channel.repo;

import com.redhat.rhn.common.client.InvalidCertificateException;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.domain.channel.ContentSourceType;
import com.redhat.rhn.domain.channel.SslContentSource;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.crypto.SslCryptoKey;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.xmlrpc.channel.repo.InvalidRepoLabelException;
import com.redhat.rhn.frontend.xmlrpc.channel.repo.InvalidRepoTypeException;
import com.redhat.rhn.frontend.xmlrpc.channel.repo.InvalidRepoUrlException;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;


/**
 * BaseRepoCommand - Command to create or edit a repo
 * @version $Rev: 119601 $
 */
public abstract class BaseRepoCommand {

    protected ContentSource repo;

    private String label;
    private String url;
    private String type;
    private Set<SslContentSource> sslSetsToAdd = new HashSet<SslContentSource>();
    private Set<SslContentSource> sslSetsToDelete = new HashSet<SslContentSource>();
    private Org org;

    /**
     *
     * @return Org of repo
     */
    public Org getOrg() {
        return org;
    }

    /**
     *
     * @param orgIn to set for repo
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    /**
     *
     * @return label for repo
     */
    public String getLabel() {
        return label;
    }

    /**
     *
     * @param labelIn to set for repo
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     *
     * @return url for repo
     */
    public String getUrl() {
        return url;
    }

    /**
     *
     * @param urlIn to set for repo
     */
    public void setUrl(String urlIn) {
        this.url = urlIn;
    }

    /**
     *
     * @return type of repo
     */
    public String getType() {
        return type;
    }

    /**
     *
     * @param typeIn to set type of repo
     */
    public void setType(String typeIn) {
        this.type = typeIn;
    }


    private SslContentSource createSslSet(Long sslCaCertId, Long sslClientCertId,
                          Long sslClientKeyId) throws InvalidCertificateException {
        SslCryptoKey caCert = lookupSslCryptoKey(sslCaCertId, org);
        SslCryptoKey clientCert = lookupSslCryptoKey(sslClientCertId, org);
        SslCryptoKey clientKey = lookupSslCryptoKey(sslClientKeyId, org);
        if (caCert == null) {
            return null;
        }
        else if (clientCert == null && clientKey != null) {
            throw new InvalidCertificateException(
                    "client key is provided but client certificate is missing");
        }
        SslContentSource sslSet = ChannelFactory.createRepoSslSet();
        sslSet.setCaCert(caCert);
        sslSet.setClientCert(clientCert);
        sslSet.setClientKey(clientKey);
        sslSet.setCreated(new Date());
        sslSet.setModified(new Date());
        return sslSet;
    }

    /**
     * Marks some SSL set for assigning to repository
     * @param sslCaCertId ca cert id
     * @param sslClientCertId client cert id
     * @param sslClientKeyId client key
     * @throws InvalidCertificateException in case ca cert is missing or client key is set,
     * but client certificate is missing
     */
    public void addSslSet(Long sslCaCertId, Long sslClientCertId, Long sslClientKeyId)
            throws InvalidCertificateException {
        SslContentSource sslSet = createSslSet(sslCaCertId, sslClientCertId,
                sslClientKeyId);
        if (sslSet != null) {
            sslSetsToAdd.add(sslSet);
            sslSetsToDelete.remove(sslSet);
        }
    }

    /**
     * Marks all assigned SSL sets for deletion
     */
    public void deleteAllSslSets() {
        if (repo != null) {
            Set<SslContentSource> repoSslSets = repo.getSslSets();
            sslSetsToDelete.addAll(repoSslSets);
            sslSetsToAdd.removeAll(repoSslSets);
        }
    }

    /**
     * Check for errors and store Org to db.
     * @throws InvalidRepoUrlException in case repo wih given url already exists
     * in the org
     * @throws InvalidRepoLabelException in case repo witch given label already exists
     * in the org
     * @throws InvalidRepoTypeException in case repo wih given type already exists
     * in the org
     */
    public void store() throws InvalidRepoUrlException, InvalidRepoLabelException,
            InvalidRepoTypeException {

        // create new repository
        if (repo == null) {
            this.repo = ChannelFactory.createRepo();
        }

        Set<SslContentSource> repoSslSets = repo.getSslSets();
        for (SslContentSource sslSet : sslSetsToAdd) {
            repoSslSets.add(sslSet);
        }
        for (SslContentSource sslSet : sslSetsToDelete) {
            repoSslSets.remove(sslSet);
        }

        repo.setOrg(org);

        if (this.label != null && !this.label.equals(repo.getLabel())) {
            if (ChannelFactory.lookupContentSourceByOrgAndLabel(org, label) != null) {
                throw new InvalidRepoLabelException(label);
            }
            repo.setLabel(this.label);
        }

        if (this.url != null && this.type != null) {
            ContentSourceType cst = ChannelFactory.lookupContentSourceType(this.type);
            boolean alreadyExists = !ChannelFactory.lookupContentSourceByOrgAndRepo(
                    org, cst, url).isEmpty();
            if (!this.url.equals(repo.getSourceUrl())) {
                if (alreadyExists) {
                    throw new InvalidRepoUrlException(url);
                }
                repo.setSourceUrl(this.url);
            }
            if (!cst.equals(repo.getType())) {
                if (alreadyExists) {
                    throw new InvalidRepoTypeException(this.type);
                }
                repo.setType(cst);
            }
        }

        ChannelFactory.save(repo);
        ChannelFactory.commitTransaction();
        ChannelFactory.closeSession();
    }

    /**
     * Get the repo
     * @return repo
     */
    public ContentSource getRepo() {
        return this.repo;
    }

    private SslCryptoKey lookupSslCryptoKey(Long keyId, Org orgIn) {
        if (keyId == null) {
            return null;
        }
        return KickstartFactory.lookupSslCryptoKeyById(keyId, orgIn);
    }
}
