<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
    <bean:message key="upgrade.jsp.header"/>
</h2>

<div class="page-summary">
    <c:if test="${requestScope.numSystems != '1'}">
        <p><bean:message key="ssm.package.install.schedule.summary.plural" arg0="${requestScope.numSystems}"/></p>
    </c:if>
    <c:if test="${requestScope.numSystems == '1'}">
        <p><bean:message key="ssm.package.install.schedule.summary.single" arg0="${requestScope.numSystems}"/></p>
    </c:if>
</div>

<rl:listset name="groupSet">
    <rhn:csrf />
    <rhn:submitted />

    <rl:list dataset="pageList"
             width="100%"
             name="groupList"
             styleclass="list">

        <rl:decorator name="ElaborationDecorator"/>

        <rl:column headerkey="actions.jsp.system" bound="false"
                   sortattr="name" sortable="true">
            <c:out value="${current.server_name}" escapeXml="true" />
        </rl:column>

        <rl:column headerkey="ssm.package.upgrade.schedule.packages" bound="false"
                   sortable="false">
            <c:forEach begin="0" end="19" items="${current.elaborator0}" var="item" varStatus="status">
                <c:out value="${item.nvre}"/><br/>
            </c:forEach>

            <c:if test="${fn:length(current.elaborator0) > 19}">
                <i><bean:message key="ssm.package.upgrade.schedule.toomanypackages"/></i>
            </c:if>

        </rl:column>

    </rl:list>

    <div class="text-right">

        <div align="left">
            <p><bean:message key="installconfirm.jsp.widgetsummary"/></p>
        </div>

        <table class="schedule-action-interface" align="center">

            <tr>
                <td><input type="radio" name="use_date" value="false" checked="checked"/>
                </td>
                <th><bean:message key="confirm.jsp.now"/></th>
            </tr>
            <tr>
                <td><input type="radio" name="use_date" value="true"/></td>
                <th><bean:message key="confirm.jsp.than"/></th>
            </tr>
            <tr>
                <th><img src="/img/rhn-icon-schedule.gif"
                         alt="<bean:message key="confirm.jsp.selection"/>"
                         title="<bean:message key="confirm.jsp.selection"/>"/>
                </th>
                <td>
                    <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                        <jsp:param name="widget" value="date"/>
                    </jsp:include>
                </td>
            </tr>
        </table>

        <hr/>
        <input type="submit"
               name="dispatch"
               value='<bean:message key="upgradeconfirm.jsp.runremotecommand"/>'/>
        <input type="submit"
               name="dispatch"
               value='<bean:message key="installconfirm.jsp.confirm"/>'/>
    </div>

    <input type="hidden" name="packagesDecl" value="${requestScope.packagesDecl}" />
    <input type="hidden" name="mode" value="${param.mode}" />

</rl:listset>

</body>
</html>
