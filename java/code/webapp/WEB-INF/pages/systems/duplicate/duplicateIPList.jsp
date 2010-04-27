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
<rhn:toolbar base="h1" img="/img/rhn-icon-system.gif" imgAlt="system.common.systemAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s3-sm-system-list-ood">
  <bean:message key="duplicate-ip.jsp.header"/>
</rhn:toolbar>
<p>
<bean:message key="duplicate-ip.jsp.message"/>
</p>
<rl:listset name="DupesListSet" legend="system">
<rl:list 
	emptykey="nosystems.message"
	>
	<!-- Name Column -->
	<rl:column bound="true"
				attr="key"
	           headerkey="systemlist.jsp.system" 
	           styleclass="first-column last-column"/>

</rl:list>

<rl:csv exportColumns="key"/>

<rhn:submitted/>

</rl:listset>

</body>
</html>
