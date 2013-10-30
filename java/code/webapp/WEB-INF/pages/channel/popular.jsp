<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
<rhn:toolbar base="h1" icon="spacewalk-icon-software-channels">
  <bean:message key="channel.nav.popular"/>
</rhn:toolbar>

<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_tabs.jspf" %>

<p>
<bean:message key="channels.popular.jsp.header1" />
</p>

<form method="post" name="rhn_list" action="/rhn/software/channels/Popular.do">
        <rhn:csrf />
        <rhn:submitted />
    	<table class="table">
    		<th>
    			<bean:message key="channels.popular.jsp.label0" />:
    		</th>
    		<td>
			<bean:message key="channels.popular.jsp.label1" />
			<select name="server_count" >
		         <c:forEach var="parameter" items="${counts}">
					<option value="<c:out value='${parameter.count}' />"
						<c:if test="${parameter.selected}">
							selected
						</c:if>
					>
						<c:out value='${parameter.count}' />
					</option>
		         </c:forEach>
			</select>
			<bean:message key="channels.popular.jsp.label2" />
			<INPUT type="submit" class="btn btn-default" value="<bean:message key="channels.popular.jsp.button" />">
			</td>
		</table>
		<br/>
	<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_tree_multiorg.jspf" %>
</form>

</body>
</html>
