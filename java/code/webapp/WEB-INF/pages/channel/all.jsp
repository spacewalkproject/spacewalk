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

<body onLoad="onLoadStuff(4); showFiltered();"> 

<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif" imgAlt="channels.overview.toolbar.imgAlt"
             helpUrl="/rhn/help/reference/en/s2-sm-channel-list.jsp#s3-sm-channel-list-all" >
  <bean:message key="channels.all.jsp.toolbar"/>
</rhn:toolbar>

<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_tabs.jspf" %>

<p>
	<bean:message key="channels.all.jsp.header1" />
</p>

<form method="post" name="rhn_list" action="/rhn/software/channels/All.do">
  <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_tree_multiorg.jspf" %>
</form>

</body>
</html>
