<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
        <h2><bean:message key="ssm.operations.provisioning.remotecommand.header"/></h2>
        <div class="page-summary">
            <p><bean:message key="ssm.operations.provisioning.remotecommand.summary"/></p>
        </div>
        <c:choose>
            <c:when test="${affectedSystemsCount > 0}">
                <html:form styleClass="form-horizontal" action="/systems/ssm/provisioning/RemoteCommand" method="post">
                    <rhn:csrf />
                            <div class="form-group">
                                <label class="col-md-3 control-label"><bean:message key="ssm.operations.provisioning.remotecommand.form.uid.label"/><span class="required-form-field">*</span>:</label>
                                <div class="col-md-6">
                                    <input type="text" name="uid" maxlength="32"
                                           value="<c:choose><c:when test="${fv.uid == null}">root</c:when><c:otherwise>${fv.uid}</c:otherwise></c:choose>"
                                           size=""
                                           class="form-control">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label"><bean:message key="ssm.operations.provisioning.remotecommand.form.gid.label"/><span class="required-form-field">*</span>:</label>
                                <div class="col-md-6">
                                    <input type="text" name="gid" maxlength="32"
                                           value="<c:choose><c:when test="${fv.gid == null}">root</c:when><c:otherwise>${fv.gid}</c:otherwise></c:choose>"
                                           size=""
                                           class="form-control">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label"><bean:message key="ssm.operations.provisioning.remotecommand.form.timeout.label"/>:</label>
                                <div class="col-md-6">
                                    <input type="text" name="timeout" maxlength=""
                                           value="<c:choose><c:when test="${fv.timeout == null}">600</c:when><c:otherwise>${fv.timeout}</c:otherwise></c:choose>"
                                           size="6"
                                           class="form-control">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label"><bean:message key="ssm.operations.provisioning.remotecommand.form.lbl.label"/>:</label>
                                <div class="col-md-6">
                                    <input type="text" id="lbl" name="lbl"
                                           value="<c:if test="${fv.label != null}">${fv.label}</c:if>"
                                           style="width: 100%;"
                                           class="form-control">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label"><bean:message key="ssm.operations.provisioning.remotecommand.form.script_body.label"/><span class="required-form-field">*</span>:</label>
                                <div class="col-md-6">
                                    <textarea id="script_body" name="script_body" rows="8" wrap="off" style="width: 100%;" class="form-control"><c:choose><c:when test="${fv.script == null}">#!/bin/sh</c:when><c:otherwise>${fv.script}</c:otherwise></c:choose>
</textarea>
                                </div>
                            </div>
                    <jsp:include page="/WEB-INF/pages/common/fragments/schedule-options.jspf"/>
                    <html:hidden property="submitted" value="true"/>
                    <div class="form-group">
                        <div class="col-md-offset-3 col-md-6">
                            <input type="submit" class="btn btn-success" name="schedule_remote_command" value="<bean:message key='ssm.operations.provisioning.remotecommand.form.submit'/>">
                        </div>
                    </div>
                </html:form>

                <div id="system-list">
                    <rl:listset name="groupSet">
                        <rhn:csrf />
                        <rhn:submitted />
                        <rl:list
                            dataset="pageList"
                            name="systemList"
                            emptykey="nosystems.message"
                            alphabarcolumn="name"
                            filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter">

                            <rl:decorator name="SystemIconDecorator"/>
                            <rl:decorator name="PageSizeDecorator"/>

                            <!-- Name Column -->
                            <rl:column sortable="true"
                                       bound="false"
                                       headerkey="systemlist.jsp.system"
                                       sortattr="name"
                                       defaultsort="asc"
                                       styleclass="${namestyle}">
                                <%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %>
                            </rl:column>

                            <!-- Base Channel Column -->
                            <rl:column sortable="false"
                                       bound="false"
                                       headerkey="systemlist.jsp.channel"  >
                                <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_list_fragment.jspf" %>
                            </rl:column>

                            <!-- Entitlement Column -->
                            <rl:column sortable="false"
                                       bound="false"
                                       headerkey="systemlist.jsp.entitlement"
                                       styleclass="last-column">
                                <c:out value="${current.entitlementLevel}" escapeXml="false"/>
                            </rl:column>
                        </rl:list>
                    </rl:listset>
                </div>
            </c:when>
            <c:otherwise>
                <p><strong><bean:message key="ssm.operations.provisioning.remotecommand.nosystems" /></strong></p>
            </c:otherwise>
        </c:choose>
    </body>
</html>
