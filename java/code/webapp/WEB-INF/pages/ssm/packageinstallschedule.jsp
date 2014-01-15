<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
    <bean:message key="installconfirm.jsp.header"/>
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
             styleclass="list "
             emptykey="systemlist.jsp.nosystems">

        <rl:column headerkey="actions.jsp.system" bound="false"
                   sortattr="name" sortable="true">
            <c:out value="${current.name}" escapeXml="true" />
        </rl:column>

    </rl:list>

    <div class="form-horizontal">
        <div class="form-group">
            <label class="col-lg-3 control-label">
                <bean:message key="schedule.jsp.at"/>
            </label>
            <div class="col-lg-6">
                <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                    <jsp:param name="widget" value="date"/>
                </jsp:include>
            </div>
        </div>
        <div class="form-group">
            <div class="col-lg-offset-3 col-lg-6">
                <input type="submit"
                       name="dispatch"
                       value='<bean:message key="installconfirm.jsp.runremotecommand"/>'/>
                <input type="submit"
                       name="dispatch"
                       value='<bean:message key="installconfirm.jsp.confirm"/>'/>
            </div>
        </div>
    </div>

    <input type="hidden" name="packagesDecl" value="${requestScope.packagesDecl}" />
    <input type="hidden" name="cid" value="${param.cid}" />
    <input type="hidden" name="mode" value="${param.mode}" />
    <input type="hidden" name="use_date" value="true" />

</rl:listset>

</body>
</html>
