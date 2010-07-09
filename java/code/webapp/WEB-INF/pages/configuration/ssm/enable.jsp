<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean"	prefix="bean"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html"	prefix="html"%>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <img src="/img/rhn-config_files.gif" alt='<bean:message key="ssmdiff.jsp.imgAlt" />' />
  <bean:message key="ssmenable.jsp.header"/>
</h2>

<div class="page-summary">
  <p>
  <bean:message key="ssmenable.jsp.summary" />
  </p>
</div>

<div>
<html:form method="POST" action="/systems/ssm/config/EnableSubmit">
<rhn:list pageList="${requestScope.pageList}"
          noDataText="targetsystems.jsp.noSystems">

  <rhn:listdisplay filterBy="system.common.systemName">
    <%@ include file="/WEB-INF/pages/common/fragments/configuration/enablelist.jspf" %>
  </rhn:listdisplay>
  <%@ include file="/WEB-INF/pages/common/fragments/configuration/enablewidgets.jspf" %>
</rhn:list>
</html:form>
</div>

</body>
</html>
