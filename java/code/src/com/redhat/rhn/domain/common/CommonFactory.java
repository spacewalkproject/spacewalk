/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
package com.redhat.rhn.domain.common;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.org.Org;

import org.apache.commons.lang.RandomStringUtils;
import org.apache.log4j.Logger;
import org.hibernate.Session;

import java.util.Calendar;
import java.util.Date;

/**
 * CommonFactory
 */
public class CommonFactory extends HibernateFactory {


    private static CommonFactory singleton = new CommonFactory();
    private static Logger log = Logger.getLogger(CommonFactory.class);


    private CommonFactory() {
        super();
    }

    /**
     * Get the Logger for the derived class so log messages
     * show up on the correct class
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * Save a FileList to the DB.
     *
     * @param fIn FileList to save
     */
    public static void saveFileList(FileList fIn) {
        singleton.saveObject(fIn);
    }

    /**
     * Create a new FileList
     *
     * @return a new FileList instance
     */
    public static FileList createFileList() {
        return new FileList();
    }

    /**
     * Remove a FileList from the DB.
     *
     * @param fIn FileLIst to remove
     * @return number of FileList affected by delete
     */
    public static int removeFileList(FileList fIn) {
        return singleton.removeObject(fIn);
    }

    /**
     * Lookup a FileList from the DB.
     * @param idIn to lookup
     * @param org to lookup in
     * @return FileList if found.
     */
    public static FileList lookupFileList(Long idIn, Org org) {
        Session session = null;
        //look for Kickstart data by id
        session = HibernateFactory.getSession();
        return (FileList) session.getNamedQuery("FileList.findByIdAndOrg")
                                      .setLong("id", idIn.longValue())
                                      .setLong("org_id", org.getId().longValue())
                                      .uniqueResult();
    }

    /**
     * Lookup a FileList from the DB.
     * @param labelIn to lookup
     * @param org to lookup in
     * @return FileList if found.
     */
    public static FileList lookupFileList(String labelIn, Org org) {
        Session session = null;
        //look for Kickstart data by label
        session = HibernateFactory.getSession();
        FileList list = (FileList) session.getNamedQuery("FileList.findByLabelAndOrg")
        .setString("label", labelIn)
        .setLong("org_id", org.getId().longValue())
        .uniqueResult();
        return list;
    }

    /**
     * Create a TinyUrl
     * @param urlIn to tinyfy
     * @param expires the date we *ADD* 6 hours to to set the expiration on the URL
     * @return TinyUrl instance
     */
    public static TinyUrl createTinyUrl(String urlIn, Date expires) {
        String token = RandomStringUtils.randomAlphanumeric(8);
        TinyUrl existing = lookupTinyUrl(token);
        while (existing != null) {
            log.warn("Had collision with: " + token);
            token = RandomStringUtils.randomAlphanumeric(8);
            existing = lookupTinyUrl(token);
        }

        TinyUrl url = new TinyUrl();
        Config c = new Config();
        url.setUrl(urlIn);
        url.setEnabled(true);
        url.setToken(token);
        Calendar pcal = Calendar.getInstance();
        pcal.setTime(expires);
        pcal.add(Calendar.HOUR, c.getInt("server.satellite.tiny_url_timeout", 4));
        url.setExpires(new Date(pcal.getTimeInMillis()));
        return url;
    }

    /**
     * Save a TinyUrl to the DB
     * @param urlIn to save.
     */
    public static void saveTinyUrl(TinyUrl urlIn) {
        singleton.saveObject(urlIn);
    }

    /**
     * Lookup a TinyUrl by its "token"
     * @param tokenIn to lookup by
     * @return TinyUrl if found
     */
    public static TinyUrl lookupTinyUrl(String tokenIn) {
        Session session = HibernateFactory.getSession();
        return (TinyUrl) session.getNamedQuery("TinyUrl.findByToken")
                                      .setString("token", tokenIn)
                                      .uniqueResult();
    }
}
