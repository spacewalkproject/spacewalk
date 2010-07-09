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
package com.redhat.rhn.domain.errata;

import com.redhat.rhn.domain.common.Checksum;
import com.redhat.rhn.domain.rhnpackage.Package;

import java.util.Date;
import java.util.Set;

/**
 * ErrataFile
 *
 * @version $Rev: $
 */
public interface ErrataFile {

    /**
     * Id
     * @param idIn id
     */
    void setId(Long idIn);

    /**
     * Id
     * @return id
     */
    Long getId();

    /**
     * File type
     * @param ft file type
     */
    void setFileType(ErrataFileType ft);

    /**
     * File type
     * @return file type
     */
    ErrataFileType getFileType();

    /**
     * MD5 checksum
     * @param cs checksums
     */
    void setChecksum(Checksum cs);

    /**
     * MD5 checksum
     * @return checksum
     */
    Checksum getChecksum();

    /**
     * File name
     * @param name file name
     */
    void setFileName(String name);

    /**
     * File name
     * @return file name
     */
    String getFileName();

    /**
     * Owning errata
     * @param errata owning errata
     */
    void setErrata(Errata errata);

    /**
     * Owning errata
     * @return owning errata
     */
    Errata getErrata();

    /**
     * Created
     * @param createdIn created
     */
    void setCreated(Date createdIn);

    /**
     * Created
     * @return created
     */
    Date getCreated();

    /**
     * Modified
     * @param mod modified
     */
    void setModified(Date mod);

    /**
     * Modified
     * @return modified
     */
    Date getModified();

    /**
     * @return Returns the packages for this errata file.
     */
    Set<Package> getPackages();

    /**
     * @param packagesIn The packages to set.
     */
    void setPackages(Set packagesIn);


    /**
     * Add a Package to the ErrataFile
     * @param p package to add
     */
    void addPackage(Package p);
}
