/**
 * Copyright (c) 2013 SUSE
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
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import java.util.Date;

import java.io.IOException;
import java.io.Writer;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Locale;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

/**
 * <strong>FormatDateTag</strong>
 * Displays a value in a human format (eg. 3 minutes ago)
 * <pre>
 *     &lt;rhn:human-value value="${bean.value}"&gt;
 * </pre> Outputs a human readable text for the value relative to now.<br />
 *
 */
public class FormatDateTag extends TagSupport {

    private static final String SHORT = "short";
    private static final String MEDIUM = "medium";
    private static final String LONG = "long";
    private static final String FULL = "full";

    private static final String DATE = "date";
    private static final String TIME = "time";
    private static final String BOTH = "both";

    private static final String FROM = "from";
    private static final String CALENDAR = "calendar";
    private static final String NONE = "none";

    // ISO format usable by moment.js parsing
    private static final String ISO_FORMAT = "yyyy-MM-dd'T'HH:mm:ssXXX";
    private final DateFormat isoFormatter = new SimpleDateFormat(ISO_FORMAT);

    protected Date value;
    protected Date reference;
    protected Locale locale;

    // cache
    private Locale bestLocale;

    // fmt:formatDate equivalents
    protected String pattern;
    protected String dateStyle;
    protected String timeStyle;
    protected String type;

    protected String humanStyle;

    /**
     * @return Current set reference
     */
    public Date getReference() {
        return reference;
    }

    /**
     * The reference date used instead of now
     * when calculating intervals or durations
     *
     * @param ref date value
     */
    public void setReference(Date ref) {
        this.reference = ref;
    }

    /**
     * @return The current set human style
     */
    public String getHumanStyle() {
        return humanStyle;
    }

    /**
     * Set human style
     * @param style value
     *
     * Valid values:
     * "none" (default)
     * "from" date from now or reference
     * "calendar" calendar date
     */
    public void setHumanStyle(String style) {
        this.humanStyle = style;
    }

    /**
     * Constructor
     */
    public FormatDateTag() {
        reset();
    }

    /**
     * @return The current pattern for the formatter
     * @see fmt:FormatDate tag
     */
    public String getPattern() {
        return pattern;
    }

    /**
     * @param pat The desired pattern for the formatter
     * @see fmt:FormatDate tag
     */
    public void setPattern(String pat) {
        this.pattern = pat;
    }

    /**
     * @return The date style for the formatter
     * @see fmt:FormatDate tag
     */
    public String getDateStyle() {
        return dateStyle;
    }

    /**
     * @param style Desired date style for the formatter
     *
     * Valid values: default, shot, medium, long, full
     *
     * @see fmt:FormatDate tag
     */
    public void setDateStyle(String style) {
        this.dateStyle = style;
    }

    /**
     * @return The time style for the formatter
     * @see fmt:FormatDate
     */
    public String getTimeStyle() {
        return timeStyle;
    }

    /**
     * @param style Desired time style for the formatter
     * @see fmt:FormatDate
     */
    public void setTimeStyle(String style) {
        this.timeStyle = style;
    }

    /**
     * @return Type of the formatter (display date, time or both)
     *
     * @see fmt:FormatDate
     */
    public String getType() {
        return type;
    }

    /**
     * @param typ Desired type for the formatter
     *
     * Valid values: date, time or both
     *
     * @see fmt:FormatDate
     */
    public void setType(String typ) {
        this.type = typ;
    }

    /**
     * @return The locale for the formatting, defaults to the application
     * settings
     */
    public Locale getLocale() {
        return locale;
    }

    /**
     * @param loc Locale to do the formatting, defaults to the application
     * settings
     */
    public void setLocale(Locale loc) {
        this.locale = loc;
    }

    /**
     * @return value to be formatted
     */
    public Date getValue() {
        return value;
    }

    /**
     * @param val the value to be formatted
     */
    public void setValue(Date val) {
        this.value = val;
    }

    /**
     * renders code that includes the moment.js library, only
     * if it has not been included before by the same tag
     * @param out Where to render to
     * @throws IOException
     */
    protected void renderMomentInclude(Writer out) throws IOException {
        if (pageContext.getAttribute("__spacewalk_momentjs_included") == null) {
            out.append("<script type=\"text/javascript\" src=\"" +
                "/javascript/momentjs/moment-with-langs.min.js\"></script>");

            out.append("<script type=\"text/javascript\">");
            out.append("  moment.lang(\"" + getBestLocale() + "\");");
            out.append("</script>");
            pageContext.setAttribute("__spacewalk_momentjs_included", true);
        }
    }

