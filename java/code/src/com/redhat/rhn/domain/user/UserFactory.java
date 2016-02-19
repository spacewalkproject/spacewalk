/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.domain.user;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.legacy.UserImpl;
import com.redhat.rhn.manager.session.SessionManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.hibernate.Query;
import org.hibernate.Session;

import java.sql.Types;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

/**
 * UserFactory  - the singleton class used to fetch and store
 * com.redhat.rhn.domain.user.User objects from the
 * database.
 * @version $Rev$
 */
public  class UserFactory extends HibernateFactory {

    private static final String USER_ID = "user_id";
    private static final String LOGIN_UC = "loginUc";
    private static final UserFactory SINGLETON = new UserFactory();
    protected static final Logger LOG = Logger.getLogger(UserFactory.class);

    private static List timeZoneList;

    private static final Role[] IMPLIEDROLESARRAY = { RoleFactory.CHANNEL_ADMIN,
            RoleFactory.CONFIG_ADMIN, RoleFactory.SYSTEM_GROUP_ADMIN,
            RoleFactory.ACTIVATION_KEY_ADMIN };

    /** List of Role objects that are applied if you are an Org_admin */
    public static final List <Role> IMPLIEDROLES = Arrays.asList(IMPLIEDROLESARRAY);

    public static final State ENABLED = loadState("enabled");
    public static final State DISABLED = loadState("disabled");


    protected UserFactory() {
        super();
    }

    /**
     * Helper method to load a user state by label. Should only be used to init the
     * static member vars of this class.
     * @param label The label of the state to lookup
     * @return Returns the appropriate state (or null).
     */
    private static State loadState(String label) {
        Session session = HibernateFactory.getSession();
        State state = (State) session.getNamedQuery("UserState.lookupByLabel")
                .setParameter("label", label)
                //Retrieve from cache if there
                .setCacheable(true)
                .uniqueResult();
        return state;
    }

    /**
     * Returns the responsible user (first org admin) of the org.
     * @param orgId Org id
     * @param r Role to search for (ORG_ADMIN)
     * @return the responsible user (first org admin) of the org.
     */
    public static User findResponsibleUser(Long orgId, Role r) {
        Session session = HibernateFactory.getSession();
        Iterator itr = session.getNamedQuery("User.findResponsibleUser")
                .setParameter("org_id", orgId)
                .setParameter("type_id", r.getId())
                //Retrieve from cache if there
                .list().iterator();
        if (itr.hasNext()) {
            // only care about the first one
            Object[] row = (Object[])itr.next();
            User u = createUser();
            u.setId((Long) row[0]);
            u.setLogin((String)row[1]);
            return u;
        }
        return null;
    }

    /**
     * Returns user (first org admin) of the org.
     * @param orgIn Org id
     * @return the user (first org admin) of the org.
     */
    public static User findRandomOrgAdmin(Org orgIn) {
        Role r = RoleFactory.ORG_ADMIN;
        Session session = HibernateFactory.getSession();
        Iterator<Long> itr = session.getNamedQuery("User.findRandomOrgAdmin")
                .setParameter("org_id", orgIn.getId())
                .setParameter("type_id", r.getId())
                //Retrieve from cache if there
                .list().iterator();
        if (itr.hasNext()) {
            // only care about the first one
            return UserFactory.lookupById(itr.next());
        }
        return null;
    }

    /** Get the Logger for the derived class so log messages
     *   show up on the correct class
     */
    @Override
    protected Logger getLogger() {
        return LOG;
    }

    /**
     * Create a new user from scratch
     * @return the user created
     */
    public static User createUser() {
        return new UserImpl();
    }

    /**
     * Create a new address instance.
     * @return Address the address created
     */
    public static Address createAddress() {
        AddressImpl addr = new AddressImpl();
        addr.setPrivType(Address.TYPE_MARKETING);
        return addr;
    }

    /**
     * Save this instance of address
     * @param addr the address to save.
     */
    public static void saveAddress(Address addr) {
        getInstance().saveObject(addr);
    }

    /**
     * Lookup a user by their id
     * @param id the id to search for
     * @return the user found
     */
    public static User lookupById(Long id) {
        Session session = HibernateFactory.getSession();
        User u = (User)session.get(UserImpl.class, id);
        return u;
    }


