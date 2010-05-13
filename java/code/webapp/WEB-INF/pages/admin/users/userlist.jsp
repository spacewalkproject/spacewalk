<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-users.gif" imgAlt="users.jsp.imgAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-users.jsp#s2-sm-users-all"
 creationUrl="/rhn/users/CreateUser.do?account_type=into_org" 
 creationType="user">
  <bean:message key="userlist.jsp.useroverview"/>
</rhn:toolbar>

<c:set var="pageList" value="${requestScope.pageList}" />

<rl:listset name="userListSet">
	<rl:list
         width="100%"        
         name="userList"
         styleclass="list"
         filter="com.redhat.rhn.frontend.action.multiorg.UserListFilter"
         emptykey="activelist.jsp.noUsers"
 		 alphabarcolumn="userLogin">
 		


		<rl:column bound="false" 
			sortable="true" 
			headerkey="username.nopunc.displayname" 
			sortattr="userLogin"
			styleclass="first-column">
			<c:out value="<a href=\"UserDetails.do?uid=${current.id}\">${current.userLogin}</a>" escapeXml="false" />
		</rl:column> 		
 		
 		
 		<%@ include file="/WEB-INF/pages/common/fragments/user/userlist_columns.jspf" %>

		<rl:column sortable="false" 
	           headerkey="userlist.jsp.status"
	           styleclass="last-column">
	   		<c:if test="${current.status == 'enabled'}">
        		<bean:message key="userlist.jsp.${current.status}"/>
      		</c:if>
      		<c:if test="${current.status == 'disabled'}">
          		<bean:message key="userlist.jsp.${current.status}"/>
      		</c:if>
	    </rl:column>
	            
 	</rl:list>
 	<rl:csv dataset="pageList"
		name="userList" 
		exportColumns="userLogin,userLastName,userFirstName,roleNames,lastLoggedIn,status"/>
</rl:listset>

</body>
</html>
