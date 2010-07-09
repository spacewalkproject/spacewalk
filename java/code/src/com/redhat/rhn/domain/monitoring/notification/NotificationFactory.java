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
package com.redhat.rhn.domain.monitoring.notification;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateRuntimeException;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * NotificationFactory - the singleton class used to fetch and store
 * com.redhat.rhn.domain.monitoring.notification.* objects from the
 * database.
 * @version $Rev: 51602 $
 */
public class NotificationFactory extends HibernateFactory {


    public static final FilterType FILTER_TYPE_REDIR = lookupFilterType("REDIR");

    public static final FilterType FILTER_TYPE_ACK = lookupFilterType("ACK");

    public static final FilterType FILTER_TYPE_BLACKHOLE = lookupFilterType("BLACKHOLE");

    public static final FilterType FILTER_TYPE_METOO = lookupFilterType("METOO");

    private static final List FILTER_TYPES;

    static {
        List types = new ArrayList();
        types.add(FILTER_TYPE_REDIR);
        types.add(FILTER_TYPE_ACK);
        types.add(FILTER_TYPE_BLACKHOLE);
        types.add(FILTER_TYPE_METOO);
        FILTER_TYPES = Collections.unmodifiableList(types);
    }

    /** Default Format class for Notification Methods */

    public static final Format FORMAT_DEFAULT = lookupFormat(new Long(4));

    public static final MethodType TYPE_PAGER = lookupMethodType(new Long(1));

    public static final MethodType TYPE_EMAIL = lookupMethodType(new Long(2));

    public static final MethodType TYPE_GROUP = lookupMethodType(new Long(4));

    public static final MethodType TYPE_SNMP = lookupMethodType(new Long(5));

    private static NotificationFactory singleton = new NotificationFactory();
    private static Logger log = Logger.getLogger(NotificationFactory.class);

    private NotificationFactory() {
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
     * Create a new ContactGroup.  Sets up proper defaults.
     * @param creator who owns this group
     * @return ContactGroup created
     */
    public static ContactGroup createContactGroup(User creator) {
        ContactGroup cg = new ContactGroup();
        cg.setAckWait(new Long(0));
        cg.setCustomerId(creator.getOrg().getId());
        cg.setStrategyId(new Long(1));
        cg.setNotificationFormatId(NotificationFactory.TYPE_GROUP.getId());
        cg.setRotateFirst("0");
        cg.setStrategyId(new Long(1));
        return cg;
    }

    /**
     * Store a notification Filter
     *
     * @param filterIn Filter to save.
     * @param currentUser who is saving the Filter
     */
    public static void saveFilter(Filter filterIn, User currentUser) {
        filterIn.setLastUpdateDate(new Date());
        filterIn.setLastUpdateUser(currentUser.getLogin());
        singleton.saveObject(filterIn);
    }

    /**
     * Lookup a Filter
     * @param id of the Filter
     * @param currentUser who wants to lookup
     * @return Filter if found, null if not
     */
    public static Filter lookupFilter(Long id, User currentUser) {
        Map params = new HashMap();
        params.put("fid", id);
        params.put("orgId", currentUser.getOrg().getId());
        return (Filter) singleton.lookupObjectByNamedQuery(
                                       "Filter.findByIdandOrgId", params);
    }

    /**
     * Return a list of all filter typ insert="false" update="falsees
     * @return a list of all filter types
     */
    public static List listFilterTypes() {
        return FILTER_TYPES;
    }

    /**
     * Return the filter type with the given name
     * @param type the name of the filter type
     * @return the filter type with the given name
     */
    public static FilterType lookupFilterType(String type) {
        FilterType retval = null;
        try {
            retval = (FilterType) getSession().get(FilterType.class, type);
        }
        catch (HibernateException e) {
            throw new
                HibernateRuntimeException("Exception looking up FilterType: " + e, e);
        }
        return retval;
    }

    /**
     * Lookup a Format.
     * @param idIn  of the Format
     * @return Format found
     */
    private static Format lookupFormat(Long idIn) {
        Format retval = null;
        try {
            retval = (Format) getSession().get(Format.class, idIn);

        }
        catch (HibernateException e) {
            throw new
                HibernateRuntimeException("Exception looking up Format: " + e, e);
        }
        return retval;
    }

    /**
     * Lookup a Format.
     * @param idIn  of the Format
     * @return Format found
     */
    private static MethodType lookupMethodType(Long idIn) {
        MethodType retval = null;
        try {
            retval = (MethodType) getSession().get(MethodType.class, idIn);

        }
        catch (HibernateException e) {
            throw new
                HibernateRuntimeException("Exception looking up MethodType: " + e, e);
        }
        return retval;
    }

    /**
     * Store a notification Method
     *
     * @param methodIn Method to save.
     * @param currentUser who is saving the Method
     */
    public static void saveMethod(Method methodIn, User currentUser) {
        methodIn.setLastUpdateDate(new Date());
        methodIn.setLastUpdateUser(currentUser.getLogin());
        singleton.saveObject(methodIn);
    }

    /**
     * Lookup a Notification Method from the db.
     * @param methodId we want to lookup
     * @param currentUser Current user doing the lookup.
     * @return Method if found.
     */
    public static Method lookupMethod(Long methodId, User currentUser) {
        Method retval = null;
        try {
            retval = (Method) getSession().get(Method.class, methodId);

        }
        catch (HibernateException e) {
            throw new
                HibernateRuntimeException("Exception looking up Method: " + e, e);
        }
        // Security check since the
        if (retval != null && retval.getUser().getOrg().equals(currentUser.getOrg())) {
            return retval;
        }
        else {
            return null;
        }
    }

    /**
     * Lookup a Method by methodName and userId
     * @param methodName of the Method
     * @param userId of the User who owns the method
     * @return Method if found.
     */
    public static Method lookupMethodByNameAndUser(String methodName, Long userId) {
        Map params = new HashMap();
        params.put("name", methodName);
        params.put("userId", userId);
        return (Method) singleton.lookupObjectByNamedQuery(
                                       "Method.findByNameAndUserId", params);
    }

    /**
     * Save a ContactGroup
     * @param userIn who is saving the ContactGroup
     * @param cg to save
     */
    public static void saveContactGroup(User userIn, ContactGroup cg) {
        cg.setLastUpdateDate(new Date());
        cg.setLastUpdateUser(userIn.getLogin());
        singleton.saveObject(cg);
    }

    /**
     * Lookup a ContactGroup by name
     * @param methodName to lookup
     * @return ContactGroup found.  Null if not
     */
    public static ContactGroup lookupContactGroupByName(String methodName) {
        Map params = new HashMap();
        params.put("name", methodName);
        return (ContactGroup) singleton.lookupObjectByNamedQuery(
                                       "ContactGroup.findByName", params);
    }
}

