/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.task.TaskManager;

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
import java.util.Calendar;
import java.util.Date;

/**
 *
 * @version $Rev $
 *
 */
public class RpmRepositoryWriter extends RepositoryWriter {

    private static final String PRIMARY_FILE = "primary.xml.gz.new";
    private static final String FILELISTS_FILE = "filelists.xml.gz.new";
    private static final String OTHER_FILE = "other.xml.gz.new";
    private static final String REPOMD_FILE = "repomd.xml.new";
    private static final String UPDATEINFO_FILE = "updateinfo.xml.gz.new";
    private static final String NOREPO_FILE = "noyumrepo.txt";

    private String checksumtype;

    /**
     * Constructor takes in pathprefix and mountpoint
     * @param pathPrefixIn prefix to package path
     * @param mountPointIn mount point package resides
     */
    public RpmRepositoryWriter(String pathPrefixIn, String mountPointIn) {
        super(pathPrefixIn, mountPointIn);
    }

    /**
     *
     * @param channel channel info
     * @return repodata sanity
     */
    @Override
    public boolean isChannelRepodataStale(Channel channel) {
        File theFile = new File(mountPoint + File.separator + pathPrefix +
                File.separator + channel.getLabel() + File.separator +
                "repomd.xml");
        // Init Date objects without milliseconds
        Calendar cal = Calendar.getInstance();
        cal.setTime(new Date(theFile.lastModified()));
        cal.set(Calendar.MILLISECOND, 0);
        Date fileModifiedDate = cal.getTime();
        cal.setTime(channel.getLastModified());
        cal.set(Calendar.MILLISECOND, 0);
        Date channelModifiedDate = cal.getTime();

        // the file Modified date should be getting set when the file
        // is moved into the correct location.
        log.info("File Modified Date:" + LocalizationService.getInstance().
                formatCustomDate(fileModifiedDate));
        log.info("Channel Modified Date:" + LocalizationService.getInstance().
                formatCustomDate(channelModifiedDate));
        return !fileModifiedDate.equals(channelModifiedDate);
    }

    /**
     *
     * @param channel channelinfo for repomd file creation
     */
    @Override
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
        // Get compatible checksumType
        this.checksumtype = channel.getChecksumTypeLabel();
        if (checksumtype == null) {
            generateBadRepo(channel, prefix);
            return;
        }
        new File(prefix + NOREPO_FILE).delete();
        if (log.isDebugEnabled()) {
            log.debug("Checksum Type Value: " + this.checksumtype);
        }

        // java.security.MessageDigest recognizes:
        // MD2, MD5, SHA-1, SHA-256, SHA-384, SHA-512
        String checksumAlgo = this.checksumtype;
        if (checksumAlgo.toUpperCase().startsWith("SHA")) {
            checksumAlgo = this.checksumtype.substring(0, 3) + "-" +
                    this.checksumtype.substring(3);
        }
        // translate sha1 to sha for xml repo files
        String checksumLabel = this.checksumtype;
        if (checksumLabel.equals("sha1")) {
            checksumLabel = "sha";
        }

        log.info("Generating new repository metadata for channel '" +
                channel.getLabel() + "'(" + this.checksumtype + ") " +
                channel.getPackageCount() + " packages, " +
                channel.getErrataCount() + " errata");

        CompressingDigestOutputWriter primaryFile;
        CompressingDigestOutputWriter filelistsFile;
        CompressingDigestOutputWriter otherFile;

        try {
            primaryFile = new CompressingDigestOutputWriter(
                    new FileOutputStream(prefix + PRIMARY_FILE),
                    checksumAlgo);
            filelistsFile = new CompressingDigestOutputWriter(
                    new FileOutputStream(prefix + FILELISTS_FILE),
                    checksumAlgo);
            otherFile = new CompressingDigestOutputWriter(
                    new FileOutputStream(prefix + OTHER_FILE), checksumAlgo);
        }
        catch (IOException e) {
            throw new RepomdRuntimeException(e);
        }
        catch (NoSuchAlgorithmException e) {
            throw new RepomdRuntimeException(e);
        }

        BufferedWriter primaryBufferedWriter = new BufferedWriter(
                new OutputStreamWriter(primaryFile));
        BufferedWriter filelistsBufferedWriter = new BufferedWriter(
                new OutputStreamWriter(filelistsFile));
        BufferedWriter otherBufferedWriter = new BufferedWriter(
                new OutputStreamWriter(otherFile));
        PrimaryXmlWriter primary = new PrimaryXmlWriter(
                primaryBufferedWriter);
        FilelistsXmlWriter filelists = new FilelistsXmlWriter(
                filelistsBufferedWriter);
        OtherXmlWriter other = new OtherXmlWriter(otherBufferedWriter);
        Date start = new Date();

