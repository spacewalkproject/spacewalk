<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ page language="java" import="com.redhat.rhn.frontend.action.systems.SystemRemoteCommandAction.FormData"%>



<html>
    <head><meta name="page-decorator" content="none" /></head>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4><bean:message key="ssm.overview.provisioning.remotecommand.header" arg0="${system.name}"/></h4>
            </div>
            <div class="panel-body">
                <form action="/rhn/systems/details/SystemRemoteCommand.do" method="post" class="form-horizontal" role="form">
                    <rhn:csrf />
                    <div class="form-group">
                        <label class="col-lg-3 control-label" for="fUidInput">
                            <bean:message key="ssm.operations.provisioning.remotecommand.form.uid.label"/>
                            <span class="required-form-field">*</span>:
                        </label>
                        <div class="col-lg-3">
                            <input type="text" name="uid" maxlength="32" class="form-control"
                                   value="${formData.uid}" size="" id="fUidInput"/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label" for="fGidInput">
                            <bean:message key="ssm.operations.provisioning.remotecommand.form.gid.label"/>
                            <span class="required-form-field">*</span>:
                        </label>
                        <div class="col-lg-3">
                            <input type="text" name="gid" maxlength="32" class="form-control"
                                   value="${formData.gid}" size="" id="fGidInput"/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label" for="fTmoInput">
                            <bean:message key="ssm.operations.provisioning.remotecommand.form.timeout.label"/>:
                        </label>
                        <div class="col-lg-3">
                            <input type="text" name="timeout" maxlength="10" class="form-control"
                                   value="${formData.timeout}" size="" id="fTmoInput"/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label" for="fLblInput">
                            <bean:message key="ssm.operations.provisioning.remotecommand.form.lbl.label"/>:
                        </label>
                        <div class="col-lg-6">
                            <input type="text" name="lbl" maxlength="10" class="form-control"
                                   value="${formData.label}" size="" id="fLblInput"/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label" for="fSptInput">
                            <bean:message key="ssm.operations.provisioning.remotecommand.form.script_body.label"/>
                            <span class="required-form-field">*</span>:
                        </label>
                        <div class="col-lg-6">
                            <textarea name="script_body" class="form-control" id="fSptInput"
                                      rows="8" wrap="off" style="width: 100%;">${formData.scriptBody}</textarea>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label" for="fLblInput">
                            <bean:message key="ssm.operations.provisioning.remotecommand.form.date.label"/>:
                        </label>
                        <div class="col-lg-6">
                            <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                                <jsp:param name="widget" value="date"/>
                            </jsp:include>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-lg-offset-3 col-lg-6">
                            <button type="submit" name="schedule" class="btn btn-success"
                                    value="<bean:message key='ssm.operations.provisioning.remotecommand.form.submit'/>">
                                <bean:message key="ssm.operations.provisioning.remotecommand.form.submit" />
                        </button>
                        </div>
                    </div>
                    <input type="hidden" name="sid" value="${system.id}" />
                    <input type="hidden" name="submitted" value="true" />
                    <input type="hidden" name="use_date" value="true" />
                </form>
            </div>
        </div>
    </body>
</html>
