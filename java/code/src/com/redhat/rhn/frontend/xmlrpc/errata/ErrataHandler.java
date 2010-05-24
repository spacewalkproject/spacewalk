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
package com.redhat.rhn.frontend.xmlrpc.errata;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.InvalidChannelRoleException;
import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Cve;
import com.redhat.rhn.domain.errata.CveFactory;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.Keyword;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.CVE;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.DuplicateErrataException;
import com.redhat.rhn.frontend.xmlrpc.InvalidAdvisoryReleaseException;
import com.redhat.rhn.frontend.xmlrpc.InvalidAdvisoryTypeException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidErrataException;
import com.redhat.rhn.frontend.xmlrpc.InvalidPackageException;
import com.redhat.rhn.frontend.xmlrpc.MissingErrataAttributeException;
import com.redhat.rhn.frontend.xmlrpc.NoChannelsSelectedException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.frontend.xmlrpc.packages.PackageHelper;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;

import org.apache.commons.collections.IteratorUtils;
import org.apache.commons.lang.StringUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ErrataHandler - provides methods to access errata information.
 * @version $Rev$
 * @xmlrpc.namespace errata
 * @xmlrpc.doc Provides methods to access and modify errata.
 */
public class ErrataHandler extends BaseHandler {
    
    /**
     * Returns an OVAL metadata file for a given errata or CVE
     * @param sessionKey The authenticated user's session key
     * @param identifier Errata identifier (either id, CVE/CAN, or Advisory name)
     * @return Escaped XML representing the OVAL metadata document
     * @throws IOException error building XML file
     * @throws FaultException general error occurred
     *
     * @xmlrpc.doc Retrieves the OVAL metadata associated with one or more erratas.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "identifier", "Can either be an erratum's ID, 
     *              CVE/CAN, or advisory name.  In the case of CVE/CAN, all dashes must be  
     *             removed from the name.Numeric advisory IDs and advisory names 
     *              (RHSA-2006:011) can be submitted as they are.")
     * @xmlrpc.returntype string - The OVAL metadata document in escaped XML form.
     */
    /**
     * The getOval method is being commented out due to bugzilla 504054.  This bug
     * raises an issue of a null exception being generated on execution.  The method
     * has been updated to address that exception; however, there is a larger issue at
     * hand in that the OVAL functionality is not fully supported by the application.
     * For example, the OVAL meta data is not synced to the database; therefore, there
     * will never be data to return by the method.  So it is better to comment it out
     * than to have the method that cannot return any data. :)  It is, however,
     * desirable to support this in the future, so we don't want to lose the logic.
     *
    public String getOval(String sessionKey, String identifier) throws IOException,
            FaultException {
        User loggedInUser = getLoggedInUser(sessionKey);
        
        String retval = "";
        List<Errata> erratas = ErrataManager.lookupErrataByIdentifier(identifier);
        for (Errata errata : erratas) {
            if (errata.getOrg() != null && 
                    !errata.getOrg().equals(loggedInUser.getOrg())) {
                erratas.remove(errata);
            }
        }
        
        if (erratas == null) {
            throw new FaultException(-1, "errataNotFound", 
                    "No erratas found for given identifier");
        }
        List files = new LinkedList();
        if (erratas != null) {
            for (Iterator iter = erratas.iterator(); iter.hasNext();) {
                Errata e = (Errata) iter.next();
                List tmp = 
                    ErrataFactory.lookupErrataFilesByErrataAndFileType(e.getId(), 
                            "oval");
                if ((tmp != null && tmp.size() > 0) && 
                        (e.getOrg() == null || e.getOrg().equals(loggedInUser.getOrg()))) {
                    files.addAll(tmp);
                }
            }
            files = ErrataManager.resolveOvalFiles(files);
            if (files != null) {
                if (files.size() == 0) {
                    throw new FaultException(-1, "ovalNotFound",
                            "No OVAL files found for given errata");
                }
                else if (files.size() == 1) {
                    File f = (File) files.get(0);
                    if (f != null) {
                        InputStream in = null;
                        byte[] buf = new byte[4096];
                        int readsize = 0;
                        ByteArrayOutputStream accum  = new ByteArrayOutputStream();
                        try {
                            in = new FileInputStream(f);
                            while ((readsize = in.read(buf)) > -1) {
                                accum.write(buf, 0, readsize);
                            }
                            retval = new String(accum.toByteArray(), "UTF-8");
                        }
                        finally {
                            if (in != null) {
                                in.close();
                            }
                        }
                    }
                }
                else if (files.size() > 1) {
                    try {
                        OvalFileAggregator agg = new OvalFileAggregator();
                        for (Iterator iter = files.iterator(); iter.hasNext();) {
                            File f = (File) iter.next();
                            if (f != null && !f.getPath().endsWith("test-5.xml")) {
                                agg.add(f);
                            }
                        }
                        retval = StringEscapeUtils.escapeXml(agg.finish(false));
                    }
                    catch (JDOMException e) {
                        throw new FaultException(-1, "err_building_oval", e.getMessage());
                    }
                }
            }
        }
        return retval;
    }
    */
    
