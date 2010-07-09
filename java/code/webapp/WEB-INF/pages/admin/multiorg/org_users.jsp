<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html>
<body>
<c:choose>
<c:when test="${param.oid != 1}">
<rhn:toolbar base="h1" img="/img/rhn-icon-org.gif"
 miscUrl="${url}"
 miscAcl="user_role(org_admin)"
 miscText="${text}"
 miscImg="${img}"
 miscAlt="${text}"
 deletionUrl="/rhn/admin/multiorg/DeleteOrg.do?oid=${param.oid}"
 deletionAcl="user_role(satellite_admin)"
 deletionType="org"
 imgAlt="users.jsp.imgAlt">
 <c:out escapeXml="true" value="${orgName}" />
</rhn:toolbar>
</c:when>
<c:otherwise>
<rhn:toolbar base="h1" img="/img/rhn-icon-org.gif"
 miscUrl="${url}"
 miscAcl="user_role(org_admin)"
 miscText="${text}"
 miscImg="${img}"
 miscAlt="${text}"
 imgAlt="users.jsp.imgAlt">
 <c:out escapeXml="true" value="${orgName}" />
</rhn:toolbar>
</c:otherwise>
</c:choose>
<rhn:dialogmenu mindepth="0" maxdepth="2" definition="/WEB-INF/nav/org_tabs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<div class="page-summary" style="padding-top: 10px;">
<p>
   <bean:message key="org.users.summary" arg0="${orgName}" />
</p>
</div>
<c:set var="pageList" value="${requestScope.pageList}" />

<div>
<rl:listset name="orgListSet">
<!-- Start of org list -->
<rl:list dataset="pageList"
         width="100%"
         name="userList"
         styleclass="list"
         filter="com.redhat.rhn.frontend.action.multiorg.UserListFilter"
         emptykey="org.jsp.noUsers">

	<!-- Organization name column -->		
	<rl:column bound="false"
	           sortable="true"
	           styleclass="first-column"
	           headerkey="username.nopunc.displayname"
	           sortattr="login">
	    <c:choose>
	      <c:when test="${canModify == 1}">
<c:out value="<a href=\"/rhn/users/UserDetails.do?uid=${current.id}\">${current.login}</a>" escapeXml="false" />
	      </c:when>
	      <c:otherwise>
	  ${current.login}
	      </c:otherwise>
		</c:choose>
		
	</rl:column>
	<rl:column bound="false"
	           headerkey="multiorg.jsp.email"
			>
		<c:out value="${current.address}" />
	</rl:column>	
	<rl:column bound="false"
	           sortable="false"
	           headerkey="realname.displayname"
	           attr="userLastName">
		<c:out value="${current.userDisplayName}" />
	</rl:column>
	<rl:column bound="false"
	           sortable="false"
	           headerkey="orgadmin.displayname"
	           styleclass="last-column"
	           attr="orgAdmin">
	    <c:choose>
	      <c:when test="${current.orgAdmin == 1}">
	        <img src="/img/rhn-listicon-checked_immutable.gif">
	      </c:when>
	      <c:otherwise>
	        <img src="/img/rhn-listicon-unchecked_immutable.gif">
	      </c:otherwise>
		</c:choose>
		
	</rl:column>
</rl:list>

</rl:listset>

<span class="small-text">
    <bean:message key="satusers.tip"/>
</span>

</div>

</body>
</html>

