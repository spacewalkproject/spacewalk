/**
 * Copyright (c) 2012 Red Hat, Inc.
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

package com.redhat.rhn.manager.errata;

import java.util.Hashtable;

/**
 * If someone attempts to schedule a synchronous errata clone into a
 * channel that has asynchronous errata clones taking place in the
 * background, a database deadlock will occur. There is no way to
 * avoid the deadlock, so instead we'll keep track of how many
 * pending jobs we have here. The jobs themselves are not persistent,
 * residing in tomcat memory only, so the counter should not be
 * persistent. That is why I implemented the counter as a singeton
 * class instead of a database table or some other such implementation.
 *
 * @author Stephen Herr <sherr@redhat.com>
 *
 */
public class AsyncErrataCloneCounter {
    // hashtable is syncronized, so is threadsafe
    private final Hashtable<Long, Integer> count;
    private static AsyncErrataCloneCounter instance = new AsyncErrataCloneCounter();

    private AsyncErrataCloneCounter() {
        count = new Hashtable<Long, Integer>();
    }

    /**
     * Get the one and only instance of AsyncErrataCloneCounter
     * @return the singleton instance
     */
    public static AsyncErrataCloneCounter getInstance() {
        return instance;
    }

    /**
     * Check if a channel has pending asyncrhonous errata clone jobs
     * @param cid channel id
     * @return True if there are pending jobs for a channel, false otherwise
     */
    public boolean channelHasPendingJobs(Long cid) {
        Integer n = count.get(cid);
        if (n == null || n == 0) {
            return false;
        }
        return true;
    }

    /**
     * Call this with the channel id when scheduling a new asyncronous
     * errata clone job
     * @param cid channel id
     */
    public void addAsyncErrataCloneJob(Long cid) {
        Integer n = count.get(cid);
        if (n != null) {
            count.put(cid, n + 1);
        }
        else {
            count.put(cid, 1);
        }
    }

    /**
     * Call this with channel id when completeing an asynchronous
     * errata clone job
     * @param cid channel id
     */
    public void removeAsyncErrataCloneJob(Long cid) {
        Integer n = count.get(cid);
        if (n != null && n > 0) {
            count.put(cid, n - 1);
        }
    }
}