    /**
     * GetDetails - Retrieves the details for a given errata. 
     * @param sessionKey The sessionKey for the logged in user
     * @param advisoryName The advisory name of the errata
     * @return Returns a map containing the details of the errata
     * @throws FaultException A FaultException is thrown if the errata
     * corresponding to advisoryName cannot be found.
     * 
     * @xmlrpc.doc Retrieves the details for the erratum matching the given
     * advisory name.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "advisoryName")
     * @xmlrpc.returntype 
     *      #struct("erratum")
     *          #prop("string", "issue_date")
     *          #prop("string", "update_date")
     *          #prop_desc("string", "last_modified_date", "This date is only included for
     *          published erratum and it represents the last time the erratum was 
     *          modified.")
     *          #prop("string", "synopsis")
     *          #prop("int", "release")
     *          #prop("string", "type")
     *          #prop("string", "product")
     *          #prop("string", "topic")
     *          #prop("string", "description")
     *          #prop("string", "references")
     *          #prop("string", "notes")
     *          #prop("string", "solution")
     *     #struct_end()
     */
    public Map getDetails(String sessionKey, String advisoryName) throws FaultException {
        // Get the logged in user. We don't care what roles this user has, we
        // just want to make sure the caller is logged in.
        User loggedInUser = getLoggedInUser(sessionKey);
        
        Errata errata = lookupErrata(advisoryName, loggedInUser.getOrg());
        
        Map errataMap = new HashMap();
              
        if (errata.getIssueDate() != null) {
            errataMap.put("issue_date", 
                          LocalizationService.getInstance()
                              .formatShortDate(errata.getIssueDate()));
        }
        if (errata.getUpdateDate() != null) {
            errataMap.put("update_date",
                          LocalizationService.getInstance()
                              .formatShortDate(errata.getUpdateDate()));
        }
        if (errata.getLastModified() != null) {
            errataMap.put("last_modified_date", errata.getLastModified().toString());
        }
        if (errata.getAdvisoryRel() != null) {
            errataMap.put("release", errata.getAdvisoryRel());
        }
        errataMap.put("product", 
                StringUtils.defaultString(errata.getProduct()));
        errataMap.put("solution", 
                StringUtils.defaultString(errata.getSolution()));
        errataMap.put("description", 
                      StringUtils.defaultString(errata.getDescription()));
        errataMap.put("synopsis", 
                      StringUtils.defaultString(errata.getSynopsis()));
        errataMap.put("topic", 
                      StringUtils.defaultString(errata.getTopic()));
        errataMap.put("references", 
                      StringUtils.defaultString(errata.getRefersTo()));
        errataMap.put("notes", 
                      StringUtils.defaultString(errata.getNotes()));
        errataMap.put("type", 
                      StringUtils.defaultString(errata.getAdvisoryType()));
        
     
        return errataMap;
    }
    
