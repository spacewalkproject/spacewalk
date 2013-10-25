<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
     <h2>
      <img src="/img/rhn-icon-errata.gif" alt="erratum" /> <bean:message key="header.jsp.errata.add"/>
    </h2>

 <table class="table">


 	<tr>
	 	<th>
			<a href="/rhn/channels/manage/errata/AddRedHatErrata.do?cid=${cid}">
					<bean:message key="channel.manage.errata.addredhaterrata"/>   </a><Br>
		</th>
		<td> <bean:message key="channel.manage.errata.addredhaterratamsg"/>   </td>
	 </tr>
	 <tr>
	 	<th>
			<a href="/rhn/channels/manage/errata/AddCustomErrata.do?cid=${cid}">
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
