<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<rhn:toolbar base="h1" icon="header-preferences">
  <bean:message key="summary.jsp.toolbar"/>
</rhn:toolbar>

  <p>
  <bean:message key="summary.jsp.summary" />
  <ol>
    <li><bean:message key="summary.jsp.stepone" />
    <li><bean:message key="summary.jsp.steptwo" />
  </ol>
  </p>

<form method="post" role="form" name="rhn_list"
	action="/rhn/configuration/system/Summary.do">
  <rhn:csrf />
  <rhn:submitted />
  <%@ include file="/WEB-INF/pages/common/fragments/configuration/enablesummary.jspf" %>
</form>

</body>
</html>

