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
	<bean:message key="verifypkgs.jsp.verifiablepackages" />
</h2>
<div class="page-summary">
	<p>
	<bean:message key="verifypkgs.jsp.verifypagesummary" />
	</p>
</div>


<form method="POST" name="rhn_list" action="/rhn/systems/details/packages/VerifyPackagesSubmit.do?sid=${param.sid}">
<rhn:list pageList="${requestScope.pageList}" noDataText="packagelist.jsp.nopackages">

  <rhn:listdisplay set="${requestScope.set}" filterBy="packagelist.jsp.packagename" 
                   hiddenvars="${requestScope.newset}" button="verifypkgs.jsp.verifypackages">

    <rhn:set element="${current.idOne}" elementTwo="${current.idTwo}" />
    <rhn:column header="packagelist.jsp.packagename" width="80%"
                url="/rhn/software/packages/Details.do?sid=${param.sid}&amp;id_combo=${current.idCombo}">
      ${current.nvre}
    </rhn:column>
    <rhn:column header="packagelist.jsp.packagearch" width="15%">
    	<c:choose>
    		<c:when test ="${not empty current.arch}">${current.arch}</c:when>
    		<c:otherwise><bean:message key="packagelist.jsp.notspecified"/></c:otherwise>
    	</c:choose>
    </rhn:column>    
  </rhn:listdisplay>
</rhn:list>

</form>
</body>
</html>
