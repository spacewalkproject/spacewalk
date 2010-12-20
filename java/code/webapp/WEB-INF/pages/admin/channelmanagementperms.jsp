<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>

<h2><bean:message key="channelManagementPerms.title" /></h2>

<div class="page-summary">
<p><bean:message key="channelManagementPerms.summary" /></p>

<p>
(<span class="ok-explanation"><img src="/img/rhn-listicon-ok.gif" alt="Permission granted" title="Permission granted" /></span>
<bean:message key="channelManagementPerms.granted" />)
</p>

</div>

<html:form action="/users/ChannelPermsSubmit">
<input type="hidden" name="role" value="${role}" />
<input type="hidden" name="uid" value="${user.id}" />
<input type="hidden" name="formvars" value="uid" />

<%@ include file="/WEB-INF/pages/common/fragments/admin/channelperms_list.jspf" %>

</html:form>

</body>
</html>
