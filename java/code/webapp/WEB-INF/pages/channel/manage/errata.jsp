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
     <h2>
      <img src="/img/rhn-icon-errata.gif" alt="erratum" /> <bean:message key="header.jsp.errata"/>
    </h2>

<ul>
	<li> <a href="/rhn/channels/manage/errata/ListRemove.do?cid=${cid}"> <bean:message key="list.jsp.errata.listremove"/></a> </li>
	<li> <a href="/rhn/channels/manage/errata/Add.do?cid=${cid}"> <bean:message key="list.jsp.errata.add"/> </a> </li>
	<rhn:require acl="channel_is_clone()" mixins="com.redhat.rhn.common.security.acl.ChannelAclHandler">
		<li> <a href="/network/software/channels/manage/errata/clone.pxt?cid=${cid}"> <bean:message key="list.jsp.errata.clone"/> </a> </li>
	</rhn:require>
</u>


</body>
</html>



 