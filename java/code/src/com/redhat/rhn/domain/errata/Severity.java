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
package com.redhat.rhn.domain.errata;

import com.redhat.rhn.common.localization.LocalizationService;

import java.util.Map;
import java.util.HashMap;

/**
 * Errata Severity
 *
 * @version $Rev $
 */
public class Severity {

    // WARNING: These must stay in sync with the values in rhnErrataSeverity
    // there's no need to keep 'unspecified' in db, it equals to null...
    public static final String LOW_LABEL = "errata.sev.label.low";
    public static final String MODERATE_LABEL = "errata.sev.label.moderate";
    public static final String IMPORTANT_LABEL = "errata.sev.label.important";
    public static final String CRITICAL_LABEL = "errata.sev.label.critical";
    public static final String UNSPECIFIED_LABEL = "errata.sev.label.unspecified";

    //dummy rank for webui selects
    public static final Integer UNSPECIFIED_RANK = 4;

    private long id;
    private int rank;
    private String label;

    /**
     * Severity id
     * @param idIn id to set
     */
    public void setId(long idIn) {
        id = idIn;
    }

    /**
     * Severity id
     * @return id from DB
     */
    public long getId() {
        return id;
    }

    /**
     * Sortable rank
     * @param rankIn rank to sort by
     */
    public void setRank(int rankIn) {
        rank = rankIn;
    }

    /**
     * Sortable rank
     * @return rank to sort by
     */
    public int getRank() {
        return rank;
    }

    /**
     * Label for the severity
     * Labels are resource bundle keys
     * @param labelIn label to set
     */
    public void setLabel(String labelIn) {
        label = labelIn;
    }

    /**
     * Label for the severity
     * Labels are resource bundle keys
     * @return severity label
     */
    public String getLabel() {
        return label;
    }

    /**
     * Looks up label in resource bundle
     * @return localized string corresponding to severity label
     */
    public String getLocalizedLabel() {
        String retval = null;
        if (label != null) {
            retval = LocalizationService.getInstance().getMessage(label);
        }
        return retval;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return "Id: " + getId() + ", Rank: " + getRank() + ", Label: " + getLabel() +
            ", Localized label: " + getLocalizedLabel();
    }

    /**
     * Looks up corresponding Severity object by given id
     * @return Severity object
     * @param id severity_id
     */
    public static Severity getById(Integer id) {
        Map<Integer, String> severityMap = new HashMap<Integer, String>();
        Severity newSeverity = new Severity();
        severityMap.put(0, CRITICAL_LABEL);
        severityMap.put(1, IMPORTANT_LABEL);
        severityMap.put(2, MODERATE_LABEL);
        severityMap.put(3, LOW_LABEL);
        if (severityMap.get(id) == null) {
            return null;
        }
        newSeverity.setId(id);
        newSeverity.setLabel(severityMap.get(id));
        newSeverity.setRank(id);
        return newSeverity;
    }
}
