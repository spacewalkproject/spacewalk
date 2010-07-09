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

<h2>
  <img src="/img/rhn-icon-packages.gif"
       alt="<bean:message key='errata.common.packageAlt' />" />
  <bean:message key="packagesindex.jsp.header"/>
</h2>

<ul>
  <li>
    <rhn:require acl="not system_feature(ftr_package_remove)">
      <a href="/rhn/systems/details/packages/PackageList.do?sid=${param.sid}">
        <bean:message key="packagesindex.jsp.list"/></a>
    </rhn:require>
    <rhn:require acl="system_feature(ftr_package_remove)">
      <a href="/rhn/systems/details/packages/PackageList.do?sid=${param.sid}">
        <bean:message key="packagesindex.jsp.remove"/></a>
    </rhn:require>
  </li>

  <rhn:require acl="system_feature(ftr_package_verify); client_capable(packges.verify) or client_capable(packages.verify)"
               mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
      <li><a href="/rhn/systems/details/packages/VerifyPackages.do?sid=${param.sid}">
        <bean:message key="packagesindex.jsp.verify"/></a></li>
  </rhn:require>

  <rhn:require acl="system_feature(ftr_package_updates)">
      <li><a href="/rhn/systems/details/packages/UpgradableList.do?sid=${param.sid}">
        <bean:message key="packagesindex.jsp.upgrade"/></a></li>
      <li><a href="/rhn/systems/details/packages/InstallPackages.do?sid=${param.sid}">
        <bean:message key="packagesindex.jsp.install"/></a></li>
  </rhn:require>

  <rhn:require acl="system_feature(ftr_profile_compare)">
      <li><a href="/rhn/systems/details/packages/profiles/ShowProfiles.do?sid=${param.sid}">
        <bean:message key="packagesindex.jsp.profiles"/></a></li>
  </rhn:require>

</ul>

<rhn:require acl="system_feature(ftr_package_refresh)">
  <form method="POST" name="rhn_list" action="/rhn/systems/details/packages/Packages.do?sid=${param.sid}">
    <div align="right">
      <hr />
      <html:submit property="dispatch">
        <bean:message key="packagesindex.jsp.update"/>
      </html:submit>
    </div>
  </form>
</rhn:require>
</body>
</html>
