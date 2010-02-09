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
 * An interface for all views for diffs.
 * Any class that implements this one should probably also implement DiffVisitor.
 * @version $Rev$
 */
public interface DiffWriter {
    
    /**
     * Write the diff, one hunk at a time.
     * @param hunk A collection of lines for a diff that represents a similar edit state
     */
    void writeHunk(Hunk hunk);

}
