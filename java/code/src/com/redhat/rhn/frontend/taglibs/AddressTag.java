/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.taglibs;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.Address;
import com.redhat.rhn.domain.user.User;

import java.io.IOException;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;
import org.apache.commons.lang.StringUtils;

/**
 * <strong>AddressTag</strong>
 * Displays a User's address information.
 * <pre>
 *     &lt;rhn:address type=MAILING&gt;
 * </pre>
 * This outputs a table row tag containing a Header column, address info
 * and a link to edit the address.<br />
 * <pre>
 *      Mailing:   444 Castro
 *                 Mountain View, CA 94043
 *
 *                 Phone: 650-555-1212
 *                 Fax: 650-555-1212
 *                 Edit This Address (this is a link)
 * </pre>
 *
 * @version $Rev: 694 $
 */
public class AddressTag extends TagSupport {

    /** defines the action the address tag should forward to */
    public static final String ACTION_MY = "my";

    /** public string representing the forward action type */
    public static final String ACTION_USER = "user";

    /** Type of address */
    private String type;
    private String action;
    private User user;
    private Address address;

    /**
     * Constructor for Address tag.
     */
    public AddressTag() {
        super();
        type = null;
        action = null;
    }

    /**
     * Set the type of this address: MAILING, BILLING, SHIPPING
     * @param typeIn the type of this address: MAILING, BILLING, SHIPPING
     */
    public void setType(String typeIn) {
        if (!typeIn.equals(Address.TYPE_MARKETING)) {
            throw new IllegalArgumentException("The type attribute must be  of the " +
                "static TYPE fields in com.redhat.rhn.domain.user.Address (M)");
        }
        type = typeIn;
    }

    /**
     * Get the type of this address: MAILING, BILLING, SHIPPING
     *
     * @return The type of this address
     */
    public String getType() {
        return type;
    }


    /**
    * Set the User associated with this Address
    *
    * @param userIn the User
    */
    public void setUser(User userIn) {
        this.user = userIn;
    }

    /**
    * Get the User associated with this Address
    * @return User that is set
    */
    public User getUser() {
        return this.user;
    }

    /**
    * Set the Address to be rendered
    *
    * @param addrIn the Address to render
    */
    public void setAddress(Address addrIn) {
        this.address = addrIn;
    }

    /**
    * Get the Address to be rendered
    *
    * @return Address that is set
    */
    public Address getAddress() {
        return this.address;
    }

    /**
     * Sets the action used to determine where to forward the call too.
     * @param actionIn the action used to determine where to forward the
     * call too.
     */
    public void setAction(String actionIn) {
        if (!AddressTag.ACTION_MY.equals(actionIn) &&
            !AddressTag.ACTION_USER.equals(actionIn)) {
                throw new IllegalArgumentException("Invalid action type [" +
                                                 actionIn + "]");
        }
        action = actionIn;
    }

    /**
     * Returns the action used to determine where to forward the call too.
     * @return the action used to determine where to forward the call too.
     */
    public String getAction() {
        return action;
    }

    /** {@inheritDoc}
     * @throws JspException
     */
    public int doStartTag() throws JspException {

        JspWriter out = null;
        try {
            out = pageContext.getOut();
            LocalizationService ls = LocalizationService.getInstance();

            StringBuilder result = new StringBuilder();
            StringBuilder key = new StringBuilder("address type ");
            key.append(type);
            result.append("<strong>");
            result.append(ls.getMessage(key.toString()));
            result.append("</strong>");
            if (user == null) {
                throw new IllegalArgumentException("User is null");
            }

            // If this Address is new
            if (address != null &&
                StringUtils.isNotBlank(address.getCity()) &&
                StringUtils.isNotBlank(address.getZip())) {
                result.append("<address>");
                // Address 1 and 2
                result.append(address.getAddress1());
                result.append("<br />");
                if (StringUtils.isNotBlank(address.getAddress2())) {
                    result.append(address.getAddress2());
                    result.append("<br />");
                }

                // City
                result.append(address.getCity());
                if (StringUtils.isNotBlank(address.getState())) {
                    result.append(", ");
                    result.append(address.getState());
                }

                result.append(" ");
                result.append(address.getZip());
                result.append("<br />");

                // Phones
                result.append(ls.getMessage("phone"));
                result.append(": ");
                result.append(address.getPhone());
                result.append("<br />");
                if (StringUtils.isNotBlank(address.getFax())) {
                    result.append(ls.getMessage("fax"));
                    result.append(": ");
                    result.append(address.getFax());
                    result.append("<br />");
                }

                result.append("</address>");

                result.append("<a ")
                      .append("class=\"btn btn-primary\"")
                      .append(" href=\"")
                      .append(getActionUrl())
                      .append("/EditAddress.do?type=")
                      .append(type)
                      .append("&amp;uid=")
                      .append(String.valueOf(user.getId()))
                      .append("\">")
                      .append(ls.getMessage("Edit this address"))
                      .append("</a>");
            }
            else {
                result.append("<div class=\"alert alert-info\">");
                result.append(ls.getMessage("address not filled in"));
                result.append("</div>");
                result.append("<a ")
                      .append("class=\"btn btn-default\"")
                      .append(" href=\"")
                      .append(getActionUrl())
                      .append("/EditAddress.do?type=")
                      .append(type)
                      .append("&amp;uid=")
                      .append(String.valueOf(user.getId()))
                      .append("\">")
                      .append(ls.getMessage("Fill in this address"))
                      .append("</a>");
            }

            out.print(result);
        }
        catch (IOException ioe) {
            throw new JspException("IO error writing to JSP file:", ioe);
        }

        return (SKIP_BODY);
    }

    // man this is a hack.
    private String getActionUrl() {
        if (AddressTag.ACTION_MY.equals(getAction())) {
            return "/rhn/account";
        }
        else if (AddressTag.ACTION_USER.equals(getAction())) {
            return "/rhn/users";
        }
        else {
            return "";
        }
    }

    /**
     * {@inheritDoc}
     */
    public void release() {
        type = null;
        action = null;
        user = null;
        address = null;
        super.release();
    }
}
