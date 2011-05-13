/**
 * Copyright (c) 2011 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc;

import com.redhat.rhn.FaultException;


/**
 * NoSuchConfigFilePathException
 * @version $Rev$
 */
public class NoSuchConfigFilePathException extends FaultException {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 3053597629652431490L;

    /**
     * Constructor
     * @param path config file path that doesn't exist
     */
    public NoSuchConfigFilePathException(String path) {
        super(-1029, "noSuchConfigFilePath", "No such configuration file path: " + path);
    }

    /**
     * Constructor
     * @param path config file path that doesn't exist
     * @param channelLabel in what channelLabel
     */
    public NoSuchConfigFilePathException(String path, String channelLabel) {
        super(-1029, "noSuchConfigFilePath", "No such configuration file path: " + path +
                " in config channel: " + channelLabel);
    }
}
