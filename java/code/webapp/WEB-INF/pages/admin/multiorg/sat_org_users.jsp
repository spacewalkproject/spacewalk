<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
<body>
<rhn:toolbar base="h1" icon="header-organisation"
 miscUrl="${url}"
 miscAcl="user_role(org_admin)"
 miscText="${text}"
 miscImg="${img}"
 miscAlt="${text}"
 imgAlt="users.jsp.imgAlt">
 <bean:message key="org.allusers.title" />
</rhn:toolbar>

<div class="page-summary">
<p>
   <bean:message key="org.allusers.summary" arg0="${orgName}" />
</p>
</div>
<c:set var="pageList" value="${requestScope.pageList}" />

<div>
<rl:listset name="orgListSet">
<rhn:csrf />
<rhn:submitted />
<!-- Start of org list -->
<rl:list dataset="pageList"
         width="100%"
         name="userList"
         styleclass="list"
         filter="com.redhat.rhn.frontend.action.multiorg.UserListFilter"
         emptykey="org.jsp.noUsers">

	<!-- Username column -->
	<rl:column bound="false"
	           sortable="true"
	           headerkey="username.nopunc.displayname"
	           sortattr="login">
	    <c:choose>
	      <c:when test="${(userOrgId == current.orgId) and (canModify == 1)}">
		    <c:out value="<a href=\"/rhn/users/UserDetails.do?uid=${current.id}\">${current.login}</a>" escapeXml="false" />
		  </c:when>
	      <c:otherwise>
	        <c:out value="${current.login}" />
	      </c:otherwise>
		</c:choose>
	</rl:column>
	<rl:column bound="false"
	           sortable="false"
	           headerkey="realname.displayname"
	           attr="userLastName">
		<c:out value="<a href=\"mailto:${current.address}\">${current.userLastName}, ${current.userFirstName}</a>" escapeXml="false"/>
	</rl:column>
	<rl:column bound="false"
	           sortable="false"
	           headerkey="org.displayname"
	           attr="orgName">
		<c:out value="${current.orgName}" />
	</rl:column>
	<rl:column bound="false"
	           sortable="false"
	           headerkey="orgadmin.displayname"
	           attr="orgAdmin">
	    <c:choose>
	      <c:when test="${current.orgAdmin == 1}">
	        <rhn:icon type="item-enabled" />
	      </c:when>
	      <c:otherwise>
                <rhn:icon type="item-disabled" />
	      </c:otherwise>
		</c:choose>
	</rl:column>
		<rl:column bound="false"
	           sortable="false"
	           headerkey="satadmin.displayname"
	           attr="orgAdmin">
	    <c:choose>
	      <c:when test="${current.satAdmin == 1}">
	        <a href="/rhn/admin/multiorg/ToggleSatAdmin.do?uid=${current.id}">
	        <rhn:icon type="item-enabled" />
	        </a>
	      </c:when>
	      <c:otherwise>
	        <a href="/rhn/admin/multiorg/ToggleSatAdmin.do?uid=${current.id}">
	        <rhn:icon type="item-disabled" />
	        </a>
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

