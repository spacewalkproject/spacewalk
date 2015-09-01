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

import org.apache.log4j.Logger;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.common.ResetPassword;
import com.redhat.rhn.domain.user.User;

public class ResetPasswordFactory extends HibernateFactory {
    private static ResetPasswordFactory singleton = new ResetPasswordFactory();
    private static Logger log = Logger.getLogger(ResetPasswordFactory.class);

    private ResetPasswordFactory() {
        super();
    }

    @Override
    protected Logger getLogger() {
        return log;
    }

    public static void save(ResetPassword rp) {
        WriteMode wm = ModeFactory.getWriteMode("ResetPassword_queries",
                                                "insert_token");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", rp.getUserId());
        params.put("token", rp.getToken());
        wm.executeUpdate(params);
    }

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

    public static int invalidateUserTokens(Long uid) {
        WriteMode wm = ModeFactory.getWriteMode("ResetPassword_queries",
                                                "invalidate_user_tokens");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", uid);
        return wm.executeUpdate(params);
    }

    public static int deleteUserTokens(Long uid) {
        WriteMode wm = ModeFactory.getWriteMode("ResetPassword_queries",
                                                "delete_user_tokens");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", uid);
        return wm.executeUpdate(params);
    }

    public static String generatePasswordToken(User u) {
        try {
            int retryCounter = 0;
            MessageDigest md = MessageDigest.getInstance("SHA-1");
            String input = retryCounter++ +
                            ":" + u.getId().toString() +
                            ":" + System.currentTimeMillis();
            String hash = StringUtil.getHexString(md.digest(input.getBytes()));
            while (lookupByToken(hash) != null) {
                input = retryCounter++ +
                        ":" + u.getId().toString() +
                        ":" + System.currentTimeMillis();
                hash = StringUtil.getHexString(md.digest(input.getBytes()));
            }
            return StringUtil.getHexString(md.digest(hash.getBytes()));
        }
        catch (NoSuchAlgorithmException e) {
            singleton.getLogger().error("Failed to find SHA-1?!?", e);
            return null;
        }
    }

    public static ResetPassword createNewEntryFor(User u) {
        invalidateUserTokens(u.getId());
        ResetPassword rp = new ResetPassword(u.getId(), generatePasswordToken(u));
        save(rp);
        return rp;
    }
}
