<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="name" value="System Details" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><img src="/img/rhn-icon-packages.gif" /><bean:message key="upgrade.jsp.header"/></h2>

<rhn:systemtimemessage server="${system}" />

<form method="POST" name="rhn_list" action="/rhn/systems/details/packages/UpgradeConfirmSubmit.do?sid=${param.sid}">
<rhn:list pageList="${requestScope.pageList}" noDataText="upgrade.jsp.none">
  <rhn:listdisplay button="upgrade.jsp.remote" button2="upgrade.jsp.confirm"
                   buttonAcl="system_feature(ftr_remote_command);client_capable(script.run)"
                   mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
    <rhn:column header="upgrade.jsp.package"
                url="/network/software/packages/details.pxt?pid=${current.id}">
      ${current.nvre}
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>
</form>
</body>
</html>