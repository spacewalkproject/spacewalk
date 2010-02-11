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
package com.redhat.rhn.frontend.dto;

/**
 * BaseListDto
 * @version $Rev$
 */
public interface BaseListDto {

    /** 
     * If false is returned, the unpagedListDisplay rendering
     * the dto will use the color of the previous row when
     * it renders the row representing this particular instance
     * of the dto.
     * @return true if the row should change colors, false otherwise
     */
    boolean changeRowColor();
    
    /**
     * If false is returned, row is rendered normally.
     * Else, row is rendered "greyed-out"
     * @return true if row should be greyed out, false otherwise
     */
    boolean greyOutRow();
    
    /**
     * @return a id string in the form of "p*id*" or
     * "c*id* depending on whether or not the node is considered
     * a child or not
     */
    String getNodeIdString();
}
