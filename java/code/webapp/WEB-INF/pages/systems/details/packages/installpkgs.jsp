<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>

<body>

<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2>
	<img src="/img/rhn-icon-package_add.gif"
	     alt="<bean:message key='errata.common.addpackageAlt' />" />
	<bean:message key="installpkgs.jsp.header" />
</h2>
<div class="page-summary">
	<p>
	<bean:message key="installpkgs.jsp.summary" />
	</p>
</div>


<form method="POST" name="rhn_list" action="/rhn/systems/details/packages/InstallPackagesSubmit.do?sid=${param.sid}">
<rhn:list pageList="${requestScope.pageList}" noDataText="packagelist.jsp.nopackages">

  <rhn:listdisplay set="${requestScope.set}" filterBy="packagelist.jsp.packagename" 
                   hiddenvars="${requestScope.newset}" button="installpkgs.jsp.installpackages">

    <rhn:set element="${current.idOne}" elementTwo="${current.idTwo}" />
    <rhn:column header="packagelist.jsp.packagename" width="95%"
                url="/network/software/packages/details.pxt?sid=${param.sid}&amp;id_combo=${current.idCombo}">
      ${current.nvre}
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>

</form>
</body>
</html>
