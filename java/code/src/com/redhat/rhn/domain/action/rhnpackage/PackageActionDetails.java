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
package com.redhat.rhn.domain.action.rhnpackage;

import com.redhat.rhn.domain.action.ActionChild;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageName;

import org.apache.commons.lang.builder.EqualsBuilder;

import java.util.HashSet;
import java.util.Set;

/**
 * PackageActionDetails
 * @version $Rev$
 */
public class PackageActionDetails extends ActionChild {

    private Long packageId;
    private PackageName packageName;
    private PackageEvr evr;
    private String parameter;
    private PackageArch arch;
    private Set results = new HashSet();
    
    /**
     * @param resultsIn The results to set.
     */
    public void setResults(Set resultsIn) {
        this.results = resultsIn;
    }
    /**
     * @return Returns the results.
     */
    public Set getResults() {
        return results;
    }
    /**
     * @param r The result to add.
     */
    public void addResult(PackageActionResult r) {
        r.setDetails(this);
        results.add(r);
    }
    /**
     * @return Returns the arch.
     */
    public PackageArch getArch() {
        return arch;
    }
    
    /**
     * @param a The arch to set.
     */
    public void setArch(PackageArch a) {
        this.arch = a;
    }
    
    /**
     * @return Returns the evr.
     */
    public PackageEvr getEvr() {
        return evr;
    }
    
    /**
     * @param e The evr to set.
     */
    public void setEvr(PackageEvr e) {
        this.evr = e;
    }
    
    /**
     * @return Returns the id.
     */
    public Long getPackageId() {
        return packageId;
    }
    
    /**
     * @param i The id to set.
     */
    public void setPackageId(Long i) {
        this.packageId = i;
    }
    
    /**
     * @return Returns the packageName.
     */
    public PackageName getPackageName() {
        return packageName;
    }
    
    /**
     * @param n The packageName to set.
     */
    public void setPackageName(PackageName n) {
        this.packageName = n;
    }
    
    /**
     * @return Returns the parameter.
     */
    public String getParameter() {
        return parameter;
    }
    
    /**
     * @param p The parameter to set.
     */
    public void setParameter(String p) {
        this.parameter = p;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (other == null || !(other instanceof PackageActionDetails)) {
            return false;
        }
        PackageActionDetails castOther = (PackageActionDetails) other;
        return new EqualsBuilder().append((getParentAction() == null ? null : 
                                       getParentAction().getId()), 
                                       (castOther.getParentAction() == null ? null :
                                       castOther.getParentAction().getId()))
                                  .append(packageId, castOther.getPackageId())
                                  .append(parameter, castOther.getParameter())
                                  .append(packageName, castOther.getPackageName())
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        int result = 37 * (getParentAction() == null ? 0 :
                          (getParentAction().getId() == null ? 0 :
                           getParentAction().getId().intValue()));
        result += 37 * (packageId == null ? 0 : packageId.intValue());
        result += 37 * (parameter == null ? 0 : parameter.hashCode());
        result += 37 * (packageName == null ? 0 : packageName.hashCode());
        return result;
    }
}
