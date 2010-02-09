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
package com.redhat.rhn.frontend.action.common;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.frontend.context.Context;

import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;

import javax.servlet.http.HttpServletRequest;

/**
 * Action setup to handle 2 date picker forms for a start and end date. 
 * 
 * @version $Rev: 56295 $
 */
public class DateRangePicker {
    
    private DynaActionForm form;
    private HttpServletRequest req;
    private Date defaultStartOffset;
    private Date defaultEndOffset;
    private int yearRangeDirection;
    private String startKey;
    private String endKey;
    /**
     * Construct a new DateRangePicker
     * 
     * @param formIn to process
     * @param reqIn to process
     * @param defaultStartDateIn number of days to offset the start from today
     * @param defaultEndOffsetIn number of days to offset the end from today
     * @param yearRangeDirectionIn If you want the year range selector to show years
     * in the future or in the past. See DatePicker.YEAR_RANGE_POSATIVE, and 
     * DatePicker.YEAR_RANGE_NEGATIVE
     * @param startKeyIn the l10n key for the name of the start date
     * @param endKeyIn the l10n key for the name of the end date
     */
    public DateRangePicker(DynaActionForm formIn, 
            HttpServletRequest reqIn, 
            Date defaultStartDateIn, 
            Date defaultEndOffsetIn,
            int yearRangeDirectionIn, String startKeyIn, String endKeyIn) {
        this.form = formIn;
        this.req = reqIn;
        this.defaultEndOffset = defaultEndOffsetIn;
        this.defaultStartOffset = defaultStartDateIn;
        this.yearRangeDirection = yearRangeDirectionIn;
        this.startKey = startKeyIn;
        this.endKey = endKeyIn;
    }
    
    /**
     * Process the date pickers.  This should be called at the top
     * of your execute() method.  
     * 
     * @param isSubmitted if the form was submitted or not
     * @return DatePickerResults instance that contains the results of processing the form
     * against the DatePickers.
     */
    public DatePickerResults processDatePickers(boolean isSubmitted) {
        // Setup the date pickers
        Context ctx = Context.getCurrentContext();
        DatePicker start = new DatePicker("start", ctx.getTimezone(), ctx.getLocale(), 
                yearRangeDirection);
        DatePicker end = new DatePicker("end", ctx.getTimezone(), ctx.getLocale(), 
                yearRangeDirection);
        ActionMessages errors = new ActionMessages();
        DatePickerResults retval = new DatePickerResults();
        retval.setStart(start);
        retval.setEnd(end);
        retval.setErrors(errors);
        if (isSubmitted) {
            start.readMap(req.getParameterMap());
            end.readMap(req.getParameterMap());
            validateDates(errors, start, end);
        }
        else {
            // Initialize the dates in the picker and default 
            // to one day before today.
            start.getCalendar().setTime(defaultStartOffset);
            start.writeToMap(form.getMap());
            end.getCalendar().setTime(defaultEndOffset);
            end.writeToMap(form.getMap());
        }

        req.setAttribute("start", start);
        req.setAttribute("end", end);
        assert (start.getDate() != null);
        assert (end.getDate() != null);
        return retval;
    }

    private void validateDates(ActionMessages errors, DatePicker start, 
            DatePicker end) {
        final LocalizationService ls = LocalizationService.getInstance();
        Date startDate = start.getDate();
        Date endDate = end.getDate(); 
        if (startDate == null) {
            String startMsg = ls.getMessage(startKey);
            errors.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("daterangepicker.error.invalid", startMsg));
            // Reset the date to the default.  We message the user 
            // about this.
            start.getCalendar().setTime(defaultStartOffset);
        }
        if (endDate == null) {
            String endMsg = ls.getMessage(endKey);
            errors.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("daterangepicker.error.invalid", endMsg));
            // Reset the date to the default.  We message the user 
            // about this.
            end.getCalendar().setTime(defaultEndOffset);
        }
        if (startDate != null && endDate != null && !endDate.after(startDate)) {
            String startMsg = ls.getMessage(startKey);
            String endMsg = ls.getMessage(endKey);
            errors.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("daterangepicker.error.start.before.end",
                            startMsg, endMsg));
        }
    }

    /**
     * DatePickerResults class to encapsulate the results of processing the DatePickers
     * in the form.
     * @version $Rev$
     */
    public class DatePickerResults {
        private DatePicker start;
        private DatePicker end;
        private ActionMessages errors;
        
        /**
         * @return Returns the errors.
         */
        public ActionMessages getErrors() {
            return errors;
        }
        
        /**
         * @param messagesIn The errors to set.
         */
        public void setErrors(ActionMessages messagesIn) {
            this.errors = messagesIn;
        }

        
        /**
         * @return Returns the end.
         */
        public DatePicker getEnd() {
            return end;
        }

        
        /**
         * @param endIn The end to set.
         */
        public void setEnd(DatePicker endIn) {
            this.end = endIn;
        }

        
        /**
         * @return Returns the start.
         */
        public DatePicker getStart() {
            return start;
        }

        
        /**
         * @param startIn The start to set.
         */
        public void setStart(DatePicker startIn) {
            this.start = startIn;
        }
                
    }
}