    /**
     * Set erratum details.
     * 
     * @param sessionKey User's session key.
     * @param advisoryName The advisory name of the errata
     * @param details Map of (optional) erratum details to be set.
     * @return 1 on success, exception thrown otherwise.
     * 
     * @xmlrpc.doc Set erratum details. All arguments are optional and will only be modified
     * if included in the struct. This method will only allow for modification of custom 
     * errata created either through the UI or API.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "advisoryName")
     * @xmlrpc.param 
     *      #struct("errata details")
     *          #prop("string", "synopsis")
     *          #prop("string", "advisory_name")
     *          #prop("int", "advisory_release")
     *          #prop_desc("string", "advisory_type", "Type of advisory (one of the 
     *                  following: 'Security Advisory', 'Product Enhancement Advisory', 
     *                  or 'Bug Fix Advisory'")
     *          #prop("string", "product")
     *          #prop("string", "topic")
     *          #prop("string", "description")
     *          #prop("string", "references")
     *          #prop("string", "notes")
     *          #prop("string", "solution")
     *          #prop_desc("array", "bugs", "'bugs' is the key into the struct")
     *              #array()
     *                 #struct("bug")
     *                    #prop_desc("int", "id", "Bug Id")
     *                    #prop("string", "summary")
     *                 #struct_end()
     *              #array_end()
     *          #prop_desc("array", "keywords", "'keywords' is the key into the struct")
     *              #array_single("string", "keyword - List of keywords to associate 
     *                  with the errata.")
     *          #prop_desc("array", "CVEs", "'cves' is the key into the struct")
     *              #array_single("string", "cves - List of CVEs to associate
     *                  with the errata.")
     *     #struct_end()
     *     
     *  @xmlrpc.returntype #return_int_success()
     */
    public Integer setDetails(String sessionKey, String advisoryName, Map details) {

        // confirm that the user only provided valid keys in the map
        Set<String> validKeys = new HashSet<String>();
        validKeys.add("synopsis");
        validKeys.add("advisory_name");
        validKeys.add("advisory_release");
        validKeys.add("advisory_type");
        validKeys.add("product");
        validKeys.add("topic");
        validKeys.add("description");
        validKeys.add("references");
        validKeys.add("notes");
        validKeys.add("solution");
        validKeys.add("bugs");
        validKeys.add("keywords");
        validKeys.add("cves");
        validateMap(validKeys, details);

        validKeys.clear();
        validKeys.add("id");
        validKeys.add("summary");
        if (details.containsKey("bugs")) {
            for (Map<String, Object> bugMap :
                 (ArrayList<Map<String, Object>>) details.get("bugs")) {

                validateMap(validKeys, bugMap);
            }
        }

        User loggedInUser = getLoggedInUser(sessionKey);
        Errata errata = lookupErrata(advisoryName, loggedInUser.getOrg());

        if (errata.getOrg() == null) {
            // Errata in the null org should not be modified; therefore, this is
            // considered an invalid errata for this request
            throw new InvalidErrataException(errata.getAdvisoryName());
        }
        
        if (details.containsKey("synopsis")) {
            errata.setSynopsis((String)details.get("synopsis"));
        }
        if (details.containsKey("advisory_name")) {
            errata.setAdvisoryName((String)details.get("advisory_name"));
        }
        if (details.containsKey("advisory_release")) {
            Long rel = new Long((Integer)details.get("advisory_release"));
            if (rel.longValue() > ErrataManager.MAX_ADVISORY_RELEASE) {
                throw new InvalidAdvisoryReleaseException(rel.longValue());
            }
            errata.setAdvisoryRel(rel);
        }
        if (details.containsKey("advisory_type")) {
            errata.setAdvisoryType((String)details.get("advisory_type"));
        }
        if (details.containsKey("product")) {
            errata.setProduct((String)details.get("product"));
        }
        if (details.containsKey("topic")) {
            errata.setTopic((String)details.get("topic"));
        }
        if (details.containsKey("description")) {
            errata.setDescription((String)details.get("description"));
        }
        if (details.containsKey("solution")) {
            errata.setSolution((String)details.get("solution"));
        }
        if (details.containsKey("references")) {
            errata.setRefersTo((String)details.get("references"));
        }
        if (details.containsKey("notes")) {
            errata.setNotes((String)details.get("notes"));
        }
        if (details.containsKey("bugs")) {
            
            if (errata.getBugs() != null) {
                errata.getBugs().clear();        
                HibernateFactory.getSession().flush();
            }
            
            for (Map<String, Object> bugMap : 
                 (ArrayList<Map<String, Object>>) details.get("bugs")) {
                
                if (bugMap.containsKey("id") && bugMap.containsKey("summary")) {
                    
                    Bug bug = ErrataFactory.createPublishedBug(
                            new Long((Integer) bugMap.get("id")), 
                            (String) bugMap.get("summary"));
                    
                    errata.addBug(bug);
                }
            }
        }
        if (details.containsKey("keywords")) {
            if (errata.getKeywords() != null) {
                errata.getKeywords().clear();
                HibernateFactory.getSession().flush();      
            }
            for (String keyword : (ArrayList<String>) details.get("keywords")) {
                errata.addKeyword(keyword);
            }
        }
        if (details.containsKey("cves")) {
            if (errata.getCves() != null) {
                errata.getCves().clear();
                HibernateFactory.getSession().flush();
            }
            for (String cveName : (ArrayList<String>) details.get("cves")) {
                Cve c = CveFactory.lookupByName(cveName);
                if (c == null) {
                    c = new Cve();
                    c.setName(cveName);
                    CveFactory.save(c);
                }
                errata.getCves().add(c);
            }
        }
        
        // ALWAYS change the advisory to match, as we do in the UI.
        errata.setAdvisory(errata.getAdvisoryName() + "-" +
                errata.getAdvisoryRel().toString());

        //Save the errata
        ErrataManager.storeErrata(errata);

        return 1;
    }

    /**
     * ListAffectedSystems 
     * @param sessionKey The sessionKey for the logged in user
     * @param advisoryName The advisory name of the errata
     * @return Returns an object array containing the system ids and system name
     * @throws FaultException A FaultException is thrown if the errata corresponding to 
     * advisoryName cannot be found.
     * 
     * @xmlrpc.doc Return the list of systems affected by the erratum with 
     * advisory name.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "advisoryName")
     * @xmlrpc.returntype 
     *      #array()
     *          $SystemOverviewSerializer
     *      #array_end()
     */
    public Object[] listAffectedSystems(String sessionKey, String advisoryName) 
        throws FaultException {
        
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Errata errata = lookupErrata(advisoryName, loggedInUser.getOrg()); 
        
        DataResult dr = ErrataManager.systemsAffectedXmlRpc(loggedInUser, errata.getId()); 
        
        return dr.toArray();
    }
    
    /**
     * Get the Bugzilla fixes for a given errata
     * @param sessionKey The sessionKey for the logged in user
     * @param advisoryName The advisory name of the errata
     * @return Returns a map containing the Bugzilla id and summary for each bug
     * @throws FaultException A FaultException is thrown if the errata
     * corresponding to the given advisoryName cannot be found.
     * 
     * @xmlrpc.doc Get the Bugzilla fixes for an erratum matching the given
     * advisoryName. The bugs will be returned in a struct where the bug id is
     * the key.  i.e. 208144="errata.bugzillaFixes Method Returns different
     * results than docs say"
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "advisoryName") 
     * @xmlrpc.returntype 
     *      #struct("Bugzilla info")
     *          #prop_desc("string", "bugzilla_id", "actual bug number is the key into the
     *                      struct")
     *          #prop_desc("string", "bug_summary", "summary who's key is the bug id")
     *      #struct_end()
     */
    public Map bugzillaFixes(String sessionKey, String advisoryName) 
        throws FaultException {
        
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Errata errata = lookupErrata(advisoryName, loggedInUser.getOrg());
        
        Set bugs = errata.getBugs();
        Map returnMap = new HashMap();
        
        /*
         * Loop through and stick the bug ids and summaries into a map. This
         * is ok since (afaict) there isn't an unreasonable number of bugs
         * attatched to any erratum.
         */
        for (Iterator itr = IteratorUtils.getIterator(bugs.iterator()); itr.hasNext();) {
            Bug bug = (Bug) itr.next();
            returnMap.put(bug.getId(), bug.getSummary());
        }
        
        return returnMap;
    }

