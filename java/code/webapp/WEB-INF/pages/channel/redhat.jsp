<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html:xhtml/>
<html>

<head>
<script src="/javascript/channel_tree.js" type="text/javascript"></script>
<script type="text/javascript">
var filtered = ${requestScope.isFiltered};
function showFiltered() {
  if (filtered)
    ShowAll();
}
</script>
</head>

<body onLoad="onLoadStuff(3); showFiltered();"> 



<html:errors/>
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-software.gif" imgAlt="channels.overview.toolbar.imgAlt">
  <bean:message key="channel.nav.redhat"/>
</rhn:toolbar>

<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_tabs.jspf" %>

<p>
<bean:message key="channels.redhat.jsp.header1" />
</p>


<form method="post" name="rhn_list" action="/rhn/software/channels/RedHat.do">
	<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_tree.jspf" %>
</form>

</body>
</html>
