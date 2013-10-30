<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" icon="spacewalk-icon-system-groups" imgAlt="system.common.groupAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-system-group-list"
 creationUrl="/rhn/groups/CreateGroup.do"
 creationType="group"
 creationAcl="user_role(system_group_admin)">
  <bean:message key="grouplist.jsp.header"/>
</rhn:toolbar>

<rl:listset name="groupSet" legend="system-group">
  <rhn:csrf />
  <rhn:submitted />
  <%@ include file="/WEB-INF/pages/common/fragments/systems/group_listdisplay.jspf" %>
</rl:listset>

</body>
</html>
