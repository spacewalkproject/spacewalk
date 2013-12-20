<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<html:xhtml/>
<html>

<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:require acl="not system_feature(ftr_package_remove)">
	<h2>
		<rhn:icon type="header-package-del" title="errata.common.deletepackageAlt" />
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
		<rhn:icon type="header-package-del" title="errata.common.deletepackageAlt" />
		<bean:message key="packagelist.jsp.removablepackages" />
	</h2>
	<div class="page-summary">
		<p>
		<bean:message key="packagelist.jsp.removepagesummary" />
		</p>
	</div>
</rhn:require>

<c:set var="pageList" value="${requestScope.all}" />

<rl:listset name="packageListSet">
    <rhn:csrf />
    <rhn:submitted />
	<rl:list dataset="pageList"
         width="100%"
         name="packageList"
         emptykey="packagelist.jsp.nopackages"
         alphabarcolumn="nvre">
 			<rl:decorator name="PageSizeDecorator"/>
 		<rl:decorator name="SelectableDecorator"/>
	 		<rl:selectablecolumn value="${current.selectionKey}"
	 			selected="${current.selected}"
	 			disabled="${not current.selectable}"/>

		  <rl:column headerkey="packagelist.jsp.packagename" bound="false"
		  	sortattr="nvre"
		  	sortable="true" filterattr="nvre">
            <c:choose>
                <c:when test="${not empty current.packageId}">
                    <a href="/rhn/software/packages/Details.do?sid=${param.sid}&amp;id_combo=${current.idCombo}">
		            ${current.nvre}</a>
                </c:when>
                <c:otherwise>
                    <c:out value="${current.nvre}"/>
                </c:otherwise>
            </c:choose>
		  </rl:column>
    <rl:column headerkey="packagelist.jsp.packagearch" bound="false">
    	<c:choose>
    		<c:when test ="${not empty current.arch}">${current.arch}</c:when>
    		<c:otherwise><bean:message key="packagelist.jsp.notspecified"/></c:otherwise>
    	</c:choose>
    </rl:column>
    <rl:column headerkey="packagelist.jsp.installtime" bound="false"
		sortattr="installTimeObj" sortable="true">
		<c:choose>
            <c:when test ="${not empty current.installTime}">${current.installTime}</c:when>
            <c:otherwise><bean:message key="packagelist.jsp.notspecified"/></c:otherwise>
        </c:choose>
    </rl:column>
	</rl:list>

<c:if test="${not empty requestScope.all}">
<div class="text-right">
   <rhn:submitted/>
   <hr/>
	<rhn:require acl="system_feature(ftr_package_remove)">
		    <input type="submit"
		    	name ="dispatch"
			    value='<bean:message key="packagelist.jsp.removepackages"/>'/>
     </rhn:require>

</div>
</c:if>

</rl:listset>
</body>
</html>
