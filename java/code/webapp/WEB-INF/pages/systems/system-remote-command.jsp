<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ page language="java" import="com.redhat.rhn.frontend.action.systems.SystemRemoteCommandAction.FormData"%>

<html:xhtml/>

<html>
    <head><meta name="page-decorator" content="none" /></head>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
        <h2><bean:message key="ssm.overview.provisioning.remotecommand.header" arg0="${system.name}"/></h2>
        <html:form action="/systems/details/SystemRemoteCommand" method="post">
            <rhn:csrf />
            <table class="details" align="center">
                <tbody>
                    <tr>
                        <th><bean:message key="ssm.operations.provisioning.remotecommand.form.uid.label"/><span class="required-form-field">*</span>:</th>
                        <td><input type="text" name="uid" maxlength="32" value="${formData.uid}" size=""></td>
                    </tr>
                    <tr>
                        <th><bean:message key="ssm.operations.provisioning.remotecommand.form.gid.label"/><span class="required-form-field">*</span>:</th>
                        <td><input type="text" name="gid" maxlength="32" value="${formData.gid}" size=""></td>
                    </tr>
                    <tr>
                        <th><bean:message key="ssm.operations.provisioning.remotecommand.form.timeout.label"/>:</th>
                        <td><input type="text" name="timeout" maxlength="" value="${formData.timeout}" size="6"></td>
                    </tr>
                    <tr>
                        <th><bean:message key="ssm.operations.provisioning.remotecommand.form.lbl.label"/>:</th>
                        <td><input type="text" id="lbl" name="lbl" value="${formData.label}" style="width: 100%;"></td>
                    </tr>
                    <tr>
                        <th><bean:message key="ssm.operations.provisioning.remotecommand.form.script_body.label"/><span class="required-form-field">*</span>:</th>
                        <td><textarea name="script_body" rows="8" wrap="off" style="width: 100%;">${formData.scriptBody}</textarea></td>
                    </tr>
                    <tr>
                        <th><bean:message key="ssm.operations.provisioning.remotecommand.form.date.label"/>:</th>
                        <td>
                            <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                                <jsp:param name="widget" value="date"/>
                            </jsp:include>
                        </td>
                    </tr>
                </tbody>
            </table>

            <input type="hidden" name="sid" value="${system.id}">
            <div align="right">
                <hr>
                <input type="submit" name="schedule" value="<bean:message key="ssm.operations.provisioning.remotecommand.form.submit" />">
                <input type="hidden" name="submitted" value="true">
                <hidden name="use_date" value="true" />
            </div>
        </html:form>

    </body>
</html>