    /**
     * Get the keywords for a given erratum
     * @param sessionKey The sessionKey for the logged in user
     * @param advisoryName The advisory name of the erratum
     * @return Returns an array of keywords for the erratum
     * @throws FaultException A FaultException is thrown if the errata corresponding to the
     * given advisoryName cannot be fo
     * 
     * @xmlrpc.doc Get the keywords associated with an erratum matching the
     * given advisory name. 
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "advisoryName")
     * @xmlrpc.returntype #array_single("string", "Keyword associated with erratum.")

     */
    public Object[] listKeywords(String sessionKey, String advisoryName) 
        throws FaultException {
        
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Errata errata = lookupErrata(advisoryName, loggedInUser.getOrg());
        
        Set keywords = errata.getKeywords();
        List returnList = new ArrayList();
        
        for (Iterator itr = IteratorUtils.getIterator(keywords); itr.hasNext();) {
            Keyword keyword = (Keyword) itr.next();
            returnList.add(keyword.getKeyword());
        }
        
        return returnList.toArray();
    }
    
    /**
     * Returns a list of channels (represented by a map) that the given erratum is
     * applicable to.
     * @param sessionKey The sessionKey for the logged in user.
     * @param advisoryName The advisory name of the erratum
     * @return Returns an array of channels for the erratum
     * @throws FaultException A FaultException is thrown if the errata corresponding to the
     * given advisoryName cannot be found
     * 
     * @xmlrpc.doc Returns a list of channels applicable to the erratum
     * with the given advisory name. 
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "advisoryName")
     * @xmlrpc.returntype 
     *      #array()
     *          #struct("channel")
     *              #prop("int", "channel_id")
     *              #prop("string", "label")
     *              #prop("string", "name")
     *              #prop("string", "parent_channel_label")
     *          #struct_end()
     *       #array_end()
     */
    public Object[] applicableToChannels(String sessionKey, String advisoryName) 
        throws FaultException {
        
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Errata errata = lookupErrata(advisoryName, loggedInUser.getOrg());
        
        return ErrataManager.applicableChannels(errata.getId(), 
                         loggedInUser.getOrg().getId(), null, Map.class).toArray();
    }

    /**
     * Returns a list of unpublished errata for the logged-in user's Org.
     * @param sessionKey The sessionKey for the logged in user
     * @return Returns an array of errata
     *
     * @xmlrpc.doc Returns a list of unpublished errata
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     *      #array()
     *          #struct()
     *              #prop("int", "id")
     *              #prop("int", "published")
     *              #prop("string", "advisory")
     *              #prop("string", "advisory_name")
     *              #prop("string", "advisory_type")
     *              #prop("string", "synopsis")
     *              #prop("dateTime.iso8601", "created")
     *              #prop("dateTime.iso8601", "update_date")
     *          #struct_end()
     *      #array_end()
     */
    public Object[] listUnpublishedErrata(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Map[] unpub = (Map[])ErrataManager.unpublishedOwnedErrata(loggedInUser, Map.class)
                .toArray(new Map[0]);

        for (Map errataItem : unpub) {
            // remove items that can be NULL to prevent xmlrpc failure
            Iterator<Map.Entry> itr = errataItem.entrySet().iterator();
            for (; itr.hasNext();) {
                if (itr.next().getValue() == null) {
                    itr.remove();
                }
            }
        }

        return unpub;
    }

    /**
     * Returns a list of CVEs for a given erratum
     * @param sessionKey The sessionKey for the logged in user
     * @param advisoryName The advisory name of the erratum
     * @return Returns a list of CVEs
     * @throws FaultException A FaultException is thrown if the errata corresponding to the
     * given advisoryName cannot be found 
        throws FaultException {
     * 
     * @xmlrpc.doc Returns a list of <a href="http://www.cve.mitre.org/">CVE</a>s
     * applicable to the erratum with the given advisory name. 
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string",  "advisoryName")
     * @xmlrpc.returntype 
     *      #array_single("string", "cveName")
     *          
     */
    public List listCves(String sessionKey, String advisoryName) throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Errata errata = lookupErrata(advisoryName, loggedInUser.getOrg());
        
        DataResult dr = ErrataManager.errataCVEs(errata.getId());
        List returnList = new ArrayList();
        
        //Just return the name of the cve...
        for (Iterator itr = dr.iterator(); itr.hasNext();) {
            CVE cve = (CVE) itr.next();
            returnList.add(cve.getName());
        }
        
