<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include
	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<h2><bean:message key="addfiles.jsp.header2"/></h2>
<a href="#upload"><bean:message key="addfiles.jsp.upload-link"/></a><br/>
<a href="#import"><bean:message key="addfiles.jsp.import-link"/></a><br/>
<a href="#create"><bean:message key="addfiles.jsp.create-link"/></a><br/>

<div class="uploadfragment">
<a name="upload"/>
<%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/upload.jspf" %>
</div>
<p />

<div class="importfragment">
<a name="import"/>
<%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/import.jspf" %>
</div>
<p />

<div class="createfragment">
<a name="create"/>
<%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/create.jspf" %>
</div>

</body>
</html>

