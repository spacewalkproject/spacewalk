<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>


<html>
<head>
</head>

<body>

<rhn:toolbar base="h1" icon="header-system" imgAlt="audit.jsp.alt">
  <bean:message key="system.audit.listscap.jsp.overview"/>
</rhn:toolbar>

<rl:listset name="groupSet">
  <rhn:csrf />
  <rhn:submitted />
  <rl:list emptykey="audit.listxccdf.jsp.noscans">
    <%@ include file="/WEB-INF/pages/common/fragments/audit/xccdf-easy-list.jspf" %>
  </rl:list>
  <rl:csv name="groupSet"
    exportColumns="id,sid,serverName,profile,completed,satisfied,dissatisfied,satisfactionUnknown"/>
  <rhn:tooltip key="audit.listxccdf.jsp.tooltip"/>
</rl:listset>

</body>
</html>
