<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

  <h2>
    <i class="fa spacewalk-icon-package-upgrade" title="<bean:message key='errata.common.upgradepackageAlt' />"></i>
    <bean:message key="upgradable.jsp.header" />
  </h2>
  <div class="page-summary">
    <p>
      <bean:message key="upgradable.jsp.summary" />
    </p>
  </div>

<c:set var="pageList" value="${requestScope.all}" />

<rl:listset name="packageListSet">
    <rhn:csrf />
    <rhn:submitted />
	<rl:list dataset="pageList"
         width="100%"
         name="packageList"
         emptykey="packagelist.jsp.nopackages"
         alphabarcolumn="nvrea">
 			<rl:decorator name="PageSizeDecorator"/>
 			<rl:decorator name="ElaborationDecorator"/>
 		<rl:decorator name="SelectableDecorator"/>
	 		<rl:selectablecolumn value="${current.selectionKey}"
	 			selected="${current.selected}"
	 			disabled="${not current.selectable}"/>

		  <rl:column headerkey="upgradable.jsp.latest" bound="false"
			sortattr="nvrea"
			sortable="true" filterattr="nvrea">
		  	
		      <a href="/rhn/software/packages/Details.do?sid=${param.sid}&amp;id_combo=${current.idCombo}">
		        ${current.nvrea}</a>
		  </rl:column>

		  <rl:column headerkey="upgradable.jsp.installed" bound="false">
		      ${current.installedPackage}
		  </rl:column>

    <rl:column headerkey="upgradable.jsp.errata">
      <c:forEach items="${current.errata}" var="errata">
        <c:if test="${not empty errata.advisory}">
          <c:if test="${errata.type == 'Security Advisory'}">
            <i class="fa fa-lock" title="<bean:message key='erratalist.jsp.securityadvisory' />"></i>
          </c:if>
          <c:if test="${errata.type == 'Bug Fix Advisory'}">
            <i class="fa fa-bug" title="<bean:message key='erratalist.jsp.bugadvisory' />"></i>
          </c:if>
          <c:if test="${errata.type == 'Product Enhancement Advisory'}">
            <i class="fa  spacewalk-icon-enhancement" title="<bean:message key='erratalist.jsp.productenhancementadvisory' />"></i>
          </c:if>
          <a href="/rhn/errata/details/Details.do?eid=${errata.id}">${errata.advisory}</a><br/>
        </c:if>
      </c:forEach>
    </rl:column>
</rl:list>
 			
<c:if test="${not empty requestScope.all}">
<div class="text-right">
   <rhn:submitted/>
   <hr/>
    <input type="submit"
    	name ="dispatch"
	    value='<bean:message key="upgradable.jsp.upgrade"/>'/>		
</div>
</c:if> 			
</rl:listset>
</body>
</html>
