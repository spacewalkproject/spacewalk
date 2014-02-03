/**
 * Copyright (c) 2013 Red Hat, Inc.
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

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

import org.apache.commons.lang.StringEscapeUtils;

/**
 * Tag to easy display the icons
 * <pre>
 * &lt;rhn:icon type="$type" title="$title"/&gt;
 * </pre>
 * @version $Rev$
 */
public class IconTag extends TagSupport {

    private String type;
    private String title;
    private static Map<String, String> icons;

    static {
        icons = new HashMap<String, String>();
        icons.put("action-failed", "fa fa-times-circle-o fa-1-5x text-danger");
        icons.put("action-ok", "fa fa-check-circle-o fa-1-5x text-success");
        icons.put("action-pending", "fa fa-clock-o fa-1-5x");
        icons.put("action-running", "fa fa-exchange fa-1-5x text-info");
        icons.put("errata-bugfix", "fa fa-bug fa-1-5x");
        icons.put("errata-enhance", "fa fa-1-5x spacewalk-icon-enhancement");
        icons.put("errata-security", "fa fa-shield fa-1-5x");
        icons.put("event-type-errata", "fa spacewalk-icon-patches");
        icons.put("event-type-package", "fa spacewalk-icon-packages");
        icons.put("event-type-preferences", "fa fa-cog");
        icons.put("event-type-system", "fa fa-desktop");
        icons.put("file-directory", "fa fa-folder-open-o");
        icons.put("file-file", "fa fa-file-text-o");
        icons.put("file-symlink", "fa spacewalk-icon-listicon-cfg-symlink");
        icons.put("header-action", "fa fa-clock-o");
        icons.put("header-activation-key", "fa fa-key");
        icons.put("header-channel", "fa spacewalk-icon-software-channels");
        icons.put("header-channel-configuration",
                  "fa spacewalk-icon-software-channel-management");
        icons.put("header-channel-mapping", "fa fa-retweet");
        icons.put("header-chat", "fa fa-comment text-primary");
        icons.put("header-config-system", "fa spacewalk-icon-config-system");
        icons.put("header-configuration", "fa spacewalk-icon-manage-configuration-files");
        icons.put("header-crash", "fa spacewalk-icon-bug-ex");
        icons.put("header-errata", "fa spacewalk-icon-patches");
        icons.put("header-errata-add", "fa spacewalk-icon-patch-install");
        icons.put("header-errata-del", "fa spacewalk-icon-patch-remove");
        icons.put("header-errata-set", "fa spacewalk-icon-patch-set");
        icons.put("header-errata-set-add", "fa pacewalk-icon-patchset-install");
        icons.put("header-event-history", "fa fa-suitcase");
        icons.put("header-file", "fa fa-file-text-o");
        icons.put("header-folder", "fa fa-folder-open-o");
        icons.put("header-globe", "fa fa-globe");
        icons.put("header-help", "fa fa-question-circle spacewalk-help-link");
        icons.put("header-info", "fa fa-info-circle");
        icons.put("header-kickstart", "fa fa-rocket");
        icons.put("header-list", "fa fa-list");
        icons.put("header-monitoring", "fa fa-1-5x spacewalk-icon-monitoring-status");
        icons.put("header-multiorg-big", "fa fa-sitemap fa-3x");
        icons.put("header-note", "fa spacewalk-icon-note-pin");
        icons.put("header-organisation", "fa fa-group");
        icons.put("header-package", "fa spacewalk-icon-packages");
        icons.put("header-package-add", "fa spacewalk-icon-package-add");
        icons.put("header-package-del", "fa spacewalk-icon-package-delete");
        icons.put("header-package-extra", "fa spacewalk-icon-package-extra");
        icons.put("header-package-upgrade", "fa spacewalk-icon-package-upgrade");
        icons.put("header-preferences", "fa fa-cogs");
        icons.put("header-proxy", "fa spacewalk-icon-proxy");
        icons.put("header-refresh", "fa fa-refresh");
        icons.put("header-reloading", "fa fa-refresh fa-spin");
        icons.put("header-sandbox", "fa spacewalk-icon-sandbox");
        icons.put("header-schedule", "fa spacewalk-icon-schedule");
        icons.put("header-search", "fa fa-search");
        icons.put("header-signout", "fa fa-sign-out");
        icons.put("header-sitemap", "fa fa-sitemap");
        icons.put("header-snapshot", "fa fa-camera");
        icons.put("header-snapshot-rollback", "fa spacewalk-icon-snapshot-rollback");
        icons.put("header-subscriptions-big", "fa fa-list-alt fa-3x");
        icons.put("header-symlink", "fa spacewalk-icon-listicon-cfg-symlink");
        icons.put("header-system", "fa fa-desktop");
        icons.put("header-system-groups", "fa spacewalk-icon-system-groups");
        icons.put("header-system-physical", "fa fa-desktop");
        icons.put("header-system-virt-guest", "fa spacewalk-icon-virtual-guest");
        icons.put("header-system-virt-host", "fa spacewalk-icon-virtual-host");
        icons.put("header-taskomatic", "fa fa-tachometer");
        icons.put("header-user", "fa fa-user");
        icons.put("header-users-big", "fa fa-group fa-3x");
        icons.put("item-add", "fa fa-plus");
        icons.put("item-clone", "fa fa-files-o");
        icons.put("item-del", "fa fa-trash-o");
        icons.put("item-disabled", "fa fa-circle-o text-muted");
        icons.put("item-download", "fa fa-download");
        icons.put("item-download-csv", "fa spacewalk-icon-download-csv");
        icons.put("item-edit", "fa fa-edit");
        icons.put("item-enabled", "fa fa-check text-success");
        icons.put("item-search", "fa fa-eye");
        icons.put("item-ssm-add", "fa fa-plus-circle");
        icons.put("item-ssm-del", "fa fa-minus-circle");
        icons.put("item-upload", "fa fa-upload");
        icons.put("monitoring-crit",
                  "fa fa-1-5x spacewalk-icon-monitoring-down text-danger");
        icons.put("monitoring-ok", "fa fa-1-5x spacewalk-icon-monitoring-ok text-success");
        icons.put("monitoring-pending", "fa fa-1-5x spacewalk-icon-monitoring-pending");
        icons.put("monitoring-status", "fa spacewalk-icon-monitoring-status");
        icons.put("monitoring-unknown", "fa fa-1-5x spacewalk-icon-monitoring-unknown");
        icons.put("monitoring-warn",
                  "fa fa-1-5x spacewalk-icon-monitoring-warning text-warning");
        icons.put("nav-bullet", "fa fa-caret-right");
        icons.put("nav-page-first", "fa fa-angle-double-left");
        icons.put("nav-page-last", "fa fa-angle-double-right");
        icons.put("nav-page-next", "fa fa-angle-right");
        icons.put("nav-page-prev", "fa fa-angle-left");
        icons.put("nav-right", "fa fa-arrow-right");
        icons.put("nav-up", "fa fa-caret-up");
        icons.put("sort-down", "fa fa-arrow-circle-down");
        icons.put("sort-up", "fa fa-arrow-circle-up");
        icons.put("system-crit", "fa fa-exclamation-circle fa-1-5x text-danger");
        icons.put("system-kickstarting", "fa fa-rocket fa-1-5x");
        icons.put("system-locked", "fa fa-lock fa-1-5x");
        icons.put("system-ok", "fa fa-check-circle fa-1-5x text-success");
        icons.put("system-physical", "fa fa-desktop fa-1-5x");
        icons.put("system-reboot", "fa fa-refresh");
        icons.put("system-unentitled", "fa fa-times-circle fa-1-5x");
        icons.put("system-unknown", "fa fa-question-circle fa-1-5x");
        icons.put("system-virt-guest", "fa fa-1-5x spacewalk-icon-virtual-guest");
        icons.put("system-virt-host", "fa fa-1-5x spacewalk-icon-virtual-host");
        icons.put("system-warn", "fa fa-exclamation-triangle fa-1-5x text-warning");
    }

