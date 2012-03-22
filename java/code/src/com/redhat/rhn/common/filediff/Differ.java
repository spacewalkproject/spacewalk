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
package com.redhat.rhn.common.filediff;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Java file diff using Eugene W. Myers's algorithm as described in
 * "An O(ND) Difference Algorithm and Its Variations".
 * @version $Rev$
 */
public class Differ {
    private final Trace head;
    private Trace beforeCurrent;
    private int bestSoFar;
    private static final int NUMBEROFTRACESTOKEEP = 1000;
    private final List<Integer> matches = new ArrayList<Integer>();

    /**
     * @param oldLength The length of the old file
     * @param newLength The length of the new file
     */
    public Differ(int oldLength, int newLength) {
        //we need a head element in order to do deletions.
        head = new Trace(0, 0); //the head of the linked list.
        head.setNext(new Trace(oldLength, newLength));
        beforeCurrent = head;
        bestSoFar = 0;
    }

    /**
     * @param oldFile The old(first, from) file
     * @param newFile The new(second, to) file
     * @return A list of Hunks representing the differences.
     */
    public List diff(String[] oldFile, String[] newFile) {
        List retval = null;
        while (retval == null) {
            retval = step(oldFile, newFile);
        }
        return retval;
    }

    /**
     * The crux of the optimization for this algorithm lies in the fact that we
     * will step through all of the traces in parallel rather than recursively.
     * This allows us to delete traces that are unlikely be the most optimal.
     *
     * We only consider the best {@value #NUMBEROFTRACESTOKEEP} traces at any
     * given time. This is to prevent the memory required from growing
     * exponentially in large files. The resulting trace is always guaranteed to
     * be *correct*, but maybe not *optimal*.
     *
     * This will call the step function on Trace for every current trace we
     * have. It will delete traces that are unlikely to be optimal.
     *
     * @param oldFile
     *            The old(first, from) file
     * @param newFile
     *            The new(second, to) file
     * @return A list of Hunks representing the differences. null if we need to
     *         step again
     */
    private List step(String[] oldFile, String[] newFile) {
        beforeCurrent = head;
        boolean forked;
        int minimumMatchValue = 0;

        // get a list of all match values for all traces
        while (beforeCurrent.next() != null) {
            beforeCurrent = beforeCurrent.next();
            matches.add(beforeCurrent.getMatches());
        }

        // if we have too many traces find the match number you need to beat to
        // remain valid
        if (matches.size() > NUMBEROFTRACESTOKEEP) {
            Collections.sort(matches); // sort ascending
            minimumMatchValue = matches.get(matches.size() -
                    NUMBEROFTRACESTOKEEP);
        }

        // reset things before the "real" iteration
        matches.clear();
        beforeCurrent = head;

        while (beforeCurrent.next() != null) {
            // delete impossible and unlikely traces.
            if (beforeCurrent.next().getMatches() < minimumMatchValue ||
                    bestSoFar > beforeCurrent.next().bestPossible()) {
                beforeCurrent.setNext(beforeCurrent.next().next());
            }
            else {
                forked = beforeCurrent.next().step(oldFile, newFile);

                //With the step algorithm, the first one to reach the end of
                //both files is the winner!
                if (beforeCurrent.next().isDone()) {
                    return beforeCurrent.next().createHunks(oldFile, newFile);
                }

                //update bestSoFar
                if (beforeCurrent.next().getMatches() > bestSoFar) {
                    bestSoFar = beforeCurrent.next().getMatches();
                }

                //if it forked, there is a new element in the linked list
                //that has already been dealt with, so skip it.
                if (forked) {
                    beforeCurrent = beforeCurrent.next().next();
                }
                else {
                    beforeCurrent = beforeCurrent.next();
                }
            }
        }
        return null; //null means we need to step again.
    }

}
