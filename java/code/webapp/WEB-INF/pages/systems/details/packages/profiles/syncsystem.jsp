<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2>
    <bean:message key="schedulesync.jsp.profilesync" />
</h2>

<rl:listset name="compareListSet">
    <rhn:csrf />
    <div class="page-summary">
        <bean:message key="schedulesync.jsp.pagesummary"
                      arg0="${fn:escapeXml(requestScope.system.name)}"
                      arg1="${fn:escapeXml(requestScope.system1.name)}" />
    </div>

    <rl:list width="100%"
        name="compareList"
        styleclass="list"
        emptykey="schedulesync.jsp.nopackagesselected">

        <rl:column headerkey="schedulesync.jsp.package" bound="false">
            ${current.name}
        </rl:column>

        <rl:column headerkey="packagelist.jsp.packagearch" bound="false">
            ${current.arch}
        </rl:column>

        <rl:column headerkey="schedulesync.jsp.action" bound="false">
            ${current.actionStatus}
        </rl:column>
    </rl:list>

    <p><bean:message key="schedulesync.jsp.disclaimer" /></p>
    <jsp:include page="/WEB-INF/pages/common/fragments/datepicker-with-label.jsp">
        <jsp:param name="widget" value="date" />
        <jsp:param name="label_text" value="confirm.jsp.than" />
    </jsp:include>

    <rhn:require acl="system_feature(ftr_delta_action)"
        mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
        <rhn:submitted/>
        <div class="text-right">
            <hr />
            <html:submit styleClass="btn btn-default" property="dispatch">
                <bean:message key="schedulesync.jsp.schedulesync" />
            </html:submit>
        </div>
    </rhn:require>

    <html:hidden property="sid" value="${param.sid}" />
    <html:hidden property="sid_1" value="${param.sid_1}" />
    <html:hidden property="set_label" value="packages_for_system_sync" />

</rl:listset>

</body>
</html>
