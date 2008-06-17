/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.common.cert;

import com.redhat.rhn.frontend.html.XmlTag;

import java.security.SignatureException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;

/**
 * A satellite server certificate.
 * 
 * @version $Rev$
 */
public class Certificate {

    public static final String CURRENT_GENERATION = "2";
    // Some of these properties should probably be int's or Date's
    // But until that is really needed, we'll stick with Strings

    private String product;
    private String owner;
    private String issued;
    private String expires;
    private String slots;
    private String provisioningSlots;
    private String monitoringSlots;
    private String virtualizationSlots;
    private String virtualizationPlatformSlots;
    private String nonlinuxSlots;
    private String satelliteVersion;
    private String generation;
    private String signature;
    private List channelFamilies;
    private static final String XML_HEADER =
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";

    /**
     * Construct an empty certificate.
     */
    Certificate() {
        channelFamilies = new ArrayList();
    }

    /**
     * States whether or not this certificate is expired.
     * @return true iff <code>expires</code> is after current system time
     * @throws ParseException this shouldn't happen, means the date format in the cert is
     *  not what we expect
     */
    public boolean isExpired() throws ParseException {
        Date now = Calendar.getInstance().getTime();
        return now.after(this.getExpiresDate());
    }
    
    /**
     * Convert this certificate into the canonical form
     * used for signing.
     * 
     * @return the certificate in the canonical form used for signing
     */
    public String asChecksumString() {
        StringBuffer result = new StringBuffer();
        // Fields must appear in the output in alphabetical order
        // The channelFamilies are sorted in their very own way
        // (see ChannelFamily.compareTo)
        Collections.sort(channelFamilies);
        for (int i = 0; i < channelFamilies.size(); i++) {
            ChannelFamilyDescriptor cf = (ChannelFamilyDescriptor) channelFamilies.get(i);
            result.append(cf.asChecksumString()).append("\n");
        }
        appendField(result, "expires", getExpires());
        appendField(result, "generation", getGeneration());
        appendField(result, "issued", getIssued());
        appendField(result, "monitoring-slots", getMonitoringSlots());
        appendField(result, "nonlinux-slots", getNonlinuxSlots());
        appendField(result, "owner", getOwner());
        appendField(result, "product", getProduct());
        appendField(result, "provisioning-slots", getProvisioningSlots());
        appendField(result, "satellite-version", getSatelliteVersion());
        appendField(result, "slots", getSlots());
        appendField(result, "virtualization_host", this.getVirtualizationSlots());
        appendField(result, "virtualization_host_platform", 
                                           this.getVirtualizationPlatformSlots());
        return result.toString();
    }
    
    /**
     * Returns the XML representation of the cert.
     * @return the XML representation of the cert.
     */
    public String asXmlString() {
        StringBuffer buf = new StringBuffer();
        
        buf.append(XML_HEADER).append("\n");
        
        XmlTag t = new XmlTag("rhn-cert");
        t.setAttribute("version", "0.1");
        buf.append(t.renderOpenTag()).append("\n");

        appendXmlField(buf, "product", getProduct());
        appendXmlField(buf, "owner", getOwner());
        appendXmlField(buf, "issued", getIssued());
        appendXmlField(buf, "expires", getExpires());
        appendXmlField(buf, "slots", getSlots());
        appendXmlField(buf, "monitoring-slots", getMonitoringSlots());
        appendXmlField(buf, "provisioning-slots", getProvisioningSlots());
        appendXmlField(buf, "nonlinux-slots", getNonlinuxSlots());
        appendXmlField(buf, "virtualization_host", this.getVirtualizationSlots());
        appendXmlField(buf, "virtualization_host_platform", 
                                           this.getVirtualizationPlatformSlots());

        for (int i = 0; i < channelFamilies.size(); i++) {
            ChannelFamilyDescriptor cf = (ChannelFamilyDescriptor) channelFamilies.get(i);
            buf.append("  ").append(cf.asXmlString()).append("\n");
        }
        
        appendXmlField(buf, "satellite-version", getSatelliteVersion());
        appendXmlField(buf, "generation", getGeneration());
        
        XmlTag sig = new XmlTag("rhn-cert-signature");
        sig.addBody(getSignature());
        buf.append("  ").append(sig.render()).append("\n");
        
        buf.append(t.renderCloseTag()).append("\n");
        return buf.toString();
    }
    
    private void appendXmlField(StringBuffer result, String fieldName, String value) {
        if (value != null) {
            XmlTag t = new XmlTag("rhn-cert-field", false);
            t.setAttribute("name", fieldName);
            t.addBody(value);
            result.append("  ").append(t.render()).append('\n');
        }
    }

    /**
     * Check that this certificate was signed with a private key
     * whose public counterpart is on <code>keyRing</code> 
     * @param keyRing the public keys with which to check the signatures
     * @return <code>true</code> if this certificate was signed with a private key
     * whose public counterpart is on <code>keyRing</code>, <code>false</code> otherwise
     * @throws SignatureException if processing the sigature fails
     */
    public boolean verifySignature(PublicKeyRing keyRing)
        throws SignatureException {
        return keyRing.verifySignature(asChecksumString(), getSignature());
    }

    // Setters. They shouldn't be public, but have to be
    // since we use reflection to populate the certificate
    // when reading from XML.

    /**
     * Add a channel family
     * @param family the channel family to add
     */
    public void addChannelFamily(ChannelFamilyDescriptor family) {
        channelFamilies.add(family);
    }

