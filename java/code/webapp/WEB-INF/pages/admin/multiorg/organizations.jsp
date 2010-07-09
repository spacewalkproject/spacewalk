<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-org.gif"
     creationUrl="/rhn/admin/multiorg/OrgCreate.do"
     creationType="org">
  <bean:message key="organizations.jsp.toolbar"/>
</rhn:toolbar>
<c:set var="pageList" value="${requestScope.pageList}" />
<div>
<rl:listset name="orgListSet">
<!-- Start of org list -->
<rl:list dataset="pageList"
         width="100%"
         name="orgList"
         styleclass="list"
         filter="com.redhat.rhn.frontend.action.multiorg.OrgListFilter"
         emptykey="orglist.jsp.noOrgs">

	<!-- Organization name column -->		
	<rl:column bound="false"
	           sortable="true"
	           styleclass="first-column"
	           headerkey="org.nopunc.displayname"
	           sortattr="name">
		<c:out value="<a href=\"/rhn/admin/multiorg/OrgDetails.do?oid=${current.id}\">${current.name}</a>" escapeXml="false" />
		<c:if test="${current.id == 1}">*</c:if>
	</rl:column>
	<rl:column bound="false"
	           sortable="true"
	           headerkey="systems.nopunc.displayname"
	           attr="systems">
		<c:out value="${current.systems}" />
	</rl:column>
	<rl:column bound="false"
	           sortable="true"
	           headerkey="users.nopunc.displayname"
	           styleclass="last-column"
	           attr="users">
		<c:out value="<a href=\"/rhn/admin/multiorg/OrgUsers.do?oid=${current.id}\">${current.users}</a>" escapeXml="false" />
	</rl:column>
   <rl:column bound="false"
              sortable="true"
              headerkey="org.trust.trusts"
              styleclass="last-column"
              attr="users">
      <a href="/rhn/admin/multiorg/OrgTrusts.do?oid=${current.id}">${current.trusts}</a>
   </rl:column>
</rl:list>

</rl:listset>
<span class="small-text">
    *<bean:message key="organizations.tip"/>
</span>
</div>

</body>
</html>

