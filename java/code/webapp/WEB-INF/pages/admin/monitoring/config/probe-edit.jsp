<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>
    <body>
        <script type="text/javascript" language="JavaScript">
                    <!--
            function refreshNotifFields() {
                form = document.forms['probeEditForm'];
                form.notification_interval_min.disabled = !form.notification.checked;
                form.contact_group_id.disabled = !form.notification.checked;
                return true;
            }
            //-->
        </script>
        <rhn:toolbar base="h1" icon="header-monitoring"
                     helpUrl="/rhn/help/reference/en-US/s1-sm-monitor.jsp#s2-sm-monitor-psuites">
            <bean:message key="probe-edit.jsp.header1"
                          arg0="${probe.description}"
                          arg1="${probeSuite.suiteName}" />
        </rhn:toolbar>
        <rhn:dialogmenu mindepth="0"
                        maxdepth="1"
                        definition="/WEB-INF/nav/probesuite_detail_edit.xml"
                        renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <h2><bean:message key="probe-edit.jsp.header2"/></h2>
        <html:form action="/monitoring/config/ProbeSuiteProbeEdit"
                   styleClass="form-horizontal"
                   method="POST">
            <rhn:csrf />
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="probeedit.jsp.probecommand" />
                </label>
                <div class="col-lg-6 text">${probe.command.description}</div>
            </div>
            <c:if test='${not empty probe.command.systemRequirements}'>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="probeedit.jsp.commandrequirements" />
                    </label>
                    <div class="col-lg-6 text">
                        <bean:message key="${probe.command.systemRequirements}"/>
                    </div>
                </div>
            </c:if>
            <c:if test='${not empty probe.command.versionSupport}'>
                <div class="form-group">
                    <label class="col-lg-3 control-label">
                        <bean:message key="probeedit.jsp.versionsupport" />
                    </label>
                    <div class="col-lg-6 text">${probe.command.versionSupport}</div>
                </div>
            </c:if>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="description">
                    <bean:message key="probeedit.jsp.description" />
                </label>
                <div class="col-lg-6">
                    <html:text property="description"
                               maxlength="100"
                               styleClass="form-control"
                               size="50"
                               styleId="description"/>
                </div>
            </div>
            <div class="form-group">
                <label for="notification" class="col-lg-3 control-label">
                    <bean:message key="probeedit.jsp.notification" />
                </label>
                <div class="col-lg-6">
                    <div class="checkbox">
                    <html:checkbox onclick="refreshNotifFields()"
                                   property="notification"
                                   styleId="notification"/>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label for="notifmin" class="col-lg-3 control-label">
                    <bean:message key="probeedit.jsp.notifmin" />
                </label>
                <div class="col-lg-6">
                    <html:select property="notification_interval_min"
                                 styleClass="form-control"
                                 disabled="${not probeEditForm.map.notification}"
                                 styleId="notifmin">
                        <html:options collection="intervals"
                                      property="value"
                                      labelProperty="label" />
                    </html:select>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="notifmethod">
                    <bean:message key="probeedit.jsp.notifmethod" />
                </label>
                <div class="col-lg-6">
                    <html:select property="contact_group_id"
                                 styleClass="form-control"
                                 disabled="${not probeEditForm.map.notification}"
                                 styleId="notifmethod">
                        <html:options collection="contactGroups"
                                      property="value"
                                      labelProperty="label" />
                    </html:select>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="checkinterval">
                    <bean:message key="probeedit.jsp.checkinterval" />
                </label>
                <div class="col-lg-6">
                    <html:select property="check_interval_min"
                                 styleClass="form-control"
                                 styleId="checkinterval">
                        <html:options collection="intervals"
                                      property="value"
                                      labelProperty="label" />
                    </html:select>
                </div>
            </div>

            <%@ include file="/WEB-INF/pages/common/fragments/probes/render-param-value-list.jspf" %>

            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:submit styleClass="btn btn-success">
                        <bean:message key="probedit.jsp.updateprobe"/>
                    </html:submit>
                </div>
            </div>

            <html:hidden property="suite_id" value="${param.suite_id}"/>
            <html:hidden property="probe_id" value="${probe.id}"/>
            <html:hidden property="submitted" value="true"/>
        </html:form>
    </body>
</html>
