<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-users.gif" imgAlt="users.jsp.imgAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-users.jsp#s2-sm-user-active"
 creationUrl="/rhn/users/CreateUser.do?account_type=into_org" 
 creationType="user">
  <bean:message key="activelist.jsp.title"/>
</rhn:toolbar>
<c:set var="pageList" value="${requestScope.pageList}" />

<rl:listset name="userListSet">

	
<!-- Start of active users list -->
<rl:list dataset="pageList"
         width="100%"        
         name="userList"
         styleclass="list"
         emptykey="activelist.jsp.noUsers"
 		 alphabarcolumn="userLogin">
        
	<!-- User name column -->
	<rl:column bound="false" 
	           sortable="true" 
	           headerkey="username.nopunc.displayname" 
	           styleclass="first-column"
	           attr="userLogin"
	           filterattr="login">
		<c:out value="<a href=\"/rhn/users/UserDetails.do?uid=${current.id}\">${current.userLogin}</a>" escapeXml="false" />
	</rl:column>
	
	<!-- Real name column -->
	<rl:column bound="false" 
	           sortable="true" 
	           headerkey="realname.displayname" 
	           sortattr="userLastName">
		<c:out value="${current.userLastName}, ${current.userFirstName}" />
	</rl:column>
	
	<!--  Roles column -->
	<rl:column attr="roleNames" 
	           bound="true" 
	           sortable="true" 
	           headerkey="userdetails.jsp.roles" 
	            />
	           
	<!-- Last logged in column -->
	<rl:column attr="lastLoggedIn" 
			   sortattr="lastLoggedInDate"
	           bound="true" 
	           sortable="true" 
	           headerkey="userdetails.jsp.lastsign" 
	           styleclass="last-column" />
	           
</rl:list>
<rl:csv dataset="pageList"
	name="userList" 
	exportColumns="userLogin,userLastName,userFirstName,roleNames,lastLoggedIn"/>
</rl:listset>
</body>
</html>
