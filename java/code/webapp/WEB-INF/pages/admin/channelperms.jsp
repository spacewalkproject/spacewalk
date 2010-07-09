<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>

<h2><bean:message key="channelperms.jsp.title" /></h2>

<div class="page-summary">
<p><bean:message key="channelperms.jsp.summary"/></p>

<p>

(<span class="ok-explanation"><img src="/img/rhn-listicon-ok.gif"
        alt="<bean:message key="channelperms.jsp.permGranted.short"/>"
        title="<bean:message key="channelperms.jsp.permGranted.short"/>" /></span>
<bean:message key="channelperms.jsp.permGranted" />)
</p>

<html:form action="/users/ChannelPermsSubmit">
<input type="hidden" name="role" value="${role}" />
<input type="hidden" name="uid" value="${user.id}" />
<input type="hidden" name="formvars" value="uid" />

<%@ include file="/WEB-INF/pages/common/fragments/admin/channelperms_list.jspf" %>

</html:form>
</div>
</body>
</html>

