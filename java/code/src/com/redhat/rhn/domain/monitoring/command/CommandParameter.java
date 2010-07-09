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
package com.redhat.rhn.domain.monitoring.command;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * CommandParameter - Class representation of the table rhn_command_parameter.
 * @version $Rev: 1 $
 */
public class CommandParameter implements Serializable {

    private Command command;
    private String paramName;
    private String paramType;
    private String dataTypeName;
    private String description;
    private boolean mandatory;
    private String defaultValue;
    private Integer minValue;
    private Integer maxValue;
    private Long fieldOrder;
    private String fieldWidgetName;
    private Long fieldVisibleLength;
    private Long fieldMaximumLength;
    private boolean fieldVisible;
    private boolean defaultValueVisible;
    private String lastUpdateUser;
    private Date lastUpdateDate;
    private ParameterValidator validator;
    // private MonitoringWidget fieldWidget;

    /**
     * Getter for paramName
     * @return String to get
    */
    public String getParamName() {
        return this.paramName;
    }

    /**
     * Getter for paramType
     * @return String to get
    */
    public String getParamType() {
        return this.paramType;
    }

    /**
     * Setter for paramType
     * @param paramTypeIn to set
    */
    private void setParamType(String paramTypeIn) {
        this.paramType = paramTypeIn;
    }

    /**
     * Getter for dataTypeName
     * @return String to get
    */
    public String getDataTypeName() {
        return this.dataTypeName;
    }

    /**
     * Setter for dataTypeName
     * @param dataTypeNameIn to set
    */
    private void setDataTypeName(String dataTypeNameIn) {
        this.dataTypeName = dataTypeNameIn;
    }

    /**
     * Getter for description
     * @return String to get
    */
    public String getDescription() {
        return this.description;
    }

    /**
     * Setter for description
     * @param descriptionIn to set
    */
    private void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /**
     * Getter for mandatory
     * @return Boolean to get
    */
    public boolean isMandatory() {
        return this.mandatory;
    }

    /**
     * Setter for mandatory
     * @param mandatoryIn to set
    */
    private void setMandatory(boolean mandatoryIn) {
        this.mandatory = mandatoryIn;
    }

    /**
     * Getter for defaultValue
     * @return String to get
    */
    public String getDefaultValue() {
        return this.defaultValue;
    }

    /**
     * Setter for defaultValue
     * @param defaultValueIn to set
    */
    private void setDefaultValue(String defaultValueIn) {
        this.defaultValue = defaultValueIn;
    }

    /**
     * Getter for minValue
     * @return Long to get
    */
    public Integer getMinValue() {
        return this.minValue;
    }

    /**
     * Setter for minValue
     * @param minValueIn to set
    */
    private void setMinValue(Integer minValueIn) {
        this.minValue = minValueIn;
    }

    /**
     * Getter for maxValue
     * @return Long to get
    */
    public Integer getMaxValue() {
        return this.maxValue;
    }

    /**
     * Setter for maxValue
     * @param maxValueIn to set
    */
    private void setMaxValue(Integer maxValueIn) {
        this.maxValue = maxValueIn;
    }

    /**
     * Getter for fieldOrder
     * @return Long to get
    */
    public Long getFieldOrder() {
        return this.fieldOrder;
    }

    /**
     * Setter for fieldOrder
     * @param fieldOrderIn to set
    */
    private void setFieldOrder(Long fieldOrderIn) {
        this.fieldOrder = fieldOrderIn;
    }

    /**
     * Getter for fieldWidgetName
     * @return String to get
    */
    public String getFieldWidgetName() {
        return this.fieldWidgetName;
    }

    /**
     * Setter for fieldWidgetName
     * @param fieldWidgetNameIn to set
    */
    private void setFieldWidgetName(String fieldWidgetNameIn) {
        this.fieldWidgetName = fieldWidgetNameIn;
    }

    /**
     * Getter for fieldVisibleLength
     * @return Long to get
    */
    public Long getFieldVisibleLength() {
        return this.fieldVisibleLength;
    }

    /**
     * Setter for fieldVisibleLength
     * @param fieldVisibleLengthIn to set
    */
    private void setFieldVisibleLength(Long fieldVisibleLengthIn) {
        this.fieldVisibleLength = fieldVisibleLengthIn;
    }

