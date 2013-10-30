<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>

<h2><bean:message key="channelManagementPerms.title" /></h2>

<p><bean:message key="channelManagementPerms.summary" /></p>

<p>
(<span class="ok-explanation"><i class="icon-ok" title="Permission granted"></i></span>
<bean:message key="channelManagementPerms.granted" />)
</p>

<html:form action="/users/ChannelPermsSubmit">
<rhn:csrf />
<input type="hidden" name="role" value="${role}" />
<input type="hidden" name="uid" value="${user.id}" />
<input type="hidden" name="formvars" value="uid" />

<%@ include file="/WEB-INF/pages/common/fragments/admin/channelperms_list.jspf" %>

</html:form>

</body>
</html>
