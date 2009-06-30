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
        <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<c:set var="noUpdates" value="true"/>
<c:set var="notSelectable" value="true"/>
<c:set var="noMonitoring" value="true"/>
<c:set var="noErrata" value="true"/>
<c:set var="noPackages" value="true"/>

<rl:listset name="systemListSet" legend="system">
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
</rl:listset>
</body>
</html>