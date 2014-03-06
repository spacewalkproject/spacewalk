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

        <div class="row-0">
            <div class="col-md-auto details-column-left">
              <%@ include file="/WEB-INF/pages/common/fragments/configuration/files/details.jspf"%>
            </div>

            <div class="col-md-auto details-column-right">
              <%@ include file="/WEB-INF/pages/common/fragments/configuration/files/properties.jspf"%>
            </div>
        </div>
	<c:if test="${revision.file}">
	  <div class="row-0">
              <div class="col-md-12">
                <%@ include file="/WEB-INF/pages/common/fragments/configuration/files/add_details.jspf"%>
              </div>
	  </div>

	  <div class="row-0">
              <div class="col-md-12">
                <%@ include file="/WEB-INF/pages/common/fragments/configuration/files/contents.jspf"%>
              </div>
	  </div>
	</c:if>

	<rhn:require acl="config_channel_editable()"
             mixins="com.redhat.rhn.common.security.acl.ConfigAclHandler">
        <div class="text-right">
            <html:submit styleClass="btn btn-primary"><bean:message key="filedetails.jsp.update" /></html:submit>
        </div>
	</rhn:require>
</html:form>
<hr/>
<rhn:require acl="is_file();config_channel_editable()"
             mixins="com.redhat.rhn.common.security.acl.ConfigAclHandler">
	<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/upload.jspf" %>
</rhn:require>
</body>
</html>
