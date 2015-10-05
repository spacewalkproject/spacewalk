/**
 * Copyright (c) 2015 Red Hat, Inc.
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

package com.redhat.rhn.common.db;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.common.ResetPassword;
import com.redhat.rhn.domain.user.User;

/**
 * ResetPasswordFactory: API to create, find, delete, and manage ResetPassword
 * entries.
 *
 * @author ggainey
 * @Rev:
 *
 */
public class ResetPasswordFactory extends HibernateFactory {
    public static final String EXPIRE_TIME = "password_token_expiration_hours";
    private static ResetPasswordFactory singleton = new ResetPasswordFactory();
    private static Logger log = Logger.getLogger(ResetPasswordFactory.class);

    private ResetPasswordFactory() {
        super();
    }

    @Override
    protected Logger getLogger() {
        return log;
    }

    /**
     * Persist a RestPassword entity
     * @param rp ResetPassword to be persisted
     */
    public static void save(ResetPassword rp) {
        WriteMode wm = ModeFactory.getWriteMode("ResetPassword_queries",
                                                "insert_token");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", rp.getUserId());
        params.put("token", rp.getToken());
        wm.executeUpdate(params);
    }

    /**
     * Find a given ResetPassword entry by token.
     * @param token token of interest
     * @return ResetPassword, or null if none found
     */
    public static ResetPassword lookupByToken(String token) {
        SelectMode sm = ModeFactory.getMode("ResetPassword_queries",
                                            "find_by_token");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("token", token);
        DataResult<ResetPassword> dr = sm.execute(params);
        if (dr == null || dr.size() == 0) {
            return null;
        }
        else {
            return dr.get(0);
        }
    }

    /**
     * Invalidate all tokens for a specified user-id
     * @param uid user-id whose tokens are to be marked invalid
     * @return number of tokens invalidated
     */
    public static int invalidateUserTokens(Long uid) {
        WriteMode wm = ModeFactory.getWriteMode("ResetPassword_queries",
                                                "invalidate_user_tokens");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", uid);
        return wm.executeUpdate(params);
    }

    /**
     * Remove all tokens for a specified user-id. NOTE: this is generally Not Done,
     * for auditing purposes
     * @param uid user-id whose tokens are to be deleted
     * @return number of deleted rows
     */
    public static int deleteUserTokens(Long uid) {
        WriteMode wm = ModeFactory.getWriteMode("ResetPassword_queries",
                                                "delete_user_tokens");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", uid);
        return wm.executeUpdate(params);
    }

    /**
     * Create a unique one-use token for a specified User
     * @param u User whose password is to be reset
     * @return unique SHA1 hash
     */
    public static String generatePasswordToken(User u) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-1");
            // What matters is that the token cannot be guessed from publically-available
            // info (like timestamp or login or uid). A random UUID is 'something only
            // the server knows'
            UUID uuid = UUID.randomUUID();
            String hash = StringUtil.getHexString(md.digest(uuid.toString().getBytes()));
            while (lookupByToken(hash) != null) {
                uuid = UUID.randomUUID();
                hash = StringUtil.getHexString(md.digest(uuid.toString().getBytes()));
            }
            return hash;
        }
        catch (NoSuchAlgorithmException e) {
            log.error("Failed to find SHA-1?!?", e);
            return null;
        }
    }

    /**
     * Create a new ResetPassword entry for the specified user
     * @param u User whose password is to be reset
     * @return ResetPassword entity
     */
    public static ResetPassword createNewEntryFor(User u) {
        ResetPassword rp = new ResetPassword(u.getId(), generatePasswordToken(u));
        save(rp);
        return rp;
    }

    /**
     * Invalidate the specified token in the DB
     * @param token token to be marked as invalid
     */
    public static void invalidateToken(String token) {
        WriteMode wm = ModeFactory.getWriteMode("ResetPassword_queries",
                        "invalidate_token");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("token", token);
        wm.executeUpdate(params);
    }

    /**
     * Generate the URL for the specified ResetPassword token
     * @param rp ResetPassword of interest
     * @return URL leading to ResetLink on 'this' machine, with the token of interest
     */
    public static String generateLink(ResetPassword rp) {
        String link = "https://" + ConfigDefaults.get().getHostname() +
                      "/rhn/ResetLink.do?token=" + rp.getToken();
        return link;
    }

    /**
     * Report problems with a ResetPassword entity
     * @param rp ResetPassword of interest
     * @return ActionErrors list - isEmpty() means "no errors found"
     */
    public static ActionErrors findErrors(ResetPassword rp) {
        log.debug("findErrors : [" + (rp == null ? "null" : rp.toString()) + "]");
        ActionErrors errors = new ActionErrors();
        if (rp == null) {
            log.debug("findErrors: no RP found");
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("resetpassword.jsp.error.notoken"));
        }
        else if (!rp.isValid()) {
            log.debug("findErrors: invalid RP found");
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("resetpassword.jsp.error.invalidtoken"));

        }
        else if (rp.isExpired()) {
            log.debug("findErrors: expired RP found");
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                       new ActionMessage("resetpassword.jsp.error.expiredtoken"));
        }
        return errors;
    }

}