    /**
     * Getter for fieldMaximumLength
     * @return Long to get
    */
    public Long getFieldMaximumLength() {
        return this.fieldMaximumLength;
    }

    /**
     * Setter for fieldMaximumLength
     * @param fieldMaximumLengthIn to set
    */
    private void setFieldMaximumLength(Long fieldMaximumLengthIn) {
        this.fieldMaximumLength = fieldMaximumLengthIn;
    }

    /**
     * Getter for fieldVisible
     * @return Boolean to get
    */
    public boolean isFieldVisible() {
        return this.fieldVisible;
    }

    /**
     * Setter for fieldVisible
     * @param fieldVisibleIn to set
    */
    private void setFieldVisible(boolean fieldVisibleIn) {
        this.fieldVisible = fieldVisibleIn;
    }

    /**
     * Getter for defaultValueVisible
     * @return Boolean to get
    */
    public boolean isDefaultValueVisible() {
        return this.defaultValueVisible;
    }

    /**
     * Setter for defaultValueVisible
     * @param defaultValueVisibleIn to set
    */
    private void setDefaultValueVisible(boolean defaultValueVisibleIn) {
        this.defaultValueVisible = defaultValueVisibleIn;
    }

    /**
     * Getter for lastUpdateUser
     * @return String to get
    */
    public String getLastUpdateUser() {
        return this.lastUpdateUser;
    }

    /**
     * Setter for lastUpdateUser
     * @param lastUpdateUserIn to set
    */
    private void setLastUpdateUser(String lastUpdateUserIn) {
        this.lastUpdateUser = lastUpdateUserIn;
    }

    /**
     * Getter for lastUpdateDate
     * @return Date to get
    */
    public Date getLastUpdateDate() {
        return this.lastUpdateDate;
    }

    /**
     * Setter for lastUpdateDate
     * @param lastUpdateDateIn to set
    */
    private void setLastUpdateDate(Date lastUpdateDateIn) {
        this.lastUpdateDate = lastUpdateDateIn;
    }

    /**
     * @return Returns the command.
     */
    public Command getCommand() {
        return command;
    }

    /**
     * Get the validator for this command parameter
     * @return the validator
     */
    public ParameterValidator getValidator() {
        if (validator == null) {
            validator = createValidator();
        }
        return validator;
    }

    private ParameterValidator createValidator() {
        String dataType = getDataTypeName();
        if ("checkbox".equals(dataType)) {
            return new CheckboxValidator(this);
        }
        else if ("float".equals(dataType)) {
            return new FloatValidator(this);
        }
        else if ("generic".equals(dataType)) {
            return new StringValidator(this);
        }
        else if ("string".equals(dataType)) {
            return new StringValidator(this);
        }
        else if ("integer".equals(dataType)) {
            return new IntegerValidator(this);
        }
        else if ("password".equals(dataType)) {
            return new StringValidator(this);
        }
        else if ("probestate".equals(dataType)) {
            return new ProbeStateValidator(this);
        }
        else {
            throw new IllegalStateException(
                    "Can not create validator for data type " + dataType);
        }
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof CommandParameter)) {
            return false;
        }
        CommandParameter castOther = (CommandParameter) other;
        return new EqualsBuilder().append(command, castOther.command).append(
                paramName, castOther.paramName).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(command).append(paramName)
                .toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("command", command).append(
                "paramName", paramName).append("paramType", paramType).append(
                "dataTypeName", dataTypeName)
                .append("description", description).append("mandatory",
                        mandatory).append("defaultValue", defaultValue).append(
                        "minValue", minValue).append("maxValue", maxValue)
                .append("fieldOrder", fieldOrder).append("fieldWidgetName",
                        fieldWidgetName).append("fieldVisibleLength",
                        fieldVisibleLength).append("fieldMaximumLength",
                        fieldMaximumLength)
                .append("fieldVisible", fieldVisible).append(
                        "defaultValueVisible", defaultValueVisible).append(
                        "lastUpdateUser", lastUpdateUser).append(
                        "lastUpdateDate", lastUpdateDate).toString();
    }

}
