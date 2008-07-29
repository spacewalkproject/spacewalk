<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:require acl="not system_feature(ftr_package_remove)">
	<h2>
		<img src="/img/rhn-icon-package_del.gif"
		     alt="<bean:message key='errata.common.deletepackageAlt' />" />
		<bean:message key="packagelist.jsp.installedpackages" />
	</h2>
	<div class="page-summary">
		<p>
		<bean:message key="packagelist.jsp.installedpagesummary" />
		</p>
	</div>
</rhn:require>
<rhn:require acl="system_feature(ftr_package_remove)">
	<h2>
		<img src="/img/rhn-icon-package_del.gif"
		     alt="<bean:message key='errata.common.deletepackageAlt' />" />
		<bean:message key="packagelist.jsp.removablepackages" />
	</h2>
	<div class="page-summary">
		<p>
		<bean:message key="packagelist.jsp.removepagesummary" />
		</p>
	</div>
</rhn:require>

<form method="POST" name="rhn_list" action="/rhn/systems/details/packages/PackageListSubmit.do?sid=${param.sid}">
<rhn:list pageList="${requestScope.pageList}" noDataText="packagelist.jsp.nopackages">

  <rhn:listdisplay set="${requestScope.set}" filterBy="packagelist.jsp.packagename" 
                   hiddenvars="${requestScope.newset}" button="packagelist.jsp.removepackages"
                   buttonAcl="system_feature(ftr_package_remove)">

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
