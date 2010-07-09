<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
    <head>
        <meta name="page-decorator" content="none" />
    </head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-system_group.gif"
	           helpUrl="/rhn/help/reference/en-US/s1-sm-monitor.jsp#s2-sm-monitor-psuites">
    <bean:message key="probesuiteedit.jsp.header1" arg0="${probeSuite.suiteName}" />
  </rhn:toolbar>


<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/probesuite_detail_edit.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />


<h2><bean:message key="probesuiteedit.jsp.header"/></h2>



<html:form action="/monitoring/config/ProbeSuiteEdit" method="POST">
    <%@ include file="suite-form.jspf" %>
    <tr>
      <td></td>
      <td align="right"><html:submit><bean:message key="probesuiteedit.jsp.updatesuite"/></html:submit></td>
    </tr>
    <html:hidden property="suite_id" value="${probeSuite.id}"/>
    <html:hidden property="submitted" value="true"/>
</html:form>

</body>
</html>
