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
package com.redhat.rhn.domain.kickstart;

/**
 * Constants defining Kickstart Hibernate queries
 * @version $Rev $
 */
public class KickstartQueries {
    
    public static final String KICKSTARTABLE_TREE_FIND_BY_ID = 
        "KickstartableTree.findById";
    
    public static final String KICKSTARTABLE_TREE_FIND_BY_LABEL_ORG = 
        "KickstartableTree.findByLabelAndOrg";
    
    public static final String KICKSTARTABLE_TREE_FIND_BY_LABEL_NULL_ORG = 
        "KickstartableTree.findByLabelAndNullOrg";
    
    public static final String KICKSTARTABLE_TREE_FIND_BY_CHANNEL_ORG = 
        "KickstartableTree.findByChannelAndOrg";
    
    public static final String KICKSTART_CMD_FIND_BY_ID = "KickstartComandName.findById";
    
    public static final String KICKSTART_CMD_FIND_BY_LABEL = 
        "KickstartCommandName.findByLabel";
    
    public static final String KICKSTART_CMD_LIST_ADVANCED_OPTIONS =
        "KickstartCommandName.listAdvancedOptions";
    
    public static final String KICKSTART_CMD_NAME_REQUIRED_OPTIONS = 
        "KickstartCommandName.requiredOptions";
    
    
    // Prevent constant class from being instantiated
    private KickstartQueries() {
        
    }
}