    /**
     * Set the expiration date for the certificate
     * @param expires0 the expiration date
     */
    public void setExpires(String expires0) {
        expires = expires0;
    }

    /**
     * Set the generation
     * @param generation0 the generation
     */
    public void setGeneration(String generation0) {
        generation = generation0;
    }

    /**
     * Set the date of issue
     * @param issued0 date of issue
     */
    public void setIssued(String issued0) {
        issued = issued0;
    }

    /**
     * Set the number of non-linux slots
     * @param nonlinuxSlots0 the number of non-linux slots
     */
    public void setNonlinuxSlots(String nonlinuxSlots0) {
        nonlinuxSlots = nonlinuxSlots0;
    }

    /**
     * Set the number of monitoring slots
     * @param monitoringSlots0 the number of monitoring slots
     */
    public void setMonitoringSlots(String monitoringSlots0) {
        monitoringSlots = monitoringSlots0;
    }

    /**
     * Set the owner
     * @param owner0 the owner
     */
    public void setOwner(String owner0) {
        owner = owner0;
    }

    /**
     * Set the product
     * @param product0 the product
     */
    public void setProduct(String product0) {
        product = product0;
    }

    /**
     * Set the number of provisioning slots
     * @param provisioningSlots0 the number of provisioning slots
     */
    public void setProvisioningSlots(String provisioningSlots0) {
        provisioningSlots = provisioningSlots0;
    }

    /**
     * Set the satellite version
     * @param satelliteVersion0 the satellite version
     */
    public void setSatelliteVersion(String satelliteVersion0) {
        satelliteVersion = satelliteVersion0;
    }

    /**
     * Set the signature as an ASCII armored string
     * @param signature0 the ASCII armored signature
     */
    public void setSignature(String signature0) {
        signature = signature0;
    }

    /**
     * Set the number of slots
     * @param slots0 the number of slots
     */
    public void setSlots(String slots0) {
        slots = slots0;
    }

    /**
     * Set the number of virtualization slots
     * @param virtualizationSlots0 the number of virtualization slots
     */
    public void setVirtualizationSlots(String virtualizationSlots0) {
        virtualizationSlots = virtualizationSlots0;
    }
    
    /**
     * Set the number of virtualization platform slots
     * @param virtualizationSlots0 the number of virtualization platform slots
     */
    public void setVirtualizationPlatformSlots(String virtualizationSlots0) {
        virtualizationPlatformSlots = virtualizationSlots0;
    }

    // Getters

    /**
     * Return an unmodifiable list of the channel families
     * @return an unmodifiable list of the channel families
     */
    public List getChannelFamilies() {
        return Collections.unmodifiableList(channelFamilies);
    }

    /**
     * Return the channel family with name <code>family</code>,
     * or <code>null</code> if no such family exists.
     * @param family the name of the family
     * @return the channel family with name <code>family</code>,
     * or <code>null</code> if no such family exists.
     */
    public ChannelFamilyDescriptor getChannelFamily(String family) {
        for (int i = 0; i < channelFamilies.size(); i++) {
            ChannelFamilyDescriptor f = (ChannelFamilyDescriptor) channelFamilies.get(i);
            if (f.getFamily().equals(family)) {
                return f;
            }
        }
        return null;
    }

    /**
     * Get the expiration date
     * @return the expiration date
     */
    public String getExpires() {
        return expires;
    }
    
    /**
     * Convenience function, returns java.util.Date equivalent of <code>expires</code>
     * @return Date obj equivalent of <code>expires</code>
     * @throws ParseException format of <code>expires</code> not what we expected
     */
    public Date getExpiresDate() throws ParseException {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        return sdf.parse(expires);
    }

    /**
     * Get the generation
     * @return the generation
     */
    public String getGeneration() {
        return generation;
    }

    /**
     * Get the issue date
     * @return the issue date
     */
    public String getIssued() {
        return issued;
    }

    /**
     * Get the nonlinux slots
     * @return the nonlinux slots
     */
    public String getNonlinuxSlots() {
        return nonlinuxSlots;
    }

    /**
     * Get the monitoring slots
     * @return the monitoring slots
     */
    public String getMonitoringSlots() {
        return monitoringSlots;
    }

    /**
     * Get the owner
     * @return the owner
     */
    public String getOwner() {
        return owner;
    }

    /**
     * Get the product
     * @return the product
     */
    public String getProduct() {
        return product;
    }

    /**
     * Get the number of provisioning slots
     * @return the number of provisioning slots
     */
    public String getProvisioningSlots() {
        return provisioningSlots;
    }
    
    /**
     * Get the satellite version
     * @return the satellite version
     */
    public String getSatelliteVersion() {
        return satelliteVersion;
    }

    /**
     * Get the ASCII armoured signature
     * @return the ASCII armoured signature
     */
    public String getSignature() {
        return signature;
    }

    /**
     * Get the number of slots
     * @return the number of slots
     */
    public String getSlots() {
        return slots;
    }

    /**
     * Get the number of virtualization slots
     * @return the number of virtualization slots
     */
    public String getVirtualizationSlots() {
        return virtualizationSlots;
    }
    
    /**
     * Get the number of virtualization platform slots
     * @return the number of virtualizationPlatform slots
     */
    public String getVirtualizationPlatformSlots() {
        return virtualizationPlatformSlots;
    }

    private void appendField(StringBuffer result, String fieldName, String value) {
        if (value != null) {
            result.append(fieldName).append("-").append(value).append('\n');
        }
    }
}
