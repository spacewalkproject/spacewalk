<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="name" value="Users" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-users.gif"
 helpUrl="/rhn/help/reference/en-US/s1-sm-users.jsp">
  <bean:message key="userconfirm.jsp.header" />
</rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="userconfirm.jsp.summary" />
    </p>
  </div>

<c:set var="pageList" value="${requestScope.pageList}" />

<rl:listset name="userConfirmListSet">
	<rl:list dataset="pageList"
         width="100%"
         name="userConfirmList"
         styleclass="list"
 		 alphabarcolumn="userLogin">
		<rl:decorator name="PageSizeDecorator"/>
		<%@ include file="/WEB-INF/pages/common/fragments/user/userlist_columns.jspf" %>

 	</rl:list>
 	
 	<rl:csv dataset="pageList"
		name="userConfirmList"
		exportColumns="userLogin,userLastName,userFirstName,roleNames,lastLoggedIn"/>
		
	<div align="right">
    	<hr />
    	<input type="submit" name="dispatch" value="<bean:message key="userconfirm.jsp.confirm" />" />
	</div>
	
</rl:listset>

</body>
</html>
