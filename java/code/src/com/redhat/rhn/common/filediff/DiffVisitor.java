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


/**
 * DiffVisitor represents any class that is going to visit hunks.
 * This could be a DiffWriter.
 * @version $Rev$
 */
public interface DiffVisitor {
    
    /**
     * Standard visitor
     * @param e ChangeHunk
     */
    void accept(ChangeHunk e);
    /**
     * Standard visitor
     * @param e DeleteHunk
     */
    void accept(DeleteHunk e);
    /**
     * Standard visitor
     * @param e MatchHunk
     */
    void accept(MatchHunk e);
    /**
     * Standard visitor
     * @param e InsertHunk
     */
    void accept(InsertHunk e);

}
