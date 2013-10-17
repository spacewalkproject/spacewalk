<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
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
<rhn:toolbar
   base="h1"
   icon="spacewalk-icon-software-channels"
   imgAlt="channels.overview.toolbar.imgAlt">
  <bean:message key="channel.nav.shared"/>
</rhn:toolbar>

<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_tabs.jspf" %>

<p>
	<bean:message key="channels.shared.jsp.header1" />
</p>

<form method="post" name="rhn_list" action="/rhn/software/channels/Shared.do">
  <rhn:csrf />
  <rhn:submitted />
  <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_tree_multiorg.jspf" %>
</form>

</body>
</html>
