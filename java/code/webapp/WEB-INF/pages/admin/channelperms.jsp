<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>

<h2><bean:message key="channelperms.jsp.title" /></h2>

<p><bean:message key="channelperms.jsp.summary"/></p>

<p>
(<rhn:icon type="item-enabled" title="channelperms.jsp.permGranted.short" />
<bean:message key="channelperms.jsp.permGranted" />)
</p>

<html:form action="/users/ChannelPermsSubmit">
<rhn:csrf />
<rhn:hidden name="role" value="${role}" />
<rhn:hidden name="uid" value="${user.id}" />
<rhn:hidden name="formvars" value="uid" />

<%@ include file="/WEB-INF/pages/common/fragments/admin/channelperms_list.jspf" %>

</html:form>

</body>
</html>

