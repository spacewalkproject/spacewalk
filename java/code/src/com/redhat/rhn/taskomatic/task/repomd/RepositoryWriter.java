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

import com.redhat.rhn.domain.channel.Channel;

import org.apache.log4j.Logger;

import java.io.File;

/**
 *
 * @version $Rev $
 *
 */
public abstract class RepositoryWriter {

    protected Logger log = Logger.getLogger(RepositoryWriter.class);
    protected String pathPrefix;
    protected String mountPoint;

    /**
     * Constructor takes in pathprefix and mountpoint
     * @param pathPrefixIn prefix to package path
     * @param mountPointIn mount point package resides
     */
    public RepositoryWriter(String pathPrefixIn, String mountPointIn) {
        this.pathPrefix = pathPrefixIn;
        this.mountPoint = mountPointIn;
    }

    /**
    *
    * @param channel channel info
    * @return repodata sanity
    */
    public abstract boolean isChannelRepodataStale(Channel channel);

    /**
    *
    * @param channel channelinfo for repomd file creation
    */
   public abstract void writeRepomdFiles(Channel channel);

   /**
    * TODO: This static comps paths should go away once
    * we can get the paths directly from hosted through
    * satellite-sync and only limit to supporting cloned.
    * @param channel channel object
    * @return compsPath comps file path
   */
   public abstract String getCompsFilePath(Channel channel);

   /**
    * Deletes repomd files
    * @param channelLabelToProcess channel label
    * @param deleteDir directory to delete
    */
   public void deleteRepomdFiles(String channelLabelToProcess, boolean deleteDir) {
       log.info("Removing " + channelLabelToProcess);
       String prefix = mountPoint + File.separator + pathPrefix + File.separator +
               channelLabelToProcess;
       File primary = new File(prefix + File.separator + "primary.xml.gz");
       File filelists = new File(prefix + File.separator + "filelists.xml.gz");
       File other = new File(prefix + File.separator + "other.xml.gz");
       File repomd = new File(prefix + File.separator + "repomd.xml");
       File updateinfo = new File(prefix + File.separator + "updateinfo.xml.gz");
       File norepo = new File(prefix + File.separator + "noyumrepo.txt");
       File theDirectory = new File(prefix);

       if (!primary.delete()) {
           log.info("Couldn't remove " + primary.getAbsolutePath());
       }
       if (!filelists.delete()) {
           log.info("Couldn't remove " + filelists.getAbsolutePath());
       }
       if (!other.delete()) {
           log.info("Couldn't remove " + other.getAbsolutePath());
       }
       if (!repomd.delete()) {
           log.info("Couldn't remove " + repomd.getAbsolutePath());
       }
       updateinfo.delete();
       norepo.delete();
       if (deleteDir) {
           if (!theDirectory.delete()) {
               log.info("Couldn't remove " + prefix);
           }
       }
   }
}
