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
package com.redhat.rhn.taskomatic.task.repomd;

import java.io.File;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.task.TaskManager;

/**
*
* @version $Rev $
*
*/
public class DebRepositoryWriter extends RepositoryWriter {

    /**
     * Constructor takes in pathprefix and mountpoint
     * @param pathPrefixIn prefix to package path
     * @param mountPointIn mount point package resides
     */
    public DebRepositoryWriter(String pathPrefixIn, String mountPointIn) {
        super(pathPrefixIn, mountPointIn);
    }

    /**
    *
    * @param channel channel info
    * @return repodata sanity
    */
    public boolean isChannelRepodataStale(Channel channel) {
        return true;
    }

    /**
     * Create repository for APT
     * @param channel
     */
    public void writeRepomdFiles(Channel channel) {
        PackageManager.createRepoEntrys(channel.getId());

        String prefix = mountPoint + File.separator + pathPrefix +
        File.separator + channel.getLabel() + File.separator;

        // we closed the session, so we need to reload the object
        channel = (Channel) HibernateFactory.getSession().get(channel.getClass(),
                channel.getId());
        if (!new File(prefix).mkdirs() && !new File(prefix).exists()) {
            throw new RepomdRuntimeException("Unable to create directory: " +
                    prefix);
        }

        log.info("Generating new DEB repository for channel " + channel.getLabel());
        DebPackageWriter writer = new DebPackageWriter(channel, prefix);
        for (PackageDto pkgDto : TaskManager.getChannelPackageDtos(channel)) {
            writer.addPackage(pkgDto);
        }
        writer.generatePackagesGz();
	}

    public String getCompsFilePath(Channel channel) {
        return null;
    }
}