    /**
     * Get users by their ids.
     *
     * If the incoming list has more than 1000 entries, we'll chop it up and run several
     * queries, re-assembling the results in application code. This is to accommodate
     * Oracle's ORA-01795 error "maximum number of expressions in a list is 1000".
     *
     * @param ids the ids to lookup for
     * @return the list of com.redhat.rhn.domain.User objects found
     */
    public static List<User> lookupByIds(Collection<Long> ids) {
        if (ids.size() < 1000) {
            return realLookupByIds(ids);
        }

        List<User> results = new LinkedList<User>();
        List<Long> blockOfIds = new LinkedList<Long>();
        for (Long uid : ids) {
            blockOfIds.add(uid);
            if (blockOfIds.size() == 999) {
                results.addAll(realLookupByIds(blockOfIds));
                blockOfIds = new LinkedList<Long>();
            }
        }
        // Deal with the remainder:
        if (blockOfIds.size() > 0) {
            results.addAll(realLookupByIds(blockOfIds));
        }
        return results;
    }

    private static List<User> realLookupByIds(Collection<Long> ids) {
        Session session = HibernateFactory.getSession();
        Query query = session.getNamedQuery("User.findByIds")
                .setParameterList("userIds", ids);
        return query.list();
    }

    /**
     * Lookup a user by their id, assuming that they are in the same Org as
     * the user doing the search.
     * @param user the user doing the search
     * @param id the id to search for
     * @return the user found
     */
    public static User lookupById(User user, Long id) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("uid", id);
        params.put("orgId", user.getOrg().getId());
        User returnedUser  = (User)getInstance().lookupObjectByNamedQuery(
                "User.findByIdandOrgId", params);
        if (returnedUser == null || !user.getOrg().equals(returnedUser.getOrg())) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException("Could not find user " + id);
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.user"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.user"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.user"));
            throw e;
        }
        return returnedUser;
    }

    /**
     * Lookup a user by their login
     * @param login the login to search by
     * @return the User found
     */
    public static User lookupByLogin(String login) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put(LOGIN_UC, login.toUpperCase());
        User user = (User)getInstance()
                .lookupObjectByNamedQuery("User.findByLogin", params);

        if (user == null) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException("Could not find user " + login);
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.user"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.user"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.user"));
            throw e;
        }
        return user;
    }

    /**
     * Lookup a user by their login
     * @param user the user doing the search
     * @param login the login to search by
     * @return the User found
     */
    public static User lookupByLogin(User user, String login) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put(LOGIN_UC, login.toUpperCase());
        params.put("orgId", user.getOrg().getId());
        User returnedUser  = (User)getInstance().lookupObjectByNamedQuery(
                "User.findByLoginAndOrgId", params);

        if (returnedUser == null) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException("Could not find user " + login);
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.user"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.user"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.user"));
            throw e;
        }
        return returnedUser;
    }

    /**
     * Gets a long value from the dataresult
     * @param dr The DataResult object containing the output
     * @param key The key for the output value
     * @return the long value
     */
    private static long getLongValue(DataResult dr, String key) {
        Long id = (Long)((Map)dr.get(0)).get(key);
        return id.longValue();
    }

    /**
     * Insert a new user.  Invalid to call this when updating a user
     * TODO: mmccune fill out the other fields in the user object.
     * @param usr The object we are commiting.
     * @param addr The address to add to the User
     * @param orgId Org this new user is a member of
     * @return User The freshly commited user.
     */

    public static User saveNewUser(User usr, Address addr, Long orgId) {
        return getInstance().addNewUser(usr, addr, orgId);
    }


    /**
     * Convenience method to determine whether a user is disabled
     * or not
     * @param user to check on...
     * @return Returns true if the user is disabled
     */
    public static boolean isDisabled(User user) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user", user);
        List <StateChange>  changes =  getInstance().
                listObjectsByNamedQuery("StateChanges.lookupByUserId", params);
        return changes != null && !changes.isEmpty() &&
                DISABLED.equals(changes.get(0).getState());
    }


    /**
     * Insert a new user.  Invalid to call this when updating a user
     * TODO: mmccune fill out the other fields in the user object.
     * @param usr The object we are commiting.
     * @param addr The address to add to the User
     * @param orgId Org this new user is a member of
     * @return User The freshly commited user.
     */
    protected User addNewUser(User usr, Address addr, Long orgId) {
        LOG.debug("Starting addNewUser");
        if (addr != null) {
            usr.setAddress1(addr.getAddress1());
            usr.setAddress2(addr.getAddress2());
            usr.setCity(addr.getCity());
            usr.setCountry(addr.getCountry());
            usr.setFax(addr.getFax());
            usr.setIsPoBox(addr.getIsPoBox());
            usr.setPhone(addr.getPhone());
            usr.setState(addr.getState());
            usr.setZip(addr.getZip());
        }
        // save the user
        CallableMode m = ModeFactory.getCallableMode("User_queries", "create_new_user");
        Map<String, Object> inParams = new HashMap<String, Object>();
        Map<String, Integer> outParams = new HashMap<String, Integer>();

        // Can't add the orgId to the object until the User has been
        // successfully added to the DB. Doing so will mean that if
        // there are problems, the user won't be rolled back properly.
        inParams.put("orgId", orgId);
        inParams.put("login", usr.getLogin());
        inParams.put("password", usr.getPassword());
        inParams.put("contactId", null);
        inParams.put("prefix", StringUtils.defaultString(usr.getPrefix(), " "));
        inParams.put("fname", StringUtils.defaultString(usr.getFirstNames(), null));
        inParams.put("lname", StringUtils.defaultString(usr.getLastName(), null));
        inParams.put("genqual", null);
        inParams.put("parentCompany", StringUtils.defaultIfEmpty(usr.getCompany(), null));
        inParams.put("company", StringUtils.defaultIfEmpty(usr.getCompany(), null));
        inParams.put("title", StringUtils.defaultIfEmpty(usr.getTitle(), null));
        inParams.put("phone", StringUtils.defaultIfEmpty(usr.getPhone(), null));
        inParams.put("fax", StringUtils.defaultIfEmpty(usr.getFax(), null));
        inParams.put("email", StringUtils.defaultIfEmpty(usr.getEmail(), null));
        inParams.put("pin", new Integer(0));
        inParams.put("fnameOl", " ");
        inParams.put("lnameOl", " ");
        inParams.put("addr1", StringUtils.defaultIfEmpty(usr.getAddress1(), null));
        inParams.put("addr2", StringUtils.defaultIfEmpty(usr.getAddress2(), null));
        inParams.put("addr3", " ");
        inParams.put("city", StringUtils.defaultIfEmpty(usr.getCity(), null));
        inParams.put("state", StringUtils.defaultIfEmpty(usr.getState(), null));
        inParams.put("zip", StringUtils.defaultIfEmpty(usr.getZip(), null));
        inParams.put("country", StringUtils.defaultIfEmpty(usr.getCountry(), null));
        inParams.put("altFnames", null);
        inParams.put("altLnames", null);
        inParams.put("contCall", "N");
        inParams.put("contMail", "N");
        inParams.put("contFax", "N");
        inParams.put("contEmail", "N");

        outParams.put("userId", new Integer(Types.NUMERIC));
        Map<String, Object> result = m.execute(inParams, outParams);

        Org org = OrgFactory.lookupById(orgId);
        if (org != null) {
            usr.setOrg(org);
        }

        long userId = ((Long) result.get("userId")).longValue();


        // We need to lookup the User to make sure that the Address in the
        // User object has an Id and that the User has an org_id.
        User retval = lookupById(new Long(userId));
        saveObject(retval);
        return retval;
    }

    /**
     * Insert or Update a user
     * @param user The object we are committing.
     */
    public static void save(User user) {
        getInstance().saveUser(user);
    }

    /**
     * Insert or Update a user
     * @param user The object we are committing.
     */
    protected void saveUser(User user) {
        LOG.debug("*********STARTING SAVE USER*********\n\n\n\n\n\n\n\n");
        if (user.getId() == null) {
            // New org, gotta use the stored procedure.
            throw new IllegalArgumentException("Only use commit for" +
                    " existing users");
        }
        saveObject(user);
        syncUserPerms(user);
    }

    /**
     * Syncs the user permissions with server group info..
     * @param usr the user to sync
     */
    protected void syncUserPerms(User usr) {
        // Here we are replacing the functionality in add/remove_from_usergroup
        // and update_perms_for_user stored procedures
        UserImpl uimpl = (UserImpl) usr;

        boolean orgAdminChanged = false;
        Boolean wasOrgAdmin = uimpl.wasOrgAdmin();
        if (wasOrgAdmin != null) {
            orgAdminChanged =
                    usr.hasRole(RoleFactory.ORG_ADMIN) != wasOrgAdmin.booleanValue();
        }

        if (orgAdminChanged) {
            syncServerGroupPerms(usr);
        }
        uimpl.resetWasOrgAdmin();
    }

    /**
     * Syncs the user permissions with server group info..
     * @param usr User to be synchronized.
     */
    public void syncServerGroupPerms(User usr) {
        CallableMode m = ModeFactory.getCallableMode("User_queries",
                "update_perms_for_user");
        Map<String, Object> inParams = new HashMap<String, Object>();
        inParams.put(USER_ID, usr.getId());
        m.execute(inParams, new HashMap<String, Integer>());
    }



    /**
     * Get the timezone by ID
     * @param id ID number for timezone
     * @return TimeZone the requested time zone
     */
    public static RhnTimeZone getTimeZone(int id) {
        Session session = HibernateFactory.getSession();
        return (RhnTimeZone) session.getNamedQuery("RhnTimeZone.loadTimeZoneById")
                .setInteger("tid", id)
                //Retrieve from cache if there
                .setCacheable(true)
                .uniqueResult();
    }

    /**
     * Get the timezone by olson name
     * @param olsonName olson name for timezone
     * @return TimeZone the requested time zone
     */
    public static RhnTimeZone getTimeZone(String olsonName) {
        Session session = HibernateFactory.getSession();
        return (RhnTimeZone) session
                .getNamedQuery("RhnTimeZone.loadTimeZoneByOlsonName")
                .setString("ton", olsonName)
                //Retrieve from cache if there
                .setCacheable(true)
                .uniqueResult();
    }

    /**
     * Gets the default time zone
     * @return US Eastern Time Zone
     */
    public static RhnTimeZone getDefaultTimeZone() {
        RhnTimeZone sysDefault = getTimeZone(TimeZone.getDefault().getID());
        if (sysDefault != null) {
            return sysDefault;
        }
        Session session = HibernateFactory.getSession();
        List<RhnTimeZone> allTimeZones =
                session.getNamedQuery("RhnTimeZone.loadAll").list();
        for (RhnTimeZone tz : allTimeZones) {
            if (TimeZone.getDefault().getRawOffset() == TimeZone.getTimeZone(
                    tz.getOlsonName()).getRawOffset()) {
                return tz;
            }
        }
        // This should not happen unless the timezone table is incomplete
        return getTimeZone("America/New_York");
    }

    /**
     * Get all timezones in apropriate order
     * @return List a list of timezones
     */
    public static List lookupAllTimeZones() {
        //timeZoneList is manually cached because instance variable is properly sorted
        //whereas the database is not.
        if (timeZoneList == null) {
            List timeZones = null; //temporary holding place until sorted
            Session session = HibernateFactory.getSession();
            timeZones = session.getNamedQuery("RhnTimeZone.loadAll").list();

            //Now sort the timezones. American timezones come first as they are 'preferred'
            //All other timezones are sorted and placed after American ones.
            //American timezones are sorted East to West based on raw off-set.
            //All other timezones are sorted West to East based on raw off-set.
            if (timeZones != null) {
                Collections.sort(timeZones, new Comparator() {
                    public int compare(Object o1, Object o2) {
                        RhnTimeZone t1 = (RhnTimeZone) o1;
                        RhnTimeZone t2 = (RhnTimeZone) o2;
                        Integer offSet1 = t1.getTimeZone().getRawOffset();
                        Integer offSet2 = t2.getTimeZone().getRawOffset();

                        if (offSet1 == 0 && offSet2 != 0) {
                            // first one GMT
                            return -1;
                        }

                        if (offSet1 != 0 && offSet2 == 0) {
                            // second one GMT
                            return 1;
                        }

                        if (offSet2.equals(offSet1)) {
                            return t2.getOlsonName().compareTo(t1.getOlsonName());
                        }

                        return offSet2.compareTo(offSet1);
                    }
                });
            }

            timeZoneList = timeZones;
        }
        return timeZoneList;
    }

    /**
     * Disable a user
     * @param userToDisable The user to disable
     * @param disabledBy The user committing the act
     */
    public void disable(User userToDisable, User disabledBy) {
        createStateChange(userToDisable, disabledBy, DISABLED);
        SessionManager.purgeUserSessions(userToDisable);
    }

    /**
     * Enable a user
     * @param userToEnable The user to enable
     * @param enabledBy The user committing the act
     */
    public void enable(User userToEnable, User enabledBy) {
        createStateChange(userToEnable, enabledBy, ENABLED);
    }

    /**
     * Helper method to do the work of disabling/enabling a user
     * @param victim The user to change
     * @param changer The user doing the changing
     * @param newState The state to change the user to
     */
    private void createStateChange(User victim, User changer, State newState) {
        //Create state change
        StateChange change = new StateChange();
        change.setUser(victim);
        change.setChangedBy(changer);
        change.setState(newState);
        //Add change to victim
        victim.addChange(change);
        save(victim);
    }

    /**
     * Method to determine whether a satellite has any users. Returns
     * true if satellite has one or more users, false otherwise.  Also
     * returns false if this method is called on a hosted installation.
     * @return true if satellite has one or more users, false otherwise.
     */
    public static boolean satelliteHasUsers() {
        SelectMode m = ModeFactory.getMode("User_queries", "user_count");
        DataResult dr = m.execute(new HashMap<String, Object>());
        Map row = (Map) dr.get(0);
        Long count = (Long) row.get("user_count");
        return (count.longValue() > 0);
    }

    /**
     *
     * @return an instance of user Factory
     */
    public static UserFactory getInstance() {
        return SINGLETON;
    }

    /**
     * Looks up the UserServerPreference corresponding to the given
     * user, server, and preference label
     * @param user user who the preference corresponds to
     * @param server server that preference corresponds to
     * @param name preference label we are looking for
     * @return UserServerPreference that corresponds to the parameters
     */
    public UserServerPreference lookupServerPreferenceByUserServerAndName(User user,
            Server server,
            String name) {
        UserServerPreferenceId id = new UserServerPreferenceId(user, server, name);
        Session session = HibernateFactory.getSession();
        return (UserServerPreference) session.get(UserServerPreference.class, id);
    }

    /**
     * Sets a UserServerPreference to true or false
     * @param user User whose preference will be set
     * @param server Server we are setting the perference on
     * @param preferenceName the name of the preference
     * @see com.redhat.rhn.domain.user.UserServerPreferenceId
     * @param value true if the preference should be true, false otherwise
     */
    public void setUserServerPreferenceValue(User user,
            Server server,
            String preferenceName,
            boolean value) {
        Session session = HibernateFactory.getSession();
        UserServerPreferenceId id = new UserServerPreferenceId(user,
                server,
                preferenceName);
        UserServerPreference usp = (UserServerPreference)
                session.get(UserServerPreference.class, id);

        /* Here, we delete the preference's entry if it should be true.
         * We would hopefully be ok setting the value to "1," but I'm emulating
         * the Perl side here just to be safe
         */
        if (value) {
            if (usp != null) {
                session.delete(usp);
            }
        }
        else {
            if (usp == null) {
                id = new UserServerPreferenceId(user, server, preferenceName);
                usp = new UserServerPreference();
                usp.setId(id);
                usp.setValue("0");
                session.save(usp);
            }
        }
    }

    /**
     * Return a list of all Users who has the given email.
     *
     * @param email String to find users for.
     * @return list of users.
     */
    public static List<User> lookupByEmail(String email) {
        Session session = HibernateFactory.getSession();
        Query query = session.getNamedQuery("User.findByEmail")
                .setParameter("userEmail", email);
        return query.list();
    }

    /**
     * Return a list of all User's who are in the given org.
     *
     * @param inOrg Org to find users for.
     * @return list of users.
     */
    public List<User> findAllUsers(Org inOrg) {
        Session session = HibernateFactory.getSession();
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", inOrg.getId());
        return listObjectsByNamedQuery("User.findAllUsersByOrg", params);
    }

    /**
     * Return a list of all User's who are org admins in the given org.
     *
     * @param inOrg Org to find administrators for.
     * @return list of users.
     */
    public List<User> findAllOrgAdmins(Org inOrg) {
        Session session = HibernateFactory.getSession();
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", inOrg.getId());
        return listObjectsByNamedQuery("User.findAllOrgAdmins", params);
    }

    /**
     * @param userId the user id
     */
    public static void deleteUser(Long userId) {
        CallableMode m = ModeFactory.getCallableMode("User_queries",
                "delete_user");
        Map<String, Object> inParams = new HashMap<String, Object>();
        Map<String, Integer> outParams = new HashMap<String, Integer>();
        inParams.put(USER_ID, userId);
        m.execute(inParams, outParams);
    }
}
