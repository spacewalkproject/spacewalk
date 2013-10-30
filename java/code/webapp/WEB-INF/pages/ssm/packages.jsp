<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>

<h2>
    <bean:message key="ssm.package.header"/>
</h2>

<div class="page-summary">
    <p><bean:message key="ssm.package.summary"/></p>
</div>

<ul>
    <li><a href="PackageInstall.do"><bean:message key="ssm.package.install"/></a></li>
    <li><a href="PackageUpgrade.do"><bean:message key="ssm.package.upgrade"/></a></li>
    <li><a href="PackageRemove.do"><bean:message key="ssm.package.remove"/></a></li>
    <li><a href="PackageVerify.do"><bean:message key="ssm.package.verify"/></a></li>
</ul>

</body>
</html>
