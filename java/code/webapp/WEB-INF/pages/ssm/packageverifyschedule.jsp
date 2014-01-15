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
    <bean:message key="verifyconfirm.jsp.header"/>
</h2>

<div class="page-summary">
    <bean:message key="ssm.package.verify.schedule.summary"/>
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
            <c:out value="${current.system_name}" escapeXml="true" />
        </rl:column>

        <rl:column headerkey="ssm.package.verify.schedule.packages" bound="false"
                   sortable="false">
            <c:forEach begin="0" end="19" items="${current.elaborator0}" var="item" varStatus="status">
                <c:out value="${item.nvre}"/><br/>
            </c:forEach>

            <c:if test="${fn:length(current.elaborator0) > 19}">
                <i><bean:message key="ssm.package.verify.schedule.toomanypackages"/></i>
            </c:if>

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
                       value='<bean:message key="installconfirm.jsp.confirm"/>'/>
            </div>
       </div>
    </div>

    <input type="hidden" name="packagesDecl" value="${requestScope.packagesDecl}" />
    <input type="hidden" name="cid" value="${param.cid}" />
    <input type="hidden" name="use_date" value="true" />

</rl:listset>

</body>
</html>
