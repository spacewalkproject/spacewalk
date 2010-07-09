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
package com.redhat.rhn.domain.config;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import java.util.Iterator;
import java.util.List;

/**
 *
 * ConfigChannelListProcessor
 * @version $Rev$
 */
public class ConfigChannelListProcessor {

    private void check(ConfigChannel cc) {
        if (cc == null) {
            String msg = "Trying to add an invalid value to the channels list";
            throw new IllegalArgumentException(msg);
        }
        else if (!cc.isGlobalChannel()) {
            String msg = "Trying to add/subscribe a NON-CENTRALLY" +
                          "-MANAGED Channel to a central channels list.";
            throw new IllegalArgumentException(msg);
        }
    }

    private void checkRank(int rank) {
        if (rank < 0) {
            String msg = "Invalid value for a position, position must be >= 0.";
            throw new IllegalArgumentException(msg);
        }

    }


    /**
     * Adds a configuration channel to an activation key, giving it the
     * highest value for the  position (or the lowest priority)
     * @param cfgChannels the base channel list to which
     *                          the new channel will be appended
     * @param cc The config channel to subscribe to
     */
    public void add(List cfgChannels, ConfigChannel cc) {
        add(cfgChannels, cc, cfgChannels.size());
    }

    /**
     * Adds a channel to an activation key at the given position
     * @param cfgChannels the base channel list to which
     *                          the new channel will be inserted at the given rank
     * @param cc the channel to subscribe
     * @param rank the positon/ranking of the channel in the system list,
     *                  must be > 0
     */

    public void add(List cfgChannels, ConfigChannel cc, int rank) {
        check(cc);
        checkRank(rank);
        cfgChannels.remove(cc);

        if (rank < cfgChannels.size()) {
            cfgChannels.add(rank, cc);
        }
        else {
            cfgChannels.add(cc);
        }
    }

    /**
     * Assumption here is that the security aspect
     *  of this the list removal is already taken care of
     *  i.e make sure that the user has the authority to remove
     *  these channels before embarking on it..
     * @param cfgChannels the config channels list from whom the
     *                    given channel will be removed..
     * @param cc the ConfigChannel to remove
     * @return returns true if the remove operation succeded
     */
    public boolean remove(List cfgChannels, ConfigChannel cc) {
        return cfgChannels.remove(cc);
    }

    /**
     * Assumption here is that the security aspect
     *  of this the list removal is already taken care of
     *  i.e make sure that the user has the authority to remove
     *  these channels before embarking on it..
     * @param cfgChannels the config channels list from whom the
     *                    given channel will be removed..
     * @param channelsToRemove the list of ConfigChannels to remove
     * @return returns true if the remove operation succeded
     */
    public boolean remove(List cfgChannels, List channelsToRemove) {
        boolean success = true;
        for (Iterator itr = channelsToRemove.iterator(); itr.hasNext();) {
            success = success && remove(cfgChannels, (ConfigChannel)itr.next());
        }
        return success;
    }


    /**
     * Removes all the  config channels associated
     * to this server.
     * Assumption here is that the security aspect
     *  of this the list removal is already taken care of
     *  i.e make sure that the user has the authority to clear
     *  these channels before embarking on it..
     * @param cfgChannels the config channels list that'll be cleared.
     */
    public void clear(List cfgChannels) {
            cfgChannels.clear();
    }

    /**
     * Replaces the list of the config channels
     * with the a new set of listings
     * this is done so that if a customer
     * provides , n channels and says these should be
     * by rankings, it should work...
     * Assumption here is that the security aspect
     *  of this the list removal is already taken care of
     *  i.e make sure that the user has the authority to replace
     *  these channels before embarking on it..
     *  @param oldChannels existing channels that'd be replace
     *  @param newChannels the contents of the new channels
     */
    public void replace(List<ConfigChannel> oldChannels, List<ConfigChannel> newChannels) {
        clear(oldChannels);
        for (ConfigChannel chan : newChannels) {
            add(oldChannels, chan);
        }
    }

    /**
     * Checks whether a user has the permission to
     * work with a list of ConfigChannels and raises an
     * LookupException  if the given user does NOT have access
     * to all the channels
     * @param user the user object to check for checking access
     * @param cfgChannels the list of channels to search on.
     */
    public void validateUserAccess(User user, List<ConfigChannel> cfgChannels) {
        ConfigurationManager cm = ConfigurationManager.getInstance();
        for (ConfigChannel cc : cfgChannels) {
            if (!user.hasRole(RoleFactory.ACTIVATION_KEY_ADMIN) &&
                        !cm.accessToChannel(user.getId(), cc.getId())) {
                LocalizationService ls = LocalizationService.getInstance();
                LookupException e = new LookupException(
                           "Could not find config channel with id=" + cc.getId());
                e.setLocalizedTitle(ls.getMessage("lookup.configchan.title"));
                e.setLocalizedReason1(ls.getMessage("lookup.configchan.reason1"));
                e.setLocalizedReason2(ls.getMessage("lookup.configchan.reason2"));
                throw e;
            }
        }
    }

}
