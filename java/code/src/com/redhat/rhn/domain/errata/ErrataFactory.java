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
/*
 * Copyright (c) 2010 SUSE LLC
 */
package com.redhat.rhn.domain.errata;

import com.redhat.rhn.common.db.DatabaseException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateRuntimeException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.common.ChecksumFactory;
import com.redhat.rhn.domain.errata.impl.PublishedBug;
import com.redhat.rhn.domain.errata.impl.PublishedClonedErrata;
import com.redhat.rhn.domain.errata.impl.PublishedErrata;
import com.redhat.rhn.domain.errata.impl.PublishedErrataFile;
import com.redhat.rhn.domain.errata.impl.UnpublishedBug;
import com.redhat.rhn.domain.errata.impl.UnpublishedClonedErrata;
import com.redhat.rhn.domain.errata.impl.UnpublishedErrata;
import com.redhat.rhn.domain.errata.impl.UnpublishedErrataFile;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.manage.PublishErrataHelper;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.dto.ErrataPackageFile;
import com.redhat.rhn.frontend.dto.OwnedErrata;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;

import org.apache.commons.collections.IteratorUtils;
import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;

/**
 * ErrataFactory - the singleton class used to fetch and store
 * com.redhat.rhn.domain.errata.Errata objects from the
 * database.
 * @version $Rev$
 */
public class ErrataFactory extends HibernateFactory {

    private static ErrataFactory singleton = new ErrataFactory();
    private static Logger log = Logger.getLogger(ErrataFactory.class);

    public static final String ERRATA_TYPE_BUG = "Bug Fix Advisory";
    public static final String ERRATA_TYPE_ENHANCEMENT = "Product Enhancement Advisory";
    public static final String ERRATA_TYPE_SECURITY = "Security Advisory";

    private ErrataFactory() {
        super();
    }

    /**
     * Get the Logger for the derived class so log messages
     * show up on the correct class
     */
    @Override
    protected Logger getLogger() {
        return log;
    }

