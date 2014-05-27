<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-snapshot-rollback">
  <bean:message key="system.history.snapshot.header-rollback" arg0="${param.snapshot_name}" />
</rhn:toolbar>

<c:set var="rollback_links">
<a href="/rhn/systems/details/history/snapshots/Groups.do?sid=${param.sid}&amp;ss_id=${param.ss_id}"><bean:message key="system.history.snapshot.groups-link"/></a>,
<a href="/rhn/systems/details/history/snapshots/Channels.do?sid=${param.sid}&amp;ss_id=${param.ss_id}"><bean:message key="system.history.snapshot.channels-link"/></a>,
<a href="/rhn/systems/details/history/snapshots/Packages.do?sid=${param.sid}&amp;ss_id=${param.ss_id}"><bean:message key="system.history.snapshot.packages-link"/></a>,
<a href="/rhn/systems/details/history/snapshots/ConfigChannels.do?sid=${param.sid}&amp;ss_id=${param.ss_id}"><bean:message key="system.history.snapshot.config-channel-link"/></a>
and
<a href="/rhn/systems/details/history/snapshots/ConfigFiles.do?sid=${param.sid}&amp;ss_id=${param.ss_id}"><bean:message key="system.history.snapshot.config-files-link"/></a>
</c:set>
<div class="page-summary">
  <p><bean:message key="system.history.snapshot.summary-rollback" arg0="${rollback_links}" /></p>
     <c:if test="${! empty param.invalid_reason_label}">
        <div class="local-alert">
        <p>
        <c:choose>
        <c:when test="${param.invalid_reason_label == 'sg_removed'}">
            <bean:message key="system.history.snapshot.sg_removed" arg0='<br />' />
        </c:when>
        <c:when test="${param.invalid_reason_label == 'channel_removed'}">
            <bean:message key="system.history.snapshot.channel_removed" arg0='<br />' />
        </c:when>
        <c:when test="${param.invalid_reason_label == 'channel_modified'}">
            <bean:message key="system.history.snapshot.channel_modified" arg0='<br />' />
        </c:when>
        <c:when test="${param.invalid_reason_label == 'ns_removed'}">
            <bean:message key="system.history.snapshot.ns_removed" arg0='<br />' />
        </c:when>
        <c:otherwise>
            ${param.invalid_reason_name}
        </c:otherwise>
        </c:choose>
        </p>
        </div>
     </c:if>
     <c:if test="${! empty param.snapshot_unservable_packages}">
        <div class="local-alert">
        <p><bean:message key="system.history.snapshot.unservable_packages"
                      arg0='<a href="/network/systems/details/history/snapshots/unservable_packages.pxt?sid=${param.sid}&amp;ss_id=${param.ss_id}">'
                      arg1='</a>' /></p>
        </div>
     </c:if>
     <rhn:require mixins="com.redhat.rhn.common.security.acl.SystemAclHandler"
                     acl="client_capable(configfiles.deploy); not client_capable(packages.runTransaction)">
        <div class="local-alert">
        <p><bean:message key="system.history.snapshot.notransactions"
                      arg0='<strong>'
                      arg1='</strong>' /></p>
        </div>
     </rhn:require>
     <bean:message key="system.history.snapshot.summary-rollback2" />
</div>
<br />

<html:form method="POST" styleClass="form-horizontal" action="/systems/details/history/snapshots/Rollback.do">
    <rhn:csrf />
    <html:hidden property="sid" value="${param.sid}" />
    <html:hidden property="ss_id" value="${param.ss_id}" />

    <div class="form-group">
        <label class="col-lg-3 control-label">
            <bean:message key="system.history.snapshot.group-membership" />
        </label>
        <div class="col-lg-6">
            <p class="form-control-static">
                <bean:message key="system.history.snapshot.diff-count" arg0="${param.group_changes}" />
            </p>
        </div>
    </div>
    <div class="form-group">
        <label class="col-lg-3 control-label">
            <bean:message key="system.history.snapshot.channel-subscription" />
        </label>
        <div class="col-lg-6">
            <p class="form-control-static">
                <bean:message key="system.history.snapshot.diff-count"  arg0="${param.channel_changes}" />
            </p>
        </div>
    </div>
    <div class="form-group">
        <label class="col-lg-3 control-label">
            <bean:message key="system.history.snapshot.package-manifest" />
        </label>
        <div class="col-lg-6">
            <p class="form-control-static">
                <bean:message key="system.history.snapshot.diff-count"  arg0="${param.package_changes}" />
            </p>
        </div>
    </div>
    <div class="form-group">
        <label class="col-lg-3 control-label">
            <bean:message key="system.history.snapshot.config-channel-membership" />
        </label>
        <div class="col-lg-6">
            <p class="form-control-static">
                <bean:message key="system.history.snapshot.diff-count" arg0="${param.config_changes}" />
            </p>
        </div>
    </div>
    <div class="form-group">
        <label class="col-lg-3 control-label">
            <bean:message key="system.history.snapshot.config-files" />
        </label>
        <div class="col-lg-6">
            <p class="form-control-static">
                <strong><bean:message key="system.history.snapshot.config-files-msg" /></strong>
            </p>
        </div>
    </div>
    <div class="form-group">
        <div class="col-sm-6">
            <rhn:icon type="nav-up" />
            <a href="/rhn/systems/details/history/snapshots/Index.do?sid=${param.sid}">
                <bean:message key="system.history.snapshot.rollback-return-to-list" />
            </a>
        </div>
        <div class="col-sm-6 text-right">
            <rhn:submitted/>
            <html:submit styleClass="btn btn-success" property="dispatch">
                <bean:message key="system.history.snapshot.rollback-button" />
            </html:submit>
        </div>
    </div>
</html:form>
</body>
</html>