        primary.begin(channel);
        filelists.begin(channel);
        other.begin(channel);

        // batch the elaboration so we don't have to hold many thousands of
        // packages in memory at once
        final int batchSize = 1000;
        DataResult<PackageDto> packages = TaskManager.getChannelPackageDtos(channel);
        for (int i = 0; i < packages.size(); i += batchSize) {
            DataResult<PackageDto> packageBatch = packages.subList(i, i + batchSize);
            packageBatch.elaborate();
            for (PackageDto pkgDto : packageBatch) {
                // this is a sanity check
                // package may have been deleted before packageBatch.elaborate()
                if (pkgDto.getChecksum() == null) {
                    // channel content changed, we cannot guarantee correct repodata
                    throw new RepomdRuntimeException("Package with id " + pkgDto.getId() +
                            " removed from server, interrupting repo generation for " +
                            channel.getLabel());
                }
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
                .getCompressedChecksum(), primaryFile
                .getUncompressedChecksum(), channel.getLastModified());
        RepomdIndexData filelistsData = new RepomdIndexData(filelistsFile
                .getCompressedChecksum(), filelistsFile
                .getUncompressedChecksum(), channel.getLastModified());
        RepomdIndexData otherData = new RepomdIndexData(otherFile
                .getCompressedChecksum(), otherFile
                .getUncompressedChecksum(), channel.getLastModified());

        if (log.isDebugEnabled()) {
            log.debug("Starting updateinfo generation for '" + channel.getLabel() + '"');
        }
        RepomdIndexData updateinfoData = generateUpdateinfo(channel,
                prefix, checksumAlgo);

        RepomdIndexData groupsData = loadCompsFile(channel, checksumAlgo);

        // Set the type so yum can read and perform checksum
        primaryData.setType(checksumLabel);
        filelistsData.setType(checksumLabel);
        otherData.setType(checksumLabel);
        if (updateinfoData != null) {
            updateinfoData.setType(checksumLabel);
        }

        if (groupsData != null) {
            groupsData.setType(checksumLabel);
        }

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

        log.info("Repository metadata generation for '" +
                channel.getLabel() + "' finished in " +
                (int) (new Date().getTime() - start.getTime()) / 1000 + " seconds");
    }

    /**
     * Deletes existing repo and generates file stating that no repo was generated
     * @param channel the channel to do this for
     * @param prefix the directory prefix
     */
    private void generateBadRepo(Channel channel, String prefix) {
        log.warn("No repo will be generated for channel " + channel.getLabel());
        deleteRepomdFiles(channel.getLabel(), false);
        try {
            FileWriter norepo = new FileWriter(prefix + NOREPO_FILE);
            norepo.write("No repo will be generated for channel " +
                    channel.getLabel() + ".\n");
            norepo.close();
        }
        catch (IOException e) {
            log.warn("Cannot create " + NOREPO_FILE + " file.");
        }
        return;
    }

    private String getCompsRelativeFilename(Channel channel) {
        if (channel.getComps() != null) {
            return channel.getComps().getRelativeFilename();
        }
        // if we didn't find anything, let's check channel's original
        if (channel.isCloned()) {
            // use a hack not to use ClonedChannel and it's getOriginal() method
            Long originalChannelId = ChannelManager.lookupOriginalId(channel);
            Channel originalChannel = ChannelFactory.lookupById(originalChannelId);
            return getCompsRelativeFilename(originalChannel);
        }

        return null;
    }

    /**
     *
     * @param channel channel indo
     * @param checksumAlgo checksum algorithm
     * @return repomd index for given channel
     */
    private RepomdIndexData loadCompsFile(Channel channel, String checksumAlgo) {
        String compsMount = Config.get().getString(ConfigDefaults.MOUNT_POINT);
        String relativeFilename = getCompsRelativeFilename(channel);

        if (relativeFilename == null) {
            return null;
        }

        File compsFile = new File(compsMount + File.separator + relativeFilename);
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
     * Generates update info for given channel
     * @param channel channel info
     * @param prefix repodata file prefix
     * @param checksumtype checksum type
     * @return repodata index
     */
    private RepomdIndexData generateUpdateinfo(Channel channel, String prefix,
            String checksumtypeIn) {

        if (channel.getErrataCount() == 0) {
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
        catch (NoSuchAlgorithmException e) {
            throw new RepomdRuntimeException(e);
        }
        catch (IOException e) {
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
}
