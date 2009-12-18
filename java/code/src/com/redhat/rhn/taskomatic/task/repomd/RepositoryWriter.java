/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ClonedChannel;
import com.redhat.rhn.frontend.dto.PackageDto;

import org.apache.log4j.Logger;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.security.DigestInputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * 
 * @version $Rev $
 * 
 */
public class RepositoryWriter {

    private static final String PRIMARY_FILE = "primary.xml.gz.new";
    private static final String FILELISTS_FILE = "filelists.xml.gz.new";
    private static final String OTHER_FILE = "other.xml.gz.new";
    private static final String REPOMD_FILE = "repomd.xml.new";
    private static final String UPDATEINFO_FILE = "updateinfo.xml.gz.new";

    private Logger log = Logger.getLogger(RepositoryWriter.class);
    private String pathPrefix;
    private String mountPoint;
    private String checksumtype;

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
    public boolean isChannelRepodataStale(Channel channel) {
        File theFile = new File(mountPoint + File.separator + pathPrefix +
                File.separator + channel.getLabel() + File.separator +
                "repomd.xml");
        Date fileModifiedDate = new Date(theFile.lastModified());
        // the file Modified date should be getting set when the file
        // is moved into the correct location.
        log.info("File Modified Date:" + fileModifiedDate);
        log.info("Channel Modified Date:" + channel.getLastModified());
        return !fileModifiedDate.equals(channel.getLastModified());
    }
    /**
     * 
     * @param channel channelinfo for repomd file creation
     */
    public void writeRepomdFiles(Channel channel) {
        log.info("Generating new repository metatada for channel '" +
                channel.getLabel() + "' " + channel.getPackages().size() +
                " packages, " + channel.getErratas().size() + " updates");
        String prefix = mountPoint + File.separator + pathPrefix +
                File.separator + channel.getLabel() + File.separator;

        if (!new File(prefix).mkdirs() && !new File(prefix).exists()) {
            throw new RepomdRuntimeException("Unable to create directory: " +
                    prefix);
        }

        CompressingDigestOutputWriter primaryFile;
        CompressingDigestOutputWriter filelistsFile;
        CompressingDigestOutputWriter otherFile;

        // Get compatible checksumType
        this.checksumtype = channel.getChecksumType();
        
        log.info("Checksum Type Value" + this.checksumtype);

        // available digests:  MD2, MD5, SHA-1, SHA-256, SHA-384, SHA-512
        String checksum_algo = this.checksumtype;
        if (checksum_algo.toUpperCase().startsWith("SHA")) {
            checksum_algo = this.checksumtype.substring(0, 3) + "-" + this.checksumtype.substring(3);
        }

        try {
            primaryFile = new CompressingDigestOutputWriter(
                    new FileOutputStream(prefix + PRIMARY_FILE), checksum_algo);
            filelistsFile = new CompressingDigestOutputWriter(
                    new FileOutputStream(prefix + FILELISTS_FILE), checksum_algo);
            otherFile = new CompressingDigestOutputWriter(new FileOutputStream(
                    prefix + OTHER_FILE), checksum_algo);
        }
        catch (IOException e) {
            throw new RepomdRuntimeException(e);
        }

        BufferedWriter primaryBufferedWriter = new BufferedWriter(
                new OutputStreamWriter(primaryFile));
        BufferedWriter filelistsBufferedWriter = new BufferedWriter(
                new OutputStreamWriter(filelistsFile));
        BufferedWriter otherBufferedWriter = new BufferedWriter(
                new OutputStreamWriter(otherFile));

        PrimaryXmlWriter primary = new PrimaryXmlWriter(primaryBufferedWriter);
        FilelistsXmlWriter filelists = new FilelistsXmlWriter(
                filelistsBufferedWriter);
        OtherXmlWriter other = new OtherXmlWriter(otherBufferedWriter);

        Date start = new Date();
        primary.begin(channel);
        filelists.begin(channel);
        other.begin(channel);

        Iterator iter = RepomdWriter.getChannelPackageDtoIterator(channel);
        while (iter.hasNext()) {
            PackageDto pkgDto = (PackageDto) iter.next();
            primary.addPackage(pkgDto);
            filelists.addPackage(pkgDto);
            other.addPackage(pkgDto);

            try {
                primaryFile.flush();
                filelistsFile.flush();
                otherFile.flush();
            }
            catch (IOException e) {
                throw new RepomdRuntimeException(e);
            }
        }
        primary.end();
        filelists.end();
        other.end();

        try {
            primaryBufferedWriter.close();
            filelistsBufferedWriter.close();
            otherBufferedWriter.close();
        }
        catch (IOException e) {
            throw new RepomdRuntimeException(e);
        }

        RepomdIndexData primaryData = new RepomdIndexData(primaryFile
                .getCompressedChecksum(),
                primaryFile.getUncompressedChecksum(), channel
                        .getLastModified());
        RepomdIndexData filelistsData = new RepomdIndexData(filelistsFile
                .getCompressedChecksum(), filelistsFile
                .getUncompressedChecksum(), channel.getLastModified());
        RepomdIndexData otherData = new RepomdIndexData(otherFile
                .getCompressedChecksum(), otherFile.getUncompressedChecksum(),
                channel.getLastModified());

        log.info("Starting updateinfo generation for '" + channel.getLabel() +
                '"');
        log.info("Checksum Type Value for generate updateinfo" + this.checksumtype);
        RepomdIndexData updateinfoData = generateUpdateinfo(channel, prefix, 
                checksum_algo);

        RepomdIndexData groupsData = loadCompsFile(channel, checksum_algo);
        
        //Set the type so yum can read and perform checksum
        primaryData.setType(this.checksumtype);
        filelistsData.setType(this.checksumtype);
        otherData.setType(this.checksumtype);
        if (updateinfoData != null) {
            updateinfoData.setType(this.checksumtype);
        }
        
        if (groupsData != null) {
            groupsData.setType(this.checksumtype);
        }
        
        log.info("Primary xml's type" + primaryData.getType());
        log.info("filelists xml's type" + filelistsData.getType());
        log.info("other xml's type" + otherData.getType());
        
        FileWriter indexFile;

        try {
            indexFile = new FileWriter(prefix + REPOMD_FILE);
        }
        catch (IOException e) {
            throw new RepomdRuntimeException(e);
        }

        RepomdIndexWriter index = new RepomdIndexWriter(indexFile, primaryData,
                filelistsData, otherData, updateinfoData, groupsData);

        index.writeRepomdIndex();

        try {
            indexFile.close();
        }
        catch (IOException e) {
            throw new RepomdRuntimeException(e);
        }

        renameFiles(prefix, channel.getLastModified().getTime(),
                updateinfoData != null);

        log.info("Repository metadata generation for '" + channel.getLabel() +
                "' finished in " +
                (int) (new Date().getTime() - start.getTime()) / 1000 +
                " seconds");
    }

