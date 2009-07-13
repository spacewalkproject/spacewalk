<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include
	file="/WEB-INF/pages/common/fragments/configuration/channel/details-header.jspf"%>

<div class="uploadfragment">
<!-- Upload file to channel  -->
<h2><bean:message key="addfiles.jsp.upload-link" /> </h2>
<html:form
	action="/configuration/ChannelUploadFiles.do?ccid=${ccid}"
	enctype="multipart/form-data">
  <%@ include file="/WEB-INF/pages/common/fragments/configuration/channel/upload.jspf" %>
</html:form>
</div>

</body>
</html>

