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

<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

 <%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
 
 <br><br>
 <br><br> 
 
 <table class="details">
 	<tr>
	 	<th>
			<a href="/rhn/channels/manage/packages/AddRedHatErrata.do?cid=${cid}">
					<bean:message key="channel.manage.errata.addredhaterrata"/>   </a><Br>
		</th>
		<td> <bean:message key="channel.manage.errata.addredhaterratamsg"/>   </td>
	 </tr>
	 <tr>
	 	<th>
			<a href="/rhn/channels/manage/packages/AddCustomErrata.do?cid=${cid}">
			<bean:message key="channel.manage.errata.addcustomerrata"/></a>
		</th>
		<td><bean:message key="channel.manage.errata.addcustomerratamsg"/>  </td>
  	 </tr>
  	 <tr>
  	 	<th><a href="/rhn/errata/manage/Create.do">
  	 				<bean:message key="channel.manage.errata.createerrata"/></a>
  	 	</th>
  	 	<td><bean:message key="channel.manage.errata.createerratamsg"/></td>
  	 </tr>
 </table>
 
 
</body>
</html>
 