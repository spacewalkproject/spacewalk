<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
    <meta name="name" value="sdc.config.jsp.header" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<div class="row-0">
    <div class="col-md-6">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4><bean:message key="sdc.config.header.overview"/></h4>
            </div>
            <div class="panel-body">
                <div class="form-horizontal">
                    <div class="form-group">
                        <label class="col-md-5"><bean:message key="sdc.config.centrally-managed"/>:</label>
                        <div class="col-md-6">
                            <div class="form-horizontal">
                                <div class="form-group">
                                    <label class="col-md-3"><bean:message key="sdc.config.files.total"/>:</label>
                                    <div class="col-md-9">
                                        ${requestScope.centralFiles}
                                    </div>
                                </div>
                                <rhn:require mixins="com.redhat.rhn.common.security.acl.SystemAclHandler" acl="client_capable(configfiles.deploy)">
                                <div class="form-group">
                                    <label class="col-md-3"><bean:message key="sdc.config.files.deployable"/>:</label>
                                    <div class="col-md-9">
                                        ${requestScope.deployableFiles}
                                    </div>
                                </div>
                                </rhn:require>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-5"><bean:message key="sdc.config.locally-managed"/>:</label>
                        <div class="col-md-6">
                            <div class="form-horizontal">
                                <div class="form-group">
                                    <label class="col-md-3"><bean:message key="sdc.config.files.total"/>:</label>
                                    <div class="col-md-9">
                                        ${requestScope.localFiles}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-5"><bean:message key="sdc.config.sandbox.files" />:</label>
                        <div class="col-md-6">
                            ${requestScope.sandboxFiles}
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-5"><bean:message key="sdc.config.central-channel.subscriptions"/>:</label>
                        <div class="col-md-6">
                            ${requestScope.globalConfigChannels}.&nbsp;[<a href="/rhn/systems/details/configuration/SubscriptionsSetup.do?sid=${param.sid}"><bean:message key="sdc.config.subscribe_to_channels"/></a>]
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Adding recent events -->
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4><bean:message key="sdc.config.header.recent-events"/></h4>
            </div>
            <div class="panel-body">
                <div class="form-horizontal">
                    <div class="form-group">
                        <label class="col-md-5"><bean:message key="sdc.config.last-config.deployment"/>:</label>
                        <div class="col-md-6">
                            <div class="form-horizontal">
                                <c:if test="${requestScope.deploymentTimeMessage}">
                                <div class="form-group">
                                    <div class="col-md-9">
                                        ${requestScope.deploymentTimeMessage}
                                    </div>
                                </div>
                                </c:if>
                                <div class="form-group">
                                    <div class="col-md-9">
                                        ${requestScope.deploymentDetailsMessage}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-5"><bean:message key="sdc.config.last-rhn.comparison"/>:</label>
                        <div class="col-md-6">
                            ${requestScope.diffTimeMessage}

                            ${requestScope.diffActionMessage}

                            <c:if test="${not empty requestScope.diffActionMessage}">
                                ${requestScope.diffDetailsMessage}
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4><bean:message key="sdc.config.header.actions"/></h4>
            </div>
                <c:choose>
                <c:when test="${requestScope.configEnabled}">
                <ul class="list-group">
                <rhn:require mixins="com.redhat.rhn.common.security.acl.SystemAclHandler" acl="client_capable(configfiles.deploy)">
                    <div class="list-group-item">
                        <strong>
                            <rhn:icon type="nav-bullet"/>
                            <bean:message key="sdc.config.deploy.files"/>
                        </strong>
                    </div>
                    <li class="list-group-item">
                        <bean:message key="sdc.config.deploy.managed-files" arg0 ="/rhn/systems/details/configuration/DeployFileConfirm.do?selectall=true&sid=${param.sid}" />
                    </li>
                    <li class="list-group-item">
                        <bean:message key="sdc.config.deploy.selected-files" arg0="/rhn/systems/details/configuration/DeployFile.do?sid=${param.sid}"/>
                    </li>
                </rhn:require>
                <rhn:require mixins="com.redhat.rhn.common.security.acl.SystemAclHandler" acl="client_capable(configfiles.diff)">
                    <div class="list-group-item">
                        <strong>
                            <rhn:icon type="nav-bullet"/>
                            <bean:message key="sdc.config.compare.files"/>
                        </strong>
                    </div>
                    <li class="list-group-item">
                        <bean:message key="sdc.config.compare.managed-files" arg0="/rhn/systems/details/configuration/DiffFileConfirm.do?selectall=true&sid=${param.sid}"/>
                    </li>
                    <li class="list-group-item">
                        <bean:message key="sdc.config.compare.selected-files" arg0="/rhn/systems/details/configuration/DiffFile.do?sid=${param.sid}"/>
                    </li>
                </rhn:require>
                    <div class="list-group-item">
                        <strong>
                            <rhn:icon type="nav-bullet"/>
                            <bean:message key="sdc.config.add-create.files"/>
                        </strong>
                    </div>
                    <li class="list-group-item">
                        <bean:message key="sdc.config.add-create.new-files" arg0 = "/rhn/systems/details/configuration/addfiles/CreateFile.do?sid=${param.sid}"/>
                    </li>
                    <li class="list-group-item">
                        <bean:message key="sdc.config.add-create.upload-files" arg0 = "/rhn/systems/details/configuration//addfiles/UploadFile.do?sid=${param.sid}"/>
                    </li>
                    <rhn:require mixins="com.redhat.rhn.common.security.acl.SystemAclHandler" acl="client_capable(configfiles.upload)">
                    <li class="list-group-item">
                        <bean:message key="sdc.config.add-create.import-all-files" arg0 = "/rhn/systems/details/configuration/addfiles/ImportFileConfirm.do?selectall=true&sid=${param.sid}"/>
                    </li>
                    <li class="list-group-item">
                        <bean:message key="sdc.config.add-create.import-selected-files" arg0="/rhn/systems/details/configuration/addfiles/ImportFile.do?sid=${param.sid}"/>
                    </li>
                    </rhn:require>
                </ul>
                </c:when>
                <c:otherwise>
                <div class="panel-body">
                    <p><bean:message key="system.sdc.missing.config_deploy1"/></p>
                    <p><bean:message key="system.sdc.missing.config_deploy2"
                                     arg0="/rhn/configuration/system/TargetSystems.do"
                                     arg1="${rhn:localize('targetsystems.jsp.toolbar')}"
                                     arg2="${rhn:localize('targetsystems.jsp.enable')}"/></p>
                </div>
                </c:otherwise>
                </c:choose>
        </div>
    </div>
</div>

</body>
</html>
