<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-system_group.gif"
	           creationUrl="ProbeSuiteCreate.do"
               creationType="probesuite"
               helpUrl="/rhn/help/reference/en-US/s1-sm-monitor.jsp#s2-sm-monitor-psuites">
    <bean:message key="probesuites.jsp.header1"/>
  </rhn:toolbar>

<h2><bean:message key="probesuites.jsp.header2"/></h2>

<div>
  <p>
    <bean:message key="probesuites.jsp.summary"/>
  </p>
  <c:if test="${containsNonSelectable}">
  <p>
    <bean:message key="probesuites.jsp.access"/>
  </p>
  </c:if>
    <form method="POST" name="rhn_list" action="/rhn/monitoring/config/ProbeSuitesSubmit.do">
    <rhn:list pageList="${requestScope.pageList}" noDataText="probesuites.jsp.nosuites">
      <rhn:listdisplay   set="${requestScope.set}" exportColumns="id,suiteName,description,systemCount"
         hiddenvars="${requestScope.newset}" button="probesuites.jsp.deleteprobesuites">
        <rhn:set value="${current.id}" disabled="${not current.selectable}"/>
        <rhn:column header="probesuites.jsp.name">
            <c:if test="${current.selectable}">
              <A HREF="ProbeSuiteEdit.do?suite_id=${current.id}">${current.suiteName}</A>
            </c:if>
            <c:if test="${not current.selectable}">
              ${current.suiteName}
            </c:if>
        </rhn:column>
        <rhn:column header="probesuites.jsp.description">
            ${current.description}
        </rhn:column>
        <rhn:column header="probesuites.jsp.system_count">
            <c:if test="${current.selectable}">
              <A HREF="ProbeSuiteSystems.do?suite_id=${current.id}">${current.systemCount}</A>
            </c:if>
            <c:if test="${not current.selectable}">
              &mdash;
            </c:if>
        </rhn:column>
      </rhn:listdisplay>
    </rhn:list>
    </form>

    
  </p>
</div>


</body>
</html>

