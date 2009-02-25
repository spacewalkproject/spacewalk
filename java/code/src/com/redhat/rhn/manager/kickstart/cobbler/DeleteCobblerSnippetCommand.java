/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.common.validator.ValidatorError;

import java.io.File;

/**
 * DeleteCobblerSnippetCommand
 * @version $Rev$
 */
public class DeleteCobblerSnippetCommand extends BaseCobblerSnippetCommand {
    
    /**
     * Creates a new delete command, loading the snippet by name
     *
     * @param name used to identify the snippet; cannot be <code>null</code>
     */
    public DeleteCobblerSnippetCommand(String name) {
        super();

        if (name == null) {
            throw new IllegalArgumentException("name cannot be null");
        }
    }
    
    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        File f = new File(this.snippet.getName());
        boolean success = f.delete();
        if (!success) {
            return new ValidatorError("cobbler.snippet.couldnotdelete.message");
        }
        return null;
    }
}