    /**
     * 
     * @param channel channel indo
     * @param checksumAlgo checksum algorithm
     * @return repomd index for given channel
     */
    private RepomdIndexData loadCompsFile(Channel channel, String checksumAlgo) {
        String relativeFilename;
        String compsMount = Config.get().getString(ConfigDefaults.MOUNT_POINT);
 
        if (channel.getComps() == null) {
            relativeFilename = getCompsFilePath(channel);
            if (relativeFilename == null) {
                return null;
            }
        }
        else {
            relativeFilename = channel.getComps().getRelativeFilename();
        }

        File compsFile = new File(compsMount + relativeFilename);
        FileInputStream stream;
        try {
            stream = new FileInputStream(compsFile);
        }
        catch (FileNotFoundException e) {
            return null;
        }

        DigestInputStream digestStream;
        try {
            digestStream = new DigestInputStream(stream, MessageDigest
                    .getInstance(checksumAlgo));
        }
        catch (NoSuchAlgorithmException nsae) {
            throw new RepomdRuntimeException(nsae);
        }
        byte[] bytes = new byte[10];

        try {
            while (digestStream.read(bytes) != -1) {
                // no-op
            }
        }
        catch (IOException e) {
            return null;
        }

        Date timeStamp = new Date(compsFile.lastModified());

        return new RepomdIndexData(StringUtil.getHexString(digestStream
                .getMessageDigest().digest()), null, timeStamp);
    }

    /**
     * TODO: This static comps paths should go away once 
     * we can get the paths directly from hosted through 
     * satellite-sync and only limit to supporting cloned.
     * @param channel channel object
     * @return compsPath comps file path
    */
    public String getCompsFilePath(Channel channel) {
        String compsPath = null;

        Map<String, String> compsMapping = new HashMap<String, String>();
        String rootClientPath = "/rhn/kickstart/ks-rhel-x86_64-client-5";
        String rootServerPath = "/rhn/kickstart/ks-rhel-x86_64-server-5";
        compsMapping.put("rhel-x86_64-client-5", 
              rootClientPath + "/Client/repodata/comps-rhel5-client-core.xml");
        compsMapping.put("rhel-x86_64-client-vt-5",
              rootClientPath + "/VT/repodata/comps-rhel5-vt.xml");
        compsMapping.put("rhel-x86_64-client-workstation-5",
              rootClientPath + "/Workstation/repodata/comps-rhel5-client-workstation.xml");
        compsMapping.put("rhel-x86_64-server-5", 
              rootServerPath + "/Server/repodata/comps-rhel5-server-core.xml");
        compsMapping.put("rhel-x86_64-server-vt-5",
              rootServerPath + "/VT/repodata/comps-rhel5-vt.xml");
        compsMapping.put("rhel-x86_64-server-cluster-5",
              rootServerPath + "/Cluster/repodata/comps-rhel5-cluster.xml");
        compsMapping.put("rhel-x86_64-server-cluster-storage-5",
              rootServerPath + "/ClusterStorage/repodata/comps-rhel5-cluster-st.xml");

        String[] arches = {"i386", "ia64", "s390x", "ppc"};
        Map<String, String> newCompsmap = new HashMap<String, String>();
        for (String k : compsMapping.keySet()) {
            for (String arch : arches) {
                newCompsmap.put(k.replace("x86_64", arch), 
                    compsMapping.get(k).replace("x86_64", arch));
            }
        }
        compsMapping.putAll(newCompsmap);
 
        if (compsMapping.containsKey(channel.getLabel())) {
            compsPath = compsMapping.get(channel.getLabel());
        }
        else if (channel.isCloned()) {
            // If its a cloned channel see if we can get the comps
            // from the original channel.
            ClonedChannel clonedCh = (ClonedChannel) channel;
            Channel origChannel = clonedCh.getOriginal();
            compsPath = compsMapping.get(origChannel.getLabel());
        }

        return compsPath;
    }

