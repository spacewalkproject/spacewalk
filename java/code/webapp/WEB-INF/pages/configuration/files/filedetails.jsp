<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://struts.apache.org/tags-bean"
	prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html"
	prefix="html"%>


<html>
<head>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/header.jspf"%>

<html:form action="/configuration/file/FileDetails.do?cfid=${file.id}&amp;crid=${revision.id}">
    <rhn:csrf />
	<html:hidden property="submitted" value="true"/>

	<div class="details-column-left">
	  <%@ include file="/WEB-INF/pages/common/fragments/configuration/files/details.jspf"%>
	</div>

	<div class="details-column-right">
	  <%@ include file="/WEB-INF/pages/common/fragments/configuration/files/properties.jspf"%>
	</div>

	<c:if test="${revision.file}">
	  <div class="details-full">
	    <%@ include file="/WEB-INF/pages/common/fragments/configuration/files/add_details.jspf"%>
	  </div>

	  <div class="details-full">
	    <%@ include file="/WEB-INF/pages/common/fragments/configuration/files/contents.jspf"%>
	  </div>
	</c:if>

	<rhn:require acl="config_channel_editable()"
             mixins="com.redhat.rhn.common.security.acl.ConfigAclHandler">
      <div class="submit-bar">
	    <hr />
		<div class="text-right">
          <html:submit styleClass="btn btn-default"><bean:message key="filedetails.jsp.update" /></html:submit>
		</div>
      </div>
	</rhn:require>
</html:form>

<rhn:require acl="is_file();config_channel_editable()"
             mixins="com.redhat.rhn.common.security.acl.ConfigAclHandler">
	<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/upload.jspf" %>
</rhn:require>
</body>
</html>
