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






<rl:listset name="orgList">

<rl:list emptykey="assignedgroups.jsp.nogroups">
        
        
        <rl:decorator name="PageSizeDecorator"/>
                
        <rl:selectablecolumn value="${current.id}"
        	selected="${not empty requestScope.listSelections[current.id]}"
                             styleclass="first-column"/>

        <rl:column sortable="true" 
                           bound="false"
                   headerkey="org.jsp.name" 
                   sortattr="name"
                   defaultsort="asc"  >
						${current.name}
        </rl:column>            
        
        <rl:column sortable="true" 
                           bound="false"
                   styleclass="last-column"
                   headerkey="org.jsp.id" 
                   sortattr="name"
                   defaultsort="asc"  >
						${current.id}
        </rl:column>           


</rl:list>
<div align="right">
   <rhn:submitted/>
    <input type="submit" 
    	name ="dispatch"
	    value='<bean:message key="submit"/>'/>
	    </div>


<input type="hidden" name="uid" value="${uid}" />

</rl:listset>





</body>
</html>