    /**
     * Generates update info for given channel
     * @param channel channel info
     * @param prefix repodata file prefix
     * @param checksumtype checksum type
     * @return repodata index
     */
    private RepomdIndexData generateUpdateinfo(Channel channel, String prefix, 
            String checksumtypeIn) {

        if (channel.getErratas().size() == 0) {
            return null;
        }

        CompressingDigestOutputWriter updateinfoFile;
        try {
            updateinfoFile = new CompressingDigestOutputWriter(
                    new FileOutputStream(prefix + UPDATEINFO_FILE), checksumtypeIn);
        }
        catch (FileNotFoundException e) {
            throw new RepomdRuntimeException(e);
        }
        BufferedWriter updateinfoBufferedWriter = new BufferedWriter(
                new OutputStreamWriter(updateinfoFile));
        UpdateInfoWriter updateinfo = new UpdateInfoWriter(
                updateinfoBufferedWriter);
        updateinfo.getUpdateInfo(channel);
        try {
            updateinfoBufferedWriter.close();
        }
        catch (IOException e) {
            throw new RepomdRuntimeException(e);
        }

        RepomdIndexData updateinfoData = new RepomdIndexData(updateinfoFile
                .getCompressedChecksum(), updateinfoFile
                .getUncompressedChecksum(), channel.getLastModified());
        return updateinfoData;
    }

    /**
     * Renames the repo cache files
     * @param prefix path prefix
     * @param lastModified file last_modified
     * @param doUpdateinfo
     */
    private void renameFiles(String prefix, Long lastModified,
            Boolean doUpdateinfo) {
        File primary = new File(prefix + PRIMARY_FILE);
        File filelists = new File(prefix + FILELISTS_FILE);
        File other = new File(prefix + OTHER_FILE);
        File repomd = new File(prefix + REPOMD_FILE);

        File updateinfo = null;
        if (doUpdateinfo) {
            updateinfo = new File(prefix + UPDATEINFO_FILE);
        }

        if (doUpdateinfo) {
            updateinfo.setLastModified(lastModified);
        }

        primary.setLastModified(lastModified);
        filelists.setLastModified(lastModified);
        other.setLastModified(lastModified);
        repomd.setLastModified(lastModified);

        if (doUpdateinfo) {
            updateinfo.renameTo(new File(prefix + "updateinfo.xml.gz"));
        }

        primary.renameTo(new File(prefix + "primary.xml.gz"));
        filelists.renameTo(new File(prefix + "filelists.xml.gz"));
        other.renameTo(new File(prefix + "other.xml.gz"));
        repomd.renameTo(new File(prefix + "repomd.xml"));

    }

    /**
     * Deletes repomd files
     * @param channelLabelToProcess channel label
     */
    public void deleteRepomdFiles(String channelLabelToProcess) {
        log.info("Removing " + channelLabelToProcess);
        String prefix = mountPoint + pathPrefix + File.separator +
                channelLabelToProcess;
        File primary = new File(prefix + File.separator + "primary.xml.gz");
        File filelists = new File(prefix + File.separator + "filelists.xml.gz");
        File other = new File(prefix + File.separator + "other.xml.gz");
        File repomd = new File(prefix + File.separator + "repomd.xml");
        File theDirectory = new File(prefix);

        if (!primary.delete()) {
            log.info("Couldn't remove " + prefix + PRIMARY_FILE);
        }
        if (!filelists.delete()) {
            log.info("Couldn't remove " + prefix + FILELISTS_FILE);
        }
        if (!other.delete()) {
            log.info("Couldn't remove " + prefix + OTHER_FILE);
        }
        if (!repomd.delete()) {
            log.info("Couldn't remove " + prefix + REPOMD_FILE);
        }
        if (!theDirectory.delete()) {
            log.info("Couldn't remove " + prefix);
        }
    }

}