    /**
     * @return the date formatted into the applications preferred
     *          string format
     */
    protected String getFormattedDate() {
        String fmtDate;
        // use spacewalk defaults if the formatter is not customized
        if (!isFormatCustomized()) {
            fmtDate = LocalizationService.getInstance().formatDate(getValue());
        }
        else {
            DateFormat fmt = getFormatter();
            if (getPattern() != null) {
                SimpleDateFormat simplefmt = (SimpleDateFormat) fmt;
                simplefmt.applyPattern(pattern);
            }
            fmtDate = fmt.format(value);
        }
        return fmtDate;
    }

    /**
     * {@inheritDoc}
     *
     * @throws JspException
     */
    @Override
    public int doStartTag() throws JspException {
        try {
            JspWriter out = pageContext.getOut();

            renderMomentInclude(out);

            out.append("  <time");
            out.append(getCssClass());
            out.append(" data-reference-date=\"" +
                    isoFormatter.format(getReference()) + "\"");
            out.append(" datetime=\"" +
                    isoFormatter.format(getValue()) + "\">");
            out.append(getFormattedDate());
            out.append("  </time>");
        }
        catch (IOException ioe) {
            throw new JspException("IO error writing to JSP file:", ioe);
        }
        return (SKIP_BODY);
    }

    protected String getCssClass() {
        if (FROM.equalsIgnoreCase(getHumanStyle())) {
            return " class=\"human-from\"";
        }
        else if (CALENDAR.equalsIgnoreCase(getHumanStyle())) {
            return " class=\"human-calendar\"";
        }
        else {
          return "";
        }
    }

    private int getStyle(String style) {
        int ret = DateFormat.DEFAULT;
        if (SHORT.equalsIgnoreCase(style)) {
            ret = DateFormat.SHORT;
        }
        else if (MEDIUM.equalsIgnoreCase(style)) {
            ret = DateFormat.MEDIUM;
        }
        else if (LONG.equalsIgnoreCase(style)) {
            ret = DateFormat.LONG;
        }
        else if (FULL.equalsIgnoreCase(style)) {
            ret = DateFormat.FULL;
        }
        return ret;
    }

    protected boolean isFormatCustomized() {
        return (getPattern() != null ||
                getType() != null ||
                getDateStyle() != null ||
                getTimeStyle() != null);
    }

    /**
     * @return The final locale used to format the date
     *
     * If the tag did not supply one, use the application user
     * configured locale.
     */
    protected Locale getBestLocale() {
        if (bestLocale == null) {
            if (getLocale() == null) {
                ServletRequest req = pageContext.getRequest();
                RequestContext ctx = new RequestContext((HttpServletRequest) req);
                User user = ctx.getCurrentUser();
                String userLocale = user.getPreferredLocale();
                if (userLocale != null) {
                    bestLocale = new Locale(userLocale);
                }
                else {
                    bestLocale = Locale.getDefault();
                }
            }
            else {
                bestLocale = getLocale();
            }
        }
        return bestLocale;
    }

    protected DateFormat getFormatter() {
        if (DATE.equalsIgnoreCase(getType())) {
            return DateFormat.getDateInstance(getStyle(getDateStyle()), getBestLocale());
        }
        else if (TIME.equalsIgnoreCase(getType())) {
            return DateFormat.getTimeInstance(getStyle(getTimeStyle()), getBestLocale());
        }
        else if (BOTH.equalsIgnoreCase(getType())) {
            return DateFormat.getDateTimeInstance(getStyle(getDateStyle()),
                    getStyle(getTimeStyle()), getBestLocale());
        }
        else {
            return DateFormat.getInstance();
        }
    }

    // to share with the constructor
    private void reset() {
        value = new Date();
        reference = new Date();
        humanStyle = null;
        locale = null;
        // cached
        bestLocale = null;

        // compatibility with fmt:formatDate
        dateStyle = null;
        timeStyle = null;
        type = null;
        pattern = null;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void release() {
        reset();
        super.release();
    }
}
