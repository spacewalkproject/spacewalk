<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2>
    <bean:message key="schedulesync.jsp.profilesync" />
</h2>

<rl:listset name="compareListSet">
    <div class="page-summary">
        <bean:message key="schedulesync.jsp.pagesummary"
                      arg0="${requestScope.system.name}"
                      arg1="${requestScope.system1.name}" />
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
    <table class="schedule-action-interface" align="center">
        <tr>
            <td><input type="radio" name="use_date" value="false" checked="checked" /></td>
            <th><bean:message key="confirm.jsp.now"/></th>
        </tr>
        <tr>
            <td><input type="radio" name="use_date" value="true"/></td>
            <th><bean:message key="confirm.jsp.than"/></th>
        </tr>
        <tr>
            <th><img src="/img/rhn-icon-schedule.gif" alt="<bean:message key="confirm.jsp.selection"/>"
                title="<bean:message key="confirm.jsp.selection"/>"/>
            </th>
            <td>
                <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                <jsp:param name="widget" value="date"/>
                </jsp:include>
            </td>
        </tr>
    </table>

    <rhn:require acl="system_feature(ftr_delta_action)"
        mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
        <rhn:submitted/>
        <div align="right">
            <hr />
            <html:submit property="dispatch">
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
