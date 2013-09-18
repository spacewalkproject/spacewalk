<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
        <h2><bean:message key="sdc.details.edit.header"/></h2>

    <html:form method="post" action="/systems/details/Edit.do?sid=${system.id}" styleClass="form-horizontal">
            <rhn:csrf />
            <html:hidden property="submitted" value="true"/>

            <div class="form-group">
                <label for="system_name" class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.profilename"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="system_name" styleClass="form-control" styleId="system_name"/>
                </div>
            </div>

            <div class="form-group">
                <label for="baseentitlement" class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.baseentitlement"/>
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test="${!base_entitlement_permanent}">
                            <rhn:require acl="user_role(org_admin)">
                                <html:select property="base_entitlement" styleId="baseentitlement" styleClass="form-control">
                                    <html:options collection="base_entitlement_options" property="value" labelProperty="label"/>
                                </html:select>
                            </rhn:require>
                            <rhn:require acl="not user_role(org_admin)">
                                <c:out value="${base_entitlement}"/>
                            </rhn:require>
                        </c:when>
                        <c:otherwise>
                            <c:out value="${base_entitlement}"/>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.addonentitlements"/>
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test="${system.baseEntitlement == null}">
                            <bean:message key="sdc.details.edit.nobase"/>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${addon_entitlements}" var="entitlement">
                                <div class="checkbox">
                                    <label for="${entitlement.entitlement.label}">
                                        <html:checkbox property="${entitlement.entitlement.label}"
                                                       styleId="${entitlement.entitlement.label}"/>
                                        <strong>
                                            <c:out value="${entitlement.entitlement.humanReadableLabel}"/>
                                        </strong>
                                        (${entitlement.availbleEntitlements} <bean:message key="sdc.channels.edit.available"/>)
                                    </label>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.notifications"/>
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test="${notifications_disabled}">
                            <bean:message key="sdc.details.overview.notifications.disabled"/>
                        </c:when>
                        <c:when test="${system.baseEntitlement == null}">
                            <bean:message key="sdc.details.edit.notifications.unentitled"/>
                        </c:when>
                        <c:otherwise>
                            <label for="receive_notifications">
                                <html:checkbox property="receive_notifications" styleId="receive_notifications"/>
                                <bean:message key="sdc.details.edit.updates"/>
                            </label>
                            <label for="summary">
                                <html:checkbox property="include_in_daily_summary" styleId="summary"/>
                                <bean:message key="sdc.details.edit.summary"/>
                            </label>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="form-group">
                <label class="col-lg-3 control-label" for="autoerrataupdate">
                    <bean:message key="sdc.details.edit.autoerrataupdate"/>
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test="${system.baseEntitlement == null}">
                            <bean:message key="sdc.details.edit.autoupdate.unentitled"/>
                        </c:when>
                        <c:otherwise>
                            <label for="autoerrataupdate">
                                <html:checkbox property="auto_update" styleId="autoerrataupdate"/>
                                <bean:message key="sdc.details.edit.autoupdate"/>
                            </label>
                            </c:otherwise>
                        </c:choose>
                </div>
            </div>

            <div class="form-group">
                <label for="description" class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.description" />
                </label>
                <div class="col-lg-6">
                    <html:textarea property="description" styleClass="form-control" rows="6" styleId="description"/>
                </div>
            </div>

            <div class="form-group">
                <label for="address" class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.address"/>
                </label>
                <div class="col-lg-6">
                    <html:text property="address1" maxlength="128" styleClass="form-control" styleId="address"/><br/>
                    <html:text property="address2" maxlength="128" styleClass="form-control" />
                </div>
            </div>

            <div class="form-group">
                <label for="city" class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.city"/>
                </label>
                <div class="col-lg-2">
                    <html:text property="city" maxlength="128" styleClass="form-control" styleId="city"/>
                </div>
            </div>

            <div class="form-group">
                <label for="state" class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.state"/>
                </label>
                <div class="col-lg-2">
                    <html:text property="state" maxlength="60" styleClass="form-control" styleId="state"/>
                </div>
            </div>

            <div class="form-group">
                <label for="country" class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.country"/>
                </label>
                <div class="col-lg-2">
                    <html:select property="country" styleId="country" styleClass="form-control">
                        <html:options collection="countries" property="value" labelProperty="label" />
                    </html:select>
                </div>
           </div>

            <div class="form-group">
                <label for="building" class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.building"/>
                </label>
                <div class="col-lg-1">
                    <html:text property="building" maxlength="128" styleClass="form-control" styleId="building"/>
                </div>
            </div>

            <div class="form-group">
                <label for="room" class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.room"/>
                </label>
                <div class="col-lg-1">
                    <html:text property="room" maxlength="32" styleClass="form-control" styleId="room"/>
                </div>
            </div>

            <div class="form-group">
                <label for="rack" class="col-lg-3 control-label">
                    <bean:message key="sdc.details.edit.rack"/>
                </label>
                <div class="col-lg-1">
                    <html:text property="rack" maxlength="64" styleClass="form-control" styleId="rack"/>
                </div>
            </div>

            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <button type="submit" class="btn btn-success">
                        <bean:message key="sdc.details.edit.update"/>
                    </button>
                </div>
            </div>
        </html:form>
    </body>
</html:html>