        return returnList;
    }
    
    /**
     * List the packages for a given erratum
     * @param sessionKey The sessionKey for the logged in user
     * @param advisoryName The advisory name of the erratum
     * @return Returns an Array of maps representing a package
     * @throws FaultException A FaultException is thrown if the errata corresponding to the
     * given advisoryName cannot be found
     * 
     * @xmlrpc.doc Returns a list of the packages affected by the erratum
     * with the given advisory name. 
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "advisoryName")
     * @xmlrpc.returntype 
     *          #array()
     *              #struct("package")
     *                  #prop("int", "id")
     *                  #prop("string", "name")
     *                  #prop("string", "epoch")
     *                  #prop("string", "version")
     *                  #prop("string", "release")
     *                  #prop("string", "arch_label")
     *                  #prop_array("providing_channels", "string", "- Channel label 
     *                              providing this package.")
     *                  #prop("string", "build_host")
     *                  #prop("string", "description")
     *                  #prop("string", "checksum")
     *                  #prop("string", "vendor")
     *                  #prop("string", "summary")
     *                  #prop("string", "cookie")
     *                  #prop("string", "license")
     *                  #prop("string", "file")
     *                  #prop("string", "path")
     *                  #prop("string", "build_date")
     *                  #prop("string", "last_modified_date")
     *                  #prop("string", "size")
     *                  #prop("string", "payload_size")
     *               #struct_end()
     *           #array_end()
     */
    public Object[] listPackages(String sessionKey, String advisoryName) 
        throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Errata errata = lookupErrata(advisoryName, loggedInUser.getOrg());
        
        //The set of packages for this erratum
        Set packages = errata.getPackages();
        
        //Main List containing the maps
        List returnList = new ArrayList();
        
        /*
         * Loop through the packages and add each one to the returnList array
         */
        for (Iterator itr = packages.iterator(); itr.hasNext();) {
            Package pkg = (Package) itr.next();
            // fill out a new row containing the package info map
            Map pmap = PackageHelper.packageToMap(pkg, loggedInUser);
            returnList.add(pmap);
        }
        
        return returnList.toArray();
    }
    
    /**
     * Add a set of packages to an erratum
     * @param sessionKey The sessionKey for the logged in user
     * @param advisoryName The advisory name of the erratum
     * @param packageIds The ids for packages to remove
     * @return Returns int - representing the number of packages added, exception otherwise
     * @throws FaultException A FaultException is thrown if the errata corresponding to the
     * given advisoryName cannot be found
     * 
     * @xmlrpc.doc Add a set of packages to an erratum
     * with the given advisory name. This method will only allow for modification
     * of custom errata created either through the UI or API.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "advisoryName")
     * @xmlrpc.param #array_single("int", "packageId")
     * @xmlrpc.returntype int - representing the number of packages added, 
     * exception otherwise
     */
    public int addPackages(String sessionKey, String advisoryName, 
            List<Integer> packageIds) throws FaultException {
        
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Errata errata = lookupErrata(advisoryName, loggedInUser.getOrg());
        
        if (errata.getOrg() == null) {
            // Errata in the null org should not be modified; therefore, this is
            // considered an invalid errata for this request
            throw new InvalidErrataException(errata.getAdvisoryName());
        }
        
        int packagesAdded = 0;
        for (Integer packageId : packageIds) {
            
            Package pkg = PackageManager.lookupByIdAndUser(new Long(packageId), 
                    loggedInUser);
            
            if ((pkg != null) && (!errata.getPackages().contains(pkg))) {
                errata.addPackage(pkg);
                packagesAdded++;
            }
        }

        //Update Errata Cache
        if ((packagesAdded > 0) && errata.isPublished() && 
            (errata.getChannels() != null)) {
            ErrataCacheManager.updateCacheForChannelsAsync(
                    errata.getChannels());
        }
        
        //Save the errata
        ErrataManager.storeErrata(errata);

        return packagesAdded;
    }
    
    /**
     * Remove a set of packages from an erratum
     * @param sessionKey The sessionKey for the logged in user
     * @param advisoryName The advisory name of the erratum
     * @param packageIds The ids for packages to remove
     * @return Returns int - representing the number of packages removed, 
     * exception otherwise
     * @throws FaultException A FaultException is thrown if the errata corresponding to the
     * given advisoryName cannot be found
     * 
     * @xmlrpc.doc Remove a set of packages from an erratum
     * with the given advisory name.  This method will only allow for modification
     * of custom errata created either through the UI or API.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "advisoryName")
     * @xmlrpc.param #array_single("int", "packageId")
     * @xmlrpc.returntype int - representing the number of packages removed,
     * exception otherwise
     */
    public int removePackages(String sessionKey, String advisoryName, 
            List<Integer> packageIds) throws FaultException {
        
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Errata errata = lookupErrata(advisoryName, loggedInUser.getOrg());
        
        if (errata.getOrg() == null) {
            // Errata in the null org should not be modified; therefore, this is
            // considered an invalid errata for this request
            throw new InvalidErrataException(errata.getAdvisoryName());
        }
        
        int packagesRemoved = 0;
        for (Integer packageId : packageIds) {
            
            Package pkg = PackageManager.lookupByIdAndUser(new Long(packageId), 
                    loggedInUser);

            if ((pkg != null) && (errata.getPackages().contains(pkg))) {
                errata.removePackage(pkg);
                packagesRemoved++;
            }
        }

        //Update Errata Cache
        if ((packagesRemoved > 0) && errata.isPublished() && 
                (errata.getChannels() != null)) {
            ErrataCacheManager.updateCacheForChannelsAsync(
                    errata.getChannels());
        }
        
        //Save the errata
        ErrataManager.storeErrata(errata);

        return packagesRemoved;
    }

    /**
     * Private helper method to lookup an errata and throw a Fault exception if it isn't
     * found
     * @param advisoryName The advisory name for the erratum you're looking for
     * @return Returns the errata or a Fault Exception
     * @throws FaultException Occurs when the erratum is not found
     */
    private Errata lookupErrata(String advisoryName, Org org) throws FaultException {
        Errata errata = ErrataManager.lookupByAdvisory(advisoryName);
        
        /*
         * ErrataManager.lookupByAdvisory() could return null, so we need to check
         * and throw a no_such_errata exception if the errata was not found.
         */
        if (errata == null) {
            throw new FaultException(-208, "no_such_errata", 
                                     "The errata " + advisoryName + " cannot be found.");
        }
        /**
         * errata with org_id of null are public, but ones with an org id of !null are not
         * need to make sure here that everything is checked correclty
         */
        if (errata.getOrg() != null && !errata.getOrg().equals(org)) {
            throw new FaultException(-209, "no_such_errata", 
                    "The errata " + advisoryName + " cannot be found.");
        }
        
        return errata;
    }    

    /**
     * Clones a list of errata into a specified channel
     * 
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel the channel's label that we are cloning into
     * @param advisoryNames an array of String objects containing the advisory name
     *          of every errata you want to clone 
     * @throws InvalidChannelRoleException if the user perms are incorrect
     * @return Returns an array of Errata objects, which get serialized into XMLRPC 
     * 
     * @xmlrpc.doc Clone a list of errata into the specified channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "channel_label") 
     * @xmlrpc.param 
     *      #array_single("string", " advisory - The advisory name of the errata to clone.")
     * @xmlrpc.returntype 
     *          #array()
     *              $ErrataSerializer
     *          #array_end()
     */
    public Object[] clone(String sessionKey, String channelLabel, 
            List advisoryNames) throws InvalidChannelRoleException {
        User loggedInUser = getLoggedInUser(sessionKey);
        
        Channel channel = ChannelFactory.lookupByLabelAndUser(channelLabel, 
                            loggedInUser);       
        
        if (channel == null) {
            throw new NoSuchChannelException();
        }
        //do a user permission check
        if (!ChannelManager.verifyChannelAdmin(loggedInUser, channel.getId())) {
            throw new InvalidChannelRoleException(channel.getLabel());
        }

        channel = ChannelFactory.lookupByIdAndUser(channel.getId(), loggedInUser);
        
        List errataToClone = new ArrayList();
        List toReturn = new ArrayList();
        
        //We loop through once, making sure all the errata exist
        for (Iterator itr = advisoryNames.iterator(); itr.hasNext();) {
            Errata toClone = lookupErrata((String)itr.next(), loggedInUser.getOrg());
            errataToClone.add(toClone);            
        }
        //now that we know its all valid, we clone everything. 
        for (Iterator itr = errataToClone.iterator(); itr.hasNext();) {
            Errata cloned = ErrataManager.createClone(loggedInUser, (Errata)itr.next());
            Errata publishedClone = ErrataManager.publish(cloned);

            publishedClone = ErrataFactory.publishToChannel(publishedClone, channel, 
                    loggedInUser);
            ErrataFactory.save(publishedClone);
            
            toReturn.add(publishedClone);
        }
        return toReturn.toArray();
    }
    
    
    
    private Object getRequiredAttribute(Map map, String attribute) {
        Object value = map.get(attribute);
        if (value == null || StringUtils.isEmpty(value.toString())) {
            throw new MissingErrataAttributeException(attribute);
        }
        else {
            return value;
        }
    }
    
    /**
     * creates an errata
     * @param sessionKey  The sessionKey containing the logged in user
     * @param errataInfo map containing the following values:
     *  String "synopsis" short synopsis of the errata
     *  String "advisory_name" advisory name of the errata
     *  Integer "advisory_release" release number of the errata
     *  String "advisory_type" the type of advisory for the errata (Must be one of the 
     *          following: "Security Advisory", "Product Enhancement Advisory", or 
     *          "Bug Fix Advisory"
     *  String "product" the product the errata affects
     *  String "topic" the topic of the errata
     *  String "description" the description of the errata
     *  String "solution" the solution of the errata 
     *  String "references" references of the errata to be created
     *  String "notes" notes on the errata
     * @param bugs a List of maps consisting of 'id' Integers and 'summary' strings
     * @param keywords a List of keywords for the errata
     * @param packageIds a List of package Id packageId Integers
     * @param publish should the errata be published
     * @param channelLabels an array of channel labels to publish to if the errata is to
     *          be published    
     * @throws InvalidChannelRoleException if the user perms are incorrect          
     * @return The errata created (whether published or unpublished)
     * 
     * @xmlrpc.doc Create a custom errata.  If "publish" is set to true, 
     *      the errata will be published as well
     * @xmlrpc.param #session_key()
     * @xmlrpc.param 
     *      #struct("errata info")
     *          #prop("string", "synopsis")
     *          #prop("string", "advisory_name")
     *          #prop("int", "advisory_release")
     *          #prop_desc("string", "advisory_type", "Type of advisory (one of the 
     *                  following: 'Security Advisory', 'Product Enhancement Advisory', 
     *                  or 'Bug Fix Advisory'")
     *          #prop("string", "product")
     *          #prop("string", "topic")
     *          #prop("string", "description")
     *          #prop("string", "references")
     *          #prop("string", "notes")
     *          #prop("string", "solution")
     *       #struct_end()
     *  @xmlrpc.param
     *       #array()
     *              #struct("bug")
     *                  #prop_desc("int", "id", "Bug Id")
     *                  #prop("string", "summary")
     *               #struct_end()
     *       #array_end()
     * @xmlrpc.param #array_single("string", "keyword - List of keywords to associate 
     *              with the errata.")
     * @xmlrpc.param #array_single("int", "packageId")
     * @xmlrpc.param #param_desc("boolean", "publish", "Should the errata be published.")
     * @xmlrpc.param 
     *       #array_single("string", "channelLabel - list of channels the errata should be 
     *                  published too, ignored if publish is set to false")
     * @xmlrpc.returntype 
     *      $ErrataSerializer
     */
    public Errata create(String sessionKey, Map errataInfo,
            List bugs, List keywords, List packageIds, boolean publish, 
            List channelLabels) throws InvalidChannelRoleException {

        // confirm that the user only provided valid keys in the map
        Set<String> validKeys = new HashSet<String>();
        validKeys.add("synopsis");
        validKeys.add("advisory_name");
        validKeys.add("advisory_release");
        validKeys.add("advisory_type");
        validKeys.add("product");
        validKeys.add("topic");
        validKeys.add("description");
        validKeys.add("references");
        validKeys.add("notes");
        validKeys.add("solution");
        validateMap(validKeys, errataInfo);

        validKeys.clear();
        validKeys.add("id");
        validKeys.add("summary");
        for (Map<String, Object> bugMap : (ArrayList<Map<String, Object>>) bugs) {
            validateMap(validKeys, bugMap);
        }

        User loggedInUser = getLoggedInUser(sessionKey);
        
        //Don't want them to publish an errata without any channels, 
        //so check first before creating anything
        List channels = null;
        if (publish) {
             channels = verifyChannelList(channelLabels, loggedInUser);
        }
        
        String synopsis = (String) getRequiredAttribute(errataInfo, "synopsis");
        String advisoryName = (String) getRequiredAttribute(errataInfo, "advisory_name");
        Integer advisoryRelease = (Integer) getRequiredAttribute(errataInfo, 
                "advisory_release");
        if (advisoryRelease.longValue() > ErrataManager.MAX_ADVISORY_RELEASE) {
            throw new InvalidAdvisoryReleaseException(advisoryRelease.longValue());
        }
        String advisoryType = (String) getRequiredAttribute(errataInfo, "advisory_type");
        String product = (String) getRequiredAttribute(errataInfo, "product");
        String topic = (String) getRequiredAttribute(errataInfo, "topic");
        String description = (String) getRequiredAttribute(errataInfo, "description");
        String solution = (String) getRequiredAttribute(errataInfo, "solution");
        String references = (String) errataInfo.get("references");
        String notes = (String) errataInfo.get("notes");
        
        Errata newErrata = ErrataManager.lookupByAdvisory(advisoryName);
        if (newErrata != null) {
            throw new DuplicateErrataException(advisoryName);
        }        
        newErrata = ErrataManager.createNewErrata();
        newErrata.setOrg(loggedInUser.getOrg());
        
        //all required
        newErrata.setSynopsis(synopsis);
        newErrata.setAdvisory(advisoryName + "-" + advisoryRelease.toString());
        newErrata.setAdvisoryName(advisoryName);
        newErrata.setAdvisoryRel(new Long(advisoryRelease.longValue()));
        
        if (advisoryType.equals("Security Advisory") || 
                advisoryType.equals("Product Enhancement Advisory") ||
                advisoryType.equals("Bug Fix Advisory")) {
            
            newErrata.setAdvisoryType(advisoryType);
        }
        else {
            throw new InvalidAdvisoryTypeException(advisoryType);
        }
                
        newErrata.setProduct(product);
        newErrata.setTopic(topic);
        newErrata.setDescription(description);
        newErrata.setSolution(solution);
        newErrata.setIssueDate(new Date());
        newErrata.setUpdateDate(new Date());
        
        //not required
        newErrata.setRefersTo(references);
        newErrata.setNotes(notes);        

        for (Iterator itr = bugs.iterator(); itr.hasNext();) {
            Map bugMap = (Map) itr.next();
            Bug bug = ErrataFactory.createPublishedBug(
                    new Long(((Integer)bugMap.get("id")).longValue()), 
                    (String)bugMap.get("summary"));
            newErrata.addBug(bug);
        }
        for (Iterator itr = keywords.iterator(); itr.hasNext();) {
            String  keyword = (String) itr.next();
            newErrata.addKeyword(keyword);       
        }
        
        newErrata.setPackages(new HashSet());        
        for (Iterator itr = packageIds.iterator(); itr.hasNext();) {
            Integer pid = (Integer) itr.next();           
            Package pack = PackageFactory.lookupByIdAndOrg(new Long(pid.longValue()),
                    loggedInUser.getOrg());
            if (pack != null) {
                newErrata.addPackage(pack);
            }
            else {
                throw new InvalidPackageException(pid.toString());
            }
        }
        
        ErrataFactory.save(newErrata);
       
        //if true, channels will not be null, but will be a List of channel objects
        if (publish) {
            return publish(newErrata, channels, loggedInUser);
        }
        else {
            return newErrata;
        }
    }

    /**
     * Delete an erratum.
     * @param sessionKey session of the logged in user
     * @param advisoryName The advisory Name of the erratum to delete
     * @throws FaultException if unknown or invalid erratum is provided.
     * @return 1 on success, exception thrown otherwise.
     * 
     * @xmlrpc.doc Delete an erratum.  This method will only allow for deletion
     * of custom errata created either through the UI or API.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "advisoryName")
     * @xmlrpc.returntype #return_int_success()
     */ 
    public Integer delete(String sessionKey, String advisoryName) 
        throws FaultException {
        User loggedInUser = getLoggedInUser(sessionKey);
        Errata errata = lookupErrata(advisoryName, loggedInUser.getOrg());

        if (errata.getOrg() == null) {
            // Errata in the null org should not be modified; therefore, this is
            // considered an invalid errata for this request
            throw new InvalidErrataException(errata.getAdvisoryName());
        }

        ErrataManager.deleteErratum(loggedInUser, errata);
        return 1;
    }

    /**
     * Publishes an existing (unpublished) errata to a set of channels
     * @param sessionKey session of the logged in user
     * @param advisory The advisory Name of the errata to publish
     * @param channelLabels List of channels to publish the errata to
     * @throws InvalidChannelRoleException if the user perms are incorrect
     * @return the published errata
     * 
     * @xmlrpc.doc Publish an existing (unpublished) errata to a set of channels.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "advisoryName")
     * @xmlrpc.param 
     *      #array_single("string", "channelLabel - list of channel labels to publish to")
     * @xmlrpc.returntype 
     *          $ErrataSerializer
     */ 
    public Errata publish(String sessionKey, String advisory, List channelLabels) 
                                                     throws InvalidChannelRoleException {
        User loggedInUser = getLoggedInUser(sessionKey);
        List channels = verifyChannelList(channelLabels, loggedInUser);
        Errata toPublish = lookupErrata(advisory, loggedInUser.getOrg());
        return publish(toPublish, channels, loggedInUser);       
    }
    
    /**
     * Verify a list of channels labels, and populate their corresponding 
     *      Channel objects into a List.  This is primarily used before publishing
     *      to verify all channels are valid before starting the errata creation
     * @param channelsLabels the List of channel labels to verify 
     * @param org the org of the user
     * @return a List of channel objects
     */
    private List verifyChannelList(List channelsLabels, User user) 
                                                throws InvalidChannelRoleException {
        if (channelsLabels.size() == 0) {
            throw new NoChannelsSelectedException();
        }
        
        List resolvedList = new ArrayList();
        for (Iterator itr = channelsLabels.iterator(); itr.hasNext();) {
            String  channelLabel = (String) itr.next();
            Channel channel = ChannelFactory.lookupByLabelAndUser(channelLabel, user);  
            if (channel == null) {
                throw new InvalidChannelLabelException();
            }
            else {
                ChannelManager.verifyChannelAdmin(user, channel.getId());
                resolvedList.add(channel);
            }
        } 
        return resolvedList;
    }

    /**
     * private helper method to publish the errata
     * @param errata the Unpublished errata to publish
     * @param channels A list of channel objects
     * @return The published Errata
     */
    private Errata publish(Errata errata, List<Channel> channels, User user) {
        Errata published = ErrataFactory.publish(errata);
        for (Channel chan : channels) {
            published = ErrataFactory.publishToChannel(published, chan, user);
        }
        return published;
    }
    
    
    /**
     * list errata by date
     * @param sessionKey session of the logged in user
     * @param channelLabel channel associated with the errata you are interested in.
     * @return List of Errata objects
     * @deprecated being replaced by channel.software.listErrata(string sessionKey,
     * string channelLabel)
     *  
     * @xmlrpc.doc List errata that have been applied to a particular channel by date.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param("string", "channelLabel")
     * @xmlrpc.returntype 
     *          #array()
     *              $ErrataSerializer
     *          #array_end()
     */
    public List listByDate(String sessionKey, String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = ChannelFactory.lookupByLabel(loggedInUser.getOrg(), 
                channelLabel); 
        return ErrataFactory.lookupByChannelSorted(loggedInUser.getOrg(), channel);
    }
    
    /**
     * Lookup the details for errata associated with the given CVE.
     * @param sessionKey session of the logged in user
     * @param cveName name of the CVE
     * @return List of Errata objects
     * 
     * @xmlrpc.doc Lookup the details for errata associated with the given CVE 
     * (e.g. CVE-2008-3270)
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param("string", "cveName")
     * @xmlrpc.returntype 
     *          #array()
     *              $ErrataSerializer
     *          #array_end()
     */
    public List<Errata> findByCve(String sessionKey, String cveName) {
        // Get the logged in user. We don't care what roles this user has, we
        // just want to make sure the caller is logged in.
        User loggedInUser = getLoggedInUser(sessionKey);
        
        List<Errata> erratas = ErrataManager.lookupByCVE(cveName);
        for (Errata errata : erratas) {
            // Remove errata that do not apply to the user's org
            if (errata.getOrg() != null && 
                    !errata.getOrg().equals(loggedInUser.getOrg())) {
                erratas.remove(errata);
            }
        }
        return erratas;
    }

}
