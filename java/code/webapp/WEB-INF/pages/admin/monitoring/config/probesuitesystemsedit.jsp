<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>

  <rhn:toolbar base="h1" img="/img/rhn-icon-system_group.gif"
	           helpUrl="/rhn/help/reference/en-US/s1-sm-monitor.jsp#s2-sm-monitor-psuites">
    <bean:message key="probesuitesystemsedit.jsp.header1" arg0="${probeSuite.suiteName}" />
  </rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/probesuite_detail_edit.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<div>
  <p>
    <bean:message key="probesuitesystemsedit.jsp.summary"/>

    <form method="POST" name="rhn_list" action="/rhn/monitoring/config/ProbeSuiteSystemsEditSubmit.do">
    <rhn:list pageList="${requestScope.pageList}" noDataText="probesuitesystemsedit.jsp.nosystems">
      <rhn:listdisplay filterBy="probesuitesystemsedit.jsp.systemname"
            set="${requestScope.set}"
        hiddenvars="${requestScope.newset}" >
        <rhn:set value="${current.id}" />
        <rhn:column header="probesuitesystems.jsp.system">
            <a href="/rhn/systems/details/probes/ProbesList.do?sid=${current.id}">${current.name}</a>
        </rhn:column>
      </rhn:listdisplay>
    </rhn:list>
    <html:hidden property="suite_id" value="${probeSuite.id}"/>
    <c:if test="${not empty pageList}">
      <div align="right">
        <hr><bean:message key="probesuitesystemsedit.jsp.monscouttouse"/>
        <select name="satCluster">
          <c:forEach items="${satClusters}" var="cluster">
            <option value="${cluster.id}">${cluster.description}</option>
          </c:forEach>
        </select>&nbsp;
        <html:submit property="dispatch">
          <bean:message key="probesuitesystemsedit.jsp.addsystem"/>
        </html:submit>
      </div>
    </c:if>
    </form>
  </p>
</div>


</body>
</html>

