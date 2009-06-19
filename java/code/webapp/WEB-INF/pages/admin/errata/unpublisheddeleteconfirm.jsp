<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<h2><bean:message key="erratalist.jsp.deleteerrata" /></h2>

<div class="page-summary">
    <p><bean:message key="deleteconfirm.jsp.pagesummary" /></p>
</div>
<c:set var="pageList" value="${requestScope.pageList}" />
<form method="post" name="rhn_list" action="/rhn/errata/manage/UnpublishedDeleteConfirmSubmit.do">
<%@ include file="/WEB-INF/pages/common/fragments/errata/erratadelete.jspf" %>
</form>
</body>
</html>


