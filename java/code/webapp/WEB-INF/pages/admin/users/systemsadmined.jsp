<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
<h2><bean:message key="systemsadmined.jsp.header"/></h2>

<div class="page-summary"> <p>
  <bean:message key="systemsadmined.jsp.summary" arg0="/rhn/users/AssignedSystemGroups.do?uid=${param.uid}" />
</p> </div>

<h2><bean:message key="systemsadmined.jsp.headertwo"/></h2>

<div class="page-summary"> <p>
<bean:message key="systemsadmined.jsp.summarytwo"/></p></div>

<form method="post" name="rhn_list" action="/rhn/users/SystemsAdminedSubmit.do?uid=${user.id}">

<rhn:csrf />
<input type="hidden" name="uid" value="${user.id}" />

<rhn:list pageList="${requestScope.pageList}" noDataText="nosystems.message" >
  <rhn:listdisplay set="${requestScope.set}" hiddenvars="${requestScope.newset}">
    <rhn:set value="${current.id}" disabled="${not current.selectable}"/>
    <rhn:column header="systemsadmined.jsp.name">
      <a href="/rhn/systems/details/Overview.do?sid=${current.id}">
        <c:out value="${current.serverName}" escapeXml="true" />
      </a>
    </rhn:column>
    <rhn:column header="systemsadmined.jsp.access">
      <c:forEach items="${current.groupName}" var="group">
        <c:out value="${group}"/><br />
      </c:forEach>
    </rhn:column>
  </rhn:listdisplay>

</rhn:list>
</form>

</body>
</html>