    /**
     * Constructor for Icon tag.
     * @param typeIn the type of the icon
     * @param titleIn the title of the icon
     */
    public IconTag(String typeIn, String titleIn) {
        super();
        type = typeIn;
        title = titleIn;
    }

    /**
     * Constructor for Icon tag.
     * @param typeIn the type of the icon
     */
    public IconTag(String typeIn) {
        this(typeIn, (String) null);
    }

    /**
     * Constructor for Icon tag.
     */
    public IconTag() {
        this((String) null, (String) null);
    }

    /**
     * Set the type of the icon
     * @param typeIn the type of the icon
     */
    public void setType(String typeIn) {
        type = typeIn;
    }

    /**
     * Get the type of the icon
     * @return The type of the icon
     */
    public String getType() {
        return type;
    }

    /**
     * Set the title of the icon
     * @param titleIn the title of the icon
     */
    public void setTitle(String titleIn) {
        title = titleIn;
    }

    /**
     * Get the title of the icon
     * @return The title of the icon
     */
    public String getTitle() {
        return LocalizationService.getInstance().getMessage(title);
    }

    /**
     * Return just the HTML
     * @return String that contains generated HTML
     */
    public String render() {
        String result = renderStartTag();
        release();
        return result;
    }

    /**
     * Return just the HTML
     * @return String that contains generated HTML
     */
    public String renderStartTag() {
        if (!icons.containsKey(type)) {
            throw new IllegalArgumentException("Unknown icon type: \"" + type + "\".");
        }

        StringBuilder result = new StringBuilder();
        result.append("<i class=\"" + icons.get(type) + "\"");
        if (title != null) {
            result.append(" title=\"" +
                StringEscapeUtils.escapeHtml(this.getTitle()) + "\"");
        }
        result.append("></i>");

        return result.toString();
    }

    /** {@inheritDoc}
     * @throws JspException
     */
    public int doStartTag() throws JspException {
        if (!icons.containsKey(type)) {
            throw new IllegalArgumentException("Unknown icon type: \"" + type + "\".");
        }

        JspWriter out = null;
        try {
            out = pageContext.getOut();
            String result = renderStartTag();
            out.print(result);
        }
        catch (IOException ioe) {
            throw new JspException("IO error writing to JSP file:", ioe);
        }
        return SKIP_BODY;
    }

    /**
     * {@inheritDoc}
     */
    public void release() {
        type = null;
        title = null;
        super.release();
    }

}
