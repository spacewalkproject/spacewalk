<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-config_system.gif">
  <bean:message key="summary.jsp.toolbar"/>
</rhn:toolbar>

<div class="page-summary">
  <p>
  <bean:message key="summary.jsp.summary" />
  <ol>
    <li><bean:message key="summary.jsp.stepone" />
    <li><bean:message key="summary.jsp.steptwo" />
  </ol>
  </p>
</div>

<div>
<form method="post" name="rhn_list"
	action="/rhn/configuration/system/Summary.do">
  <%@ include file="/WEB-INF/pages/common/fragments/configuration/enablesummary.jspf" %>
</form>
</div>

</body>
</html>