    /**
     * List the package ids that were pushed to a channel because of an errata
     * @param cid the channel id
     * @param eid the errata id
     * @return List of package ids
     */
    public static List<Long> listErrataChannelPackages(Long cid, Long eid) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("channel_id", cid);
        params.put("errata_id", eid);
        DataResult<ErrataPackageFile> dr = executeSelectMode(
                "ErrataCache_queries",
                "package_associated_to_errata_and_channel", params);
        List toReturn = new ArrayList<Long>();
        for (ErrataPackageFile file : dr) {
            toReturn.add(file.getPackageId());
        }
        return toReturn;
    }



    /**
     * Tries to locate errata based on either the errataum's id or the
     * CVE/CAN identifier string.
     * @param identifier erratum id or CVE/CAN id string
     * @param org User organization
     * @return list of erratas found
     */
    public static List lookupByIdentifier(String identifier, Org org) {
        Long eid = null;
        List retval = new LinkedList();
        Errata errata = null;
        try {
            eid = new Long(Long.parseLong(identifier));
        }
        catch (NumberFormatException e) {
            eid = null;
        }
        if (eid != null) {
            errata = ErrataFactory.lookupPublishedErrataById(eid);
            if (errata != null) {
                retval.add(errata);
            }
        }
        else if (identifier.length() > 4) {
            String prefix = null;
            errata = ErrataFactory.lookupByAdvisoryId(identifier, org);
            if (errata != null) {
                retval.add(errata);
            }
            else {
                errata = ErrataFactory.lookupByAdvisory(identifier, org);
                if (errata != null) {
                    retval.add(errata);
                }
            }
            if (errata == null) {
                prefix = identifier.substring(0, 4);
                if (prefix.matches("RH.A")) {
                    StringTokenizer strtok = new StringTokenizer(identifier, "-");
                    StringBuilder buf = new StringBuilder();
                    boolean foundFirst = false;
                    while (strtok.hasMoreTokens()) {
                        buf.append(strtok.nextToken());
                        if (!foundFirst) {
                            buf.append("-");
                            foundFirst = true;
                        }
                        else {
                            if (strtok.hasMoreTokens()) {
                                buf.append(":");
                            }
                        }
                    }
                    identifier = buf.toString();
                    errata = ErrataFactory.lookupByAdvisoryId(identifier, org);
                }
                if (errata != null) {
                    retval.add(errata);
                }
            }
            if (errata == null) {
                prefix = identifier.substring(0, 3);
                if ((prefix.equals("CVE") || prefix.equals("CAN")) &&
                        identifier.length() > 7 && identifier.indexOf('-') == -1) {
                    identifier = identifier.substring(0, 3) + "-" +
                            identifier.substring(3, 7) + "-" +
                            identifier.substring(7);
                }
                List erratas = ErrataFactory.lookupByCVE(identifier);
                retval.addAll(erratas);
            }
        }
        return retval;
    }

    /**
     * publish takes an unpublished errata and copies its contents into a Published Errata
     * object (and then returns this object). This method also handles removing the old
     * Unpublished Errata object and child elements from the db.
     * @param unpublished The Errata to publish
     * @return Returns a published errata.
     */
    public static Errata publish(Errata unpublished) {
        //Make sure the errata we're publishing is unpublished
        if (unpublished.isPublished()) {
            return unpublished; //there is nothing we can do here
        }
        //Create a published errata using unpublished

        Errata published;

        if (unpublished.isCloned()) {
            published = new PublishedClonedErrata();
            ((PublishedClonedErrata)published).setOriginal(
                    ((UnpublishedClonedErrata)unpublished).getOriginal());
        }
        else {
            published = ErrataFactory.createPublishedErrata();
        }

        copyDetails(published, unpublished, false);

        //Save the published Errata
        save(published);

        //Remove the unpublished Errata from db
        try {
            Session session = HibernateFactory.getSession();
            session.delete(unpublished);
        }
        catch (HibernateException e) {
            throw new HibernateRuntimeException(
                    "Errors occurred while publishing errata", e);
        }

        //return the published errata
        return published;
    }

    /**
     * Takes a published or unpublished errata and publishes to a channel, creating
     *      all of the correct ErrataFile* entries.  This method does push packages to
     *      the appropriate channel. (Appropriate as defined as the channel previously
     *      having a package with the same name).
     * @param errataList list of errata to publish
     * @param chan channel to publish it into.
     * @param user the user doing the pushing
     * @param inheritPackages include only original channel packages
     * @return the published errata
     */
    public static List<Errata> publishToChannel(List<Errata> errataList, Channel chan,
            User user, boolean inheritPackages) {
        return publishToChannel(errataList, chan, user, inheritPackages, true);
    }

    /**
     * Takes a published or unpublished errata and publishes to a channel, creating
     *      all of the correct ErrataFile* entries.  This method does push packages to
     *      the appropriate channel. (Appropriate as defined as the channel previously
     *      having a package with the same name).
     * @param errataList list of errata to publish
     * @param chan channel to publish it into.
     * @param user the user doing the pushing
     * @param inheritPackages include only original channel packages
     * @param performPostActions true (default) if you want to refresh newest package
     * cache and schedule repomd regeneration. False only if you're going to do those
     * things yourself.
     * @return the published errata
     */
    public static List<Errata> publishToChannel(List<Errata> errataList, Channel chan,
            User user, boolean inheritPackages, boolean performPostActions) {
        List<com.redhat.rhn.domain.errata.Errata> toReturn = new ArrayList<Errata>();
        for (Errata errata : errataList) {
            if (!errata.isPublished()) {
                errata = publish(errata);
            }
            errata.addChannel(chan);
            errata.addChannelNotification(chan, new Date());

            Set<Package> packagesToPush = new HashSet<Package>();
            DataResult<PackageOverview> packs;
            if (inheritPackages) {

                if (!chan.isCloned()) {
                    throw new InvalidChannelException("Cloned channel expected: " +
                            chan.getLabel());
                }
                Channel original = chan.getOriginal();
                // see BZ 805714, if we are a clone of a clone the 1st clone
                // may not have the errata we want
                Set<Channel> associatedChannels = errata.getChannels();
                while (original.isCloned() &&
                        !associatedChannels.contains(original)) {
                    original = ChannelFactory.lookupOriginalChannel(original);
                }
                packs = ErrataManager.listErrataChannelPacks(original, errata, user);
            }
            else {
                packs = ErrataManager.lookupPacksFromErrataForChannel(chan, errata, user);
            }

            for (PackageOverview packOver : packs) {
                //lookup the Package object
                Package pack = PackageFactory.lookupByIdAndUser(
                        packOver.getId().longValue(), user);
                packagesToPush.add(pack);
            }

            Errata e = publishErrataPackagesToChannel(errata, chan, user, packagesToPush);
            toReturn.add(e);
        }
        if (performPostActions) {
            postPublishActions(chan, user);
        }
        return toReturn;
    }

    /**
     * Publish an errata to a channel but only push a small set of packages
     * along with it
     *
     * @param errata   errata to publish
     * @param chan channel to publish it into.
     * @param user the user doing the pushing
     * @param packages the packages to push
     * @return the published errata
     */
    public static Errata publishToChannel(Errata errata, Channel chan, User user,
            Set<Package> packages) {
        if (!errata.isPublished()) {
            errata = publish(errata);
        }
        errata.addChannel(chan);
        errata = publishErrataPackagesToChannel(errata, chan, user, packages);
        postPublishActions(chan, user);
        return errata;
    }


    private static void postPublishActions(Channel chan, User user) {
        ChannelManager.refreshWithNewestPackages(chan,
            "java::publishErrataPackagesToChannel");
    }


    /**
     * Private helper method that pushes errata packages to a channel
     */
    private static Errata publishErrataPackagesToChannel(Errata errata,
            Channel chan, User user, Set<Package> packages) {
        // Much quicker to push all packages at once
        List<Long> pids = new ArrayList<Long>();
        for (Package pack : packages) {
            pids.add(pack.getId());
        }
        ChannelManager.addPackages(chan, pids, user);

        for (Package pack : packages) {
            List<ErrataFile> publishedFiles = ErrataFactory.lookupErrataFile(
                    errata, pack);
            Map<String, ErrataFile> toAdd = new HashMap();
            if (publishedFiles.size() == 0) {
                // Now create the appropriate ErrataFile object
                String path = pack.getPath();
                if (path == null) {
                    throw new DatabaseException("Package " + pack.getId() +
                        " has NULL path, please run spacewalk-data-fsck");
                }
                ErrataFile publishedFile = ErrataFactory
                        .createPublishedErrataFile(ErrataFactory
                                .lookupErrataFileType("RPM"), pack
                                .getChecksum().getChecksum(), path);
                publishedFile.addPackage(pack);
                publishedFile.setErrata(errata);
                publishedFile.setModified(new Date());
                ((PublishedErrataFile) publishedFile).addChannel(chan);
                singleton.saveObject(publishedFile);
            }
            else {
                for (ErrataFile publishedFile : publishedFiles) {
                    String fileName = publishedFile.getFileName().substring(
                            publishedFile.getFileName().lastIndexOf("/") + 1);
                    if (!toAdd.containsKey(fileName)) {
                        toAdd.put(fileName, publishedFile);
                        ((PublishedErrataFile) publishedFile).addChannel(chan);
                        singleton.saveObject(publishedFile);
                    }
                }
            }

        }
        ChannelFactory.save(chan);
        List chanList = new ArrayList();
        chanList.add(chan.getId());

        ErrataCacheManager.insertCacheForChannelErrataAsync(chanList, errata);

        return errata;
    }

    /**
     * @param org Org performing the cloning
     * @param e Errata to be cloned
     * @return clone of e
     */
    public static Errata createClone(Org org, Errata e) {

        UnpublishedClonedErrata clone = new UnpublishedClonedErrata();

        copyDetails(clone, e, true);

        PublishErrataHelper.setUniqueAdvisoryCloneName(e, clone);
        clone.setOriginal(e);
        clone.setOrg(org);

        save(clone);
        return clone;
    }

    /**
     * Helper method to copy the details for.
     * @param copy The object to copy into.
     * @param original The object to copy from.
     * @param clone  set to true if this is a cloned errata, and thus
     *      things like org or advisory name shouldn't be set
     */
    private static void copyDetails(Errata copy, Errata original, boolean clone) {

        //Set the easy things first ;)

        if (!clone) {
            copy.setAdvisory(original.getAdvisory());
            copy.setAdvisoryName(original.getAdvisoryName());
            copy.setOrg(original.getOrg());
        }

        copy.setAdvisoryType(original.getAdvisoryType());
        copy.setProduct(original.getProduct());
        copy.setErrataFrom(original.getErrataFrom());
        copy.setDescription(original.getDescription());
        copy.setSynopsis(original.getSynopsis());
        copy.setTopic(original.getTopic());
        copy.setSolution(original.getSolution());
        copy.setIssueDate(original.getIssueDate());
        copy.setUpdateDate(original.getUpdateDate());
        copy.setNotes(original.getNotes());
        copy.setRefersTo(original.getRefersTo());
        copy.setAdvisoryRel(original.getAdvisoryRel());
        copy.setLocallyModified(original.getLocallyModified());
        copy.setLastModified(original.getLastModified());
        copy.setSeverity(original.getSeverity());


        /*
         * Copy the packages
         * packages aren't published or unpublished exactly... that is determined
         * by the status of the errata...
         */
        copy.setPackages(new HashSet(original.getPackages()));

        /*
         * Copy the keywords
         * if we use the string version of addKeyword, we don't have to worry about
         * whether or not the keyword is published.
         */
        Iterator keysItr = IteratorUtils.getIterator(original.getKeywords());
        while (keysItr.hasNext()) {
            Keyword k = (Keyword) keysItr.next();
            copy.addKeyword(k.getKeyword());
        }


        /*
         * Copy the bugs. If copy is published, then the bugs should be published as well.
         * If not, then we want unpublished bugs.
         */
        Iterator bugsItr = IteratorUtils.getIterator(original.getBugs());
        while (bugsItr.hasNext()) {
            Bug bugIn = (Bug) bugsItr.next();
            Bug cloneB;
            if (copy.isPublished()) { //we want published bugs
                cloneB = ErrataManager.createNewPublishedBug(bugIn.getId(),
                        bugIn.getSummary(),
                        bugIn.getUrl());
            }
            else { //we want unpublished bugs
                cloneB = ErrataManager.createNewUnpublishedBug(bugIn.getId(),
                        bugIn.getSummary(),
                        bugIn.getUrl());
            }
            copy.addBug(cloneB);
        }
    }

    /**
     * Create a new PublishedErrata from scratch
     * @return the PublishedErrata created
     */
    public static Errata createPublishedErrata() {
        return new PublishedErrata();
    }

    /**
     * Create a new UnpublishedErrata
     * @return the UnpublishedErrata created
     */
    public static Errata createUnpublishedErrata() {
        return new UnpublishedErrata();
    }

    /**
     * Creates a new Unpublished Bug object with the given id and summary.
     * @param id The id for the new bug
     * @param summary The summary for the new bug
     * @param url The bug URL
     * @return The new unpublished bug.
     */
    public static Bug createUnpublishedBug(Long id, String summary, String url) {
        Bug bug = new UnpublishedBug();
        bug.setId(id);
        bug.setSummary(summary);
        bug.setUrl(url);
        return bug;
    }

    /**
     * Creates a new Published Bug object with the given id and summary.
     * @param id The id for the new bug
     * @param summary The summary for the new bug
     * @param url The bug URL
     * @return The new published bug.
     */
    public static Bug createPublishedBug(Long id, String summary, String url) {
        Bug bug = new PublishedBug();
        bug.setId(id);
        bug.setSummary(summary);
        bug.setUrl(url);
        return bug;
    }



    /**
     * Creates a new Unpublished Errata file with given ErrataFileType, checksum, and name
     * @param ft ErrataFileType for the new ErrataFile
     * @param cs MD5 Checksum for the new Errata File
     * @param name name for the file
     * @param packages Packages associated with this errata file.
     * @return new Unpublished Errata File
     */
    public static ErrataFile createUnpublishedErrataFile(ErrataFileType ft,
            String cs,
            String name,
            Set packages) {
        ErrataFile file = new UnpublishedErrataFile();
        file.setFileType(ft);
        file.setChecksum(ChecksumFactory.safeCreate(cs, "md5"));
        file.setFileName(name);
        file.setPackages(packages);
        return file;
    }

    /**
     * Creates a new Published Errata file with given ErrataFileType, checksum, and name
     * @param ft ErrataFileType for the new ErrataFile
     * @param cs MD5 Checksum for the new Errata File
     * @param name name for the file
     * @return new Published Errata File
     */
    public static ErrataFile createPublishedErrataFile(ErrataFileType ft,
            String cs,
            String name) {
        return createPublishedErrataFile(ft, cs, name, new HashSet());
    }

    /**
     * Creates a new Published Errata file with given ErrataFileType, checksum, and name
     * @param ft ErrataFileType for the new ErrataFile
     * @param cs MD5 Checksum for the new Errata File
     * @param name name for the file
     * @param packages Packages associated with this errata file.
     * @return new Published Errata File
     */
    public static ErrataFile createPublishedErrataFile(ErrataFileType ft,
            String cs,
            String name,
            Set packages) {
        ErrataFile file = new PublishedErrataFile();
        file.setFileType(ft);
        file.setChecksum(ChecksumFactory.safeCreate(cs, "md5"));
        file.setFileName(name);
        file.setPackages(packages);
        return file;
    }

    /**
     * Lookup a ErrataFileType based on a label
     * @param label file type label (RPM, IMG, etc)
     * @return ErrataFileType instance
     */
    public static ErrataFileType lookupErrataFileType(String label) {
        Session session = null;
        ErrataFileType retval = null;
        try {
            session = HibernateFactory.getSession();
            retval = (ErrataFileType) session.getNamedQuery("ErrataFileType.findByLabel")
                    .setString("label", label).setCacheable(true).uniqueResult();
        }
        catch (HibernateException e) {
            throw new HibernateRuntimeException(e.getMessage(), e);
        }
        return retval;
    }

    /**
     * Lookup ErrataFiles by errata and file type
     * @param errataId errata id
     * @param fileType file type label
     * @return list of ErrataFile instances
     */
    public static List lookupErrataFilesByErrataAndFileType(Long errataId,
            String fileType) {
        Session session = null;
        List retval = null;
        try {
            session = HibernateFactory.getSession();
            Query q = session.getNamedQuery("PublishedErrataFile.listByErrataAndFileType");
            q.setLong("errata_id", errataId.longValue());
            q.setString("file_type", fileType.toUpperCase());
            retval =  q.list();

            if (retval == null) {
                q = session.getNamedQuery("UnpublishedErrataFile.listByErrataAndFileType");
                q.setLong("errata_id", errataId.longValue());
                q.setString("file_type", fileType.toUpperCase());
                retval =  q.list();
            }
        }
        catch (HibernateException e) {
            throw new HibernateRuntimeException(e.getMessage(), e);
        }
        return retval;


    }


    /**
     * Lookup a Errata by their id
     * @param id the id to search for
     * @return the Errata found
     */
    public static Errata lookupById(Long id) {
        //Look for published Errata first
        Session session = HibernateFactory.getSession();
        Errata errata = (Errata) session.get(PublishedErrata.class, id);

        //If we nothing was found, look for it in the Unpublished Errata table...
        if (errata == null) {
            errata = (Errata) session.get(UnpublishedErrata.class, id);
        }
        return errata;
    }

    /**
     * Lookup a Errata by the advisoryType string
     * @param advisoryType to search for
     * @return the Errata found
     */
    public static List lookupErratasByAdvisoryType(String advisoryType) {
        Session session = null;
        List retval = null;
        try {
            session = HibernateFactory.getSession();
            retval = session.getNamedQuery("PublishedErrata.findByAdvisoryType")
                    .setString("type", advisoryType)
                    //Retrieve from cache if there
                    .setCacheable(true).list();
        }
        catch (HibernateException he) {
            log.error("Error loading ActionArchTypes from DB", he);
            throw new
            HibernateRuntimeException("Error loading ActionArchTypes from db");
        }
        return retval;
    }

    /**
     * Finds published errata by id
     * @param id errata id
     * @return Errata if found, otherwise null
     */
    public static Errata lookupPublishedErrataById(Long id) {
        Session session = null;
        Errata retval = null;
        try {
            session = HibernateFactory.getSession();
            retval = (Errata) session.getNamedQuery("PublishedErrata.findById")
                    .setLong("id", id.longValue()).uniqueResult();
        }
        catch (HibernateException he) {
            log.error("Error loading ActionArchTypes from DB", he);
            throw new
            HibernateRuntimeException("Error loading ActionArchTypes from db");
        }
        return retval;
    }

    /**
     * Look up an errata by the advisory name. This is a unique field in the db and this
     * method is needed to help us see if a created/edited advisoryName is unique.
     * @param advisory The advisory to lookup
     * @param org User organization
     * @return Returns the errata corresponding to the passed in advisory name.
     */
    public static Errata lookupByAdvisory(String advisory, Org org) {
        Session session = null;
        Errata retval = null;
        //  try {
        //look for a published errata first
        session = HibernateFactory.getSession();
        retval = (Errata) session.getNamedQuery("PublishedErrata.findByAdvisoryName")
                .setParameter("advisory", advisory)
                .setParameter("org", org)
                .uniqueResult();
        //if nothing was found, check the unpublished errata table
        if (retval == null) {
            retval = (Errata)
                    session.getNamedQuery("UnpublishedErrata.findByAdvisoryName")
                    .setParameter("advisory", advisory)
                    .setParameter("org", org)
                    .uniqueResult();
        }
        //      }
        //      catch (HibernateException e) {
        //          throw new
        //            HibernateRuntimeException("Error looking up errata by advisory name");
        //       }
        return retval;
    }

    /**
     * Finds errata based on advisory id
     * @param advisoryId errata advisory id
     * @param org User organization
     * @return Errata if found, otherwise null
     */
    public static Errata lookupByAdvisoryId(String advisoryId, Org org) {
        Session session = null;
        Errata retval = null;
        try {
            //look for a published errata first
            session = HibernateFactory.getSession();
            retval = (Errata) session.getNamedQuery("PublishedErrata.findByAdvisory")
                    .setParameter("advisory", advisoryId)
                    .setParameter("org", org)
                    .uniqueResult();

            if (retval == null) {
                retval = (Errata)
                        session.getNamedQuery("UnpublishedErrata.findByAdvisory")
                        .setParameter("advisory", advisoryId)
                        .setParameter("org", org)
                        .uniqueResult();
            }
        }
        catch (HibernateException e) {

            throw new
            HibernateRuntimeException("Error looking up errata by advisory name");
        }
        return retval;
    }

    /**
     * Finds errata based on CVE string
     * @param cve cve text
     * @return Errata if found, otherwise null
     */
    public static List lookupByCVE(String cve) {
        List retval = new LinkedList();
        SelectMode mode = ModeFactory.getMode("Errata_queries", "erratas_for_cve");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cve", cve);
        List result = mode.execute(params);
        Session session = HibernateFactory.getSession();
        for (Iterator iter = result.iterator(); iter.hasNext();) {
            Map row = (Map) iter.next();
            Long rawId = (Long) row.get("id");
            retval.add(session.load(PublishedErrata.class, rawId));
        }
        return retval;
    }

    /**
     * Lookup all the clones of a particular errata
     * @param org Org that the clones belongs to
     * @param original Original errata that the clones are clones of
     * @return list of clones of the errata
     */
    public static List lookupByOriginal(Org org, Errata original) {
        Session session = null;
        List retval = null;

        try {
            session = HibernateFactory.getSession();
            retval = session.
                    getNamedQuery("UnpublishedClonedErrata.findByOriginal")
                    .setParameter("original", original)
                    .setParameter("org", org).list();

            if (retval == null) {
                retval = lookupPublishedByOriginal(org, original);
            }

        }
        catch (HibernateException e) {
            throw new
            HibernateRuntimeException("Error looking up errata by original errata");
        }
        return retval;
    }

    /**
     * Lookup all the clones of a particular errata
     * @param org Org that the clones belongs to
     * @param original Original errata that the clones are clones of
     * @return list of clones of the errata
     */
    public static List lookupPublishedByOriginal(Org org, Errata original) {
        Session session = null;
        List retval = null;

        try {
            session = HibernateFactory.getSession();
            retval = session.getNamedQuery("PublishedClonedErrata.findByOriginal")
                    .setParameter("original", original)
                    .setParameter("org", org).list();
        }
        catch (HibernateException e) {
            throw new
            HibernateRuntimeException("Error looking up errata by original errata");
        }
        return retval;
    }

    /**
     * Lists errata present in both channels
     * @param org orgaznization
     * @param channelFrom channel1
     * @param channelTo channel2
     * @return list of errata
     */
    public static List listSamePublishedInChannels(Org org, Channel channelFrom,
            Channel channelTo) {
        Session session = null;
        List retval = null;

        try {
            session = HibernateFactory.getSession();
            retval = session.getNamedQuery("PublishedErrata.findSameInChannels")
                    .setParameter("channel_from", channelFrom)
                    .setParameter("channel_to", channelTo).list();
        }
        catch (HibernateException e) {
            throw new
            HibernateRuntimeException("Error looking up errata by original errata");
        }
        return retval;
    }

    /**
     * Lists errata from channelFrom, that are cloned from the same original
     * as errata in channelTo
     * @param org orgaznization
     * @param channelFrom channel1
     * @param channelTo channel2
     * @return list of errata
     */
    public static List listPublishedBrothersInChannels(Org org, Channel channelFrom,
            Channel channelTo) {
        Session session = null;
        List retval = null;

        try {
            session = HibernateFactory.getSession();
            retval = session.getNamedQuery("PublishedClonedErrata.findBrothersInChannel")
                    .setParameter("channel_from", channelFrom)
                    .setParameter("channel_to", channelTo).list();
        }
        catch (HibernateException e) {
            throw new
            HibernateRuntimeException("Error looking up errata by original errata");
        }
        return retval;
    }

    /**
     * Lists errata from channelFrom, that have clones in channelTo
     * @param org orgaznization
     * @param channelFrom channel1
     * @param channelTo channel2
     * @return list of errata
     */
    public static List listPublishedClonesInChannels(Org org, Channel channelFrom,
            Channel channelTo) {
        Session session = null;
        List retval = null;

        try {
            session = HibernateFactory.getSession();
            retval = session.getNamedQuery("PublishedErrata.findClonesInChannel")
                    .setParameter("channel_from", channelFrom)
                    .setParameter("channel_to", channelTo)
                    .list();
        }
        catch (HibernateException e) {
            throw new
            HibernateRuntimeException("Error looking up errata by original errata");
        }
        return retval;
    }

    /**
     * Insert or Update a Errata.
     * @param errataIn Errata to be stored in database.
     */
    public static void save(Errata errataIn) {
        singleton.saveObject(errataIn);
    }

    /**
     * Delete a bug
     * @param deleteme Bug to delete
     */
    public static void removeBug(Bug deleteme) {
        singleton.removeObject(deleteme);
    }

    /**
     * Delete a Keyword
     * @param deleteme Keyword to delete
     */
    public static void remove(Keyword deleteme) {
        singleton.removeObject(deleteme);
    }


    /**
     * Remove a file.
     * @param deleteme ErrataFile to delete
     */
    public static void removeFile(ErrataFile deleteme) {
        singleton.removeObject(deleteme);
    }


    /**
     * Lists errata assigned to a particular channel,
     *          sorted by date (from oldest to newest)
     * @param org the Org in question
     * @param channel the channel you want to get the errata for
     * @return A list of Errata objects
     */
    public static List lookupByChannelSorted(Org org, Channel channel) {

        return HibernateFactory.getSession().
                getNamedQuery("PublishedErrata.lookupSortedByChannel")
                .setParameter("org", org)
                .setParameter("channel", channel)
                .list();
    }

    /**
     * Lists errata assigned to a particular channel between
     * the given start and end date. The list is sorted by date
     * (from oldest to newest).
     * @param org the Org in question
     * @param channel the channel you want to get the errata for
     * @param startDate the start date
     * @param endDate the end date
     * @return A list of Errata objects
     */
    public static List<Errata> lookupByChannelBetweenDates(Org org, Channel channel,
            String startDate, String endDate) {

        return HibernateFactory.getSession().
                getNamedQuery("PublishedErrata.lookupByChannelBetweenDates")
                .setParameter("org", org)
                .setParameter("channel", channel)
                .setParameter("start_date", startDate)
                .setParameter("end_date", endDate)
                .list();
    }





    /**
     * Lookup an errataFile object by it's errata and package
     * @param errata the errata associated
     * @param pack the package associated
     * @return the requested errata file object
     */
    public static List<ErrataFile> lookupErrataFile(Errata errata, Package pack) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("errata", errata);
        params.put("package", pack);
        return  singleton.listObjectsByNamedQuery(
                "PublishedErrataFile.lookupByErrataAndPackage", params);
    }

    /**
     * Returns a list of ErrataOverview that match the given errata ids.
     * @param eids Errata ids.
     * @param org Organization to match results with
     * @return a list of ErrataOverview that match the given errata ids.
     */
    public static List<ErrataOverview> search(List eids, Org org) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eids", eids);
        params.put("org_id", org.getId());
        List results = singleton.listObjectsByNamedQuery(
                "PublishedErrata.searchById", params);
        List<ErrataOverview> errata = new ArrayList<ErrataOverview>();
        for (Object result : results) {
            Object[] values = (Object[]) result;
            ErrataOverview eo = new ErrataOverview();
            // e.id, e.advisory, e.advisoryName, e.advisoryType, e.synopsis, e.updateDate
            eo.setId((Long)values[0]);
            eo.setAdvisory((String)values[1]);
            eo.setAdvisoryName((String)values[2]);
            eo.setAdvisoryType((String)values[3]);
            eo.setAdvisorySynopsis((String)values[4]);
            eo.setUpdateDate((Date)values[5]);
            eo.setIssueDate((Date)values[6]);
            eo.setSeverityid((Integer)values[7]);
            errata.add(eo);
        }

        return errata;
    }

    /**
     * Returns a list of ErrataOverview of Errata that match the given Package
     * ids.
     * @param pids Package ids whose Errata are being sought.
     * @return a list of ErrataOverview of Errata that match the given Package
     * ids.
     */
    public static List<ErrataOverview> searchByPackageIds(List pids) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("pids", pids);
        if (log.isDebugEnabled()) {
            log.debug("pids = " + pids);
        }
        List results = singleton.listObjectsByNamedQuery(
                "PublishedErrata.searchByPackageIds", params);
        if (log.isDebugEnabled()) {
            log.debug("Query 'PublishedErrata.searchByPackageIds' returned " +
                    results.size() + " entries");
        }
        List<ErrataOverview> errata = new ArrayList<ErrataOverview>();
        Long lastId = null;
        ErrataOverview eo = null;
        for (Object result : results) {
            Object[] values = (Object[]) result;
            // e.id, e.advisory, e.advisoryName, e.advisoryType, e.synopsis, e.updateDate
            Long curId = (Long)values[0];

            if (!curId.equals(lastId)) {
                eo = new ErrataOverview();
            }
            eo.setId((Long)values[0]);
            eo.setAdvisory((String)values[1]);
            eo.setAdvisoryName((String)values[2]);
            eo.setAdvisoryType((String)values[3]);
            eo.setAdvisorySynopsis((String)values[4]);
            eo.setUpdateDate((Date)values[5]);
            eo.setIssueDate((Date)values[6]);
            eo.addPackageName((String)values[7]);
            if (!curId.equals(lastId)) {
                errata.add(eo);
                lastId = curId;
            }
            if (log.isDebugEnabled()) {
                log.debug("curId = " + curId + ", lastId = " + lastId);
                log.debug("ErrataOverview formed: " + eo.getAdvisoryName() + " for " +
                        eo.getPackageNames());
            }
        }

        return errata;
    }


    /**
     * Returns a list of ErrataOverview of Errata that match the given Package
     * ids.
     * @param pids Package ids whose Errata are being sought.
     * @param org Organization to match results with
     * @return a list of ErrataOverview of Errata that match the given Package
     * ids.
     */
    public static List<ErrataOverview> searchByPackageIdsWithOrg(List pids, Org org) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("pids", pids);
        params.put("org_id", org.getId());
        if (log.isDebugEnabled()) {
            log.debug("org_id = " + org.getId());
            log.debug("pids = " + pids);
        }
        List results = singleton.listObjectsByNamedQuery(
                "PublishedErrata.searchByPackageIdsWithOrg", params);
        if (log.isDebugEnabled()) {
            log.debug("Query 'PublishedErrata.searchByPackageIdsWithOrg' returned " +
                    results.size() + " entries");
        }
        List<ErrataOverview> errata = new ArrayList<ErrataOverview>();
        Long lastId = null;
        ErrataOverview eo = null;
        for (Object result : results) {
            Object[] values = (Object[]) result;
            // e.id, e.advisory, e.advisoryName, e.advisoryType, e.synopsis, e.updateDate
            Long curId = (Long)values[0];

            if (!curId.equals(lastId)) {
                eo = new ErrataOverview();
            }
            eo.setId((Long)values[0]);
            eo.setAdvisory((String)values[1]);
            eo.setAdvisoryName((String)values[2]);
            eo.setAdvisoryType((String)values[3]);
            eo.setAdvisorySynopsis((String)values[4]);
            eo.setUpdateDate((Date)values[5]);
            eo.setIssueDate((Date)values[6]);
            eo.addPackageName((String)values[7]);
            if (!curId.equals(lastId)) {
                errata.add(eo);
                lastId = curId;
            }
            if (log.isDebugEnabled()) {
                log.debug("curId = " + curId + ", lastId = " + lastId);
                log.debug("ErrataOverview formed: " + eo.getAdvisoryName() + " for " +
                        eo.getPackageNames());
            }
        }

        return errata;
    }


    /**
     * Sync all the errata details from one errata to another
     * @param cloned the cloned errata that needs syncing
     */
    public static void syncErrataDetails(PublishedClonedErrata cloned) {
        copyDetails(cloned, cloned.getOriginal(), true);
    }

    /**
     * List errata objects by ID
     * @param ids list of ids
     * @return List of Errata Objects
     */
    public static List<Errata> listErrata(Collection<Long> ids) {
        return singleton.listObjectsByNamedQuery("PublishedErrata.listByIds",
                new HashMap(), ids, "list");
    }

    /**
     * Get list of errata ids that are in one channel but not another
     * @param fromCid errata are in this channel
     * @param toCid but not in this one
     * @return list of errata overviews
     */
    public static DataResult<ErrataOverview> relevantToOneChannelButNotAnother(
            Long fromCid, Long toCid) {
        SelectMode mode = ModeFactory.getMode("Errata_queries",
                "relevant_to_one_channel_but_not_another");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("from_cid", fromCid);
        params.put("to_cid", toCid);
        return (DataResult<ErrataOverview>) mode.execute(params);
    }

    /**
     * List all owned, published, unmodified, cloned errata in an org. Useful when cloning
     * channels.
     * @param orgId Org id to look for
     * @return List of OwnedErrata
     */
    public static DataResult<OwnedErrata> listPublishedOwnedUnmodifiedClonedErrata(
            Long orgId) {
        SelectMode mode = ModeFactory.getMode("Errata_queries",
                "published_owned_unmodified_cloned_errata");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", orgId);
        return (DataResult<OwnedErrata>) mode.execute(params);
    }

    /**
     * Get all advisory strings (published or unpublished) that end in the given string.
     * Useful when cloning errata.
     * @param ending String ending of the advisory
     * @return Set of existing advisories
     */
    public static Set<String> listAdvisoriesEndingWith(String ending) {
        SelectMode mode = ModeFactory.getMode("Errata_queries", "advisories_ending_with");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("ending", "%" + ending);
        List<Map<String, Object>> results = mode.execute(params);
        Set<String> ret = new HashSet<String>();
        for (Map<String, Object> result : results) {
            ret.add((String) result.get("advisory"));
        }
        return ret;
    }

    /**
     * Get all advisory names (published or unpublished) that end in the given string.
     * Useful when cloning errata.
     * @param ending String ending of the advisory
     * @return Set of existing advisory names
     */
    public static Set<String> listAdvisoryNamesEndingWith(String ending) {
        SelectMode mode = ModeFactory.getMode("Errata_queries",
                "advisory_names_ending_with");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("ending", "%" + ending);
        List<Map<String, Object>> results = mode.execute(params);
        Set<String> ret = new HashSet<String>();
        for (Map<String, Object> result : results) {
            ret.add((String) result.get("advisory_name"));
        }
        return ret;
    }

    /**
     * Get ErrataOverview by errata id
     * @param eid errata id
     * @return ErrataOverview object
     */
    public static ErrataOverview getOverviewById(Long eid) {
        SelectMode mode = ModeFactory.getMode("Errata_queries", "overview_by_id");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", eid);
        DataResult<ErrataOverview> results = mode.execute(params);
        if (results.size() == 0) {
            return null;
        }
        results.elaborate();
        return results.get(0);
    }

    /**
     * Get ErrataOverview by advisory
     * @param advisory the advisory
     * @return ErrataOverview object
     */
    public static ErrataOverview getOverviewByAdvisory(String advisory) {
        SelectMode mode = ModeFactory.getMode("Errata_queries", "overview_by_advisory");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("advisory", advisory);
        DataResult<ErrataOverview> results = mode.execute(params);
        if (results.size() == 0) {
            return null;
        }
        results.elaborate();
        return results.get(0);
    }

    /**
     * Clone an erratum in the db. Will fill contents of rhnErrata, rhnErrataCloned,
     * rhnErrataBugList, rhnErrataPackage, rhnErrataKeyword, and rhnErrataCVE. Basically
     * do everything that PublishErrataHelper.cloneErrataFast does, but much, much faster.
     * @param originalEid erratum id to clone from
     * @param advisory unique advisory
     * @param advisoryName unique name
     * @param orgId org id to clone into
     * @return ErrataOverview for the cloned erratum
     */
    public static ErrataOverview cloneErratum(Long originalEid, String advisory,
            String advisoryName, Long orgId) {
        WriteMode m = ModeFactory.getWriteMode("Errata_queries", "clone_erratum");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", originalEid);
        params.put("advisory", advisory);
        params.put("name", advisoryName);
        params.put("org_id", orgId);
        m.executeUpdate(params);
        ErrataOverview clone = getOverviewByAdvisory(advisory);

        // set original
        m = ModeFactory.getWriteMode("Errata_queries", "set_original");
        params = new HashMap<String, Object>();
        params.put("original_id", originalEid);
        params.put("clone_id", clone.getId());
        m.executeUpdate(params);

        // clone bugs
        m = ModeFactory.getWriteMode("Errata_queries", "clone_bugs");
        m.executeUpdate(params);

        // clone keywords
        m = ModeFactory.getWriteMode("Errata_queries", "clone_keywords");
        m.executeUpdate(params);

        // clone packages
        m = ModeFactory.getWriteMode("Errata_queries", "clone_packages");
        m.executeUpdate(params);

        // clone cves
        m = ModeFactory.getWriteMode("Errata_queries", "clone_cves");
        m.executeUpdate(params);

        // clone files
        m = ModeFactory.getWriteMode("Errata_queries", "clone_files");
        m.executeUpdate(params);

        return clone;
    }

}

