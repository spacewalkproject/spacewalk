<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>

<head>
<script src="/javascript/channel_tree.js" type="text/javascript"></script>
</head>

<body onLoad="onLoadStuff(3); showAllRows();">
<rhn:toolbar base="h1" icon="spacewalk-icon-software-channels" imgAlt="channels.jsp.alt">
	${requestScope.familyName}
</rhn:toolbar>

<p>
	<bean:message key="entitlements.tree.description1" arg0="${requestScope.familyName}" />
</p>

<p>
	<bean:message key="entitlements.tree.description2" />
</p>

<form method="post" name="rhn_list" action="/rhn/software/channels/ChannelFamilyTree.do">
    <rhn:csrf />
    <rhn:submitted />
	<input type="hidden" name="cfid" value="${cfid}">
	<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_tree.jspf" %>
</form>

</body>
</html>
