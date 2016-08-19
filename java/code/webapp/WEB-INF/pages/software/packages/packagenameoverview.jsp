<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<body>
<rhn:toolbar base="h1" icon="header-package" imgAlt="packagesearch.jsp.imgAlt"
               helpUrl="">
    <bean:message key="packagesbyname.jsp.toolbar"/>
  </rhn:toolbar>

  <p><bean:message key="packagesbyname.jsp.introparagraph"/></p>

  <hr />
  <c:set var="pageList" value="${requestScope.pageList}" />
  <!-- collapse the params into a string -->
  <c:forEach items="${requestScope.channel_arch}" var="item">
    <c:set var="archparams" value="${archparams}&channel_arch=${item}"/>
  </c:forEach>
  <rl:listset name="nameoverview">
    <rhn:csrf />
    <rl:list name="pkgResults" dataset="pageList"
             emptykey="packagesearch.jsp.nopackages" width="100%"
             filter="com.redhat.rhn.frontend.action.channel.PackageNVREAFilter">
      <rl:decorator name="PageSizeDecorator"/>
      <rl:column bound="false" sortable="false" headerkey="packagesearch.jsp.name">
        <a href="/rhn/software/packages/Details.do?pid=${current.package_id}">${current.nvrea}</a>
      </rl:column>
      <rl:column bound="false" sortable="false" headerkey="ssmchildsubs.jsp.channelname">
        ${current.channel_name}
      </rl:column>
    </rl:list>
    <rhn:hidden name="package_name" value="${param.package_name}" />
    <rhn:hidden name="search_subscribed_channels" value="${param.search_subscribed_channels}" />
    <rhn:hidden name="channel_filter" value="${param.channel_filter}" />
    <c:forEach items="${paramValues.channel_arch}" var="item">
    <rhn:hidden name="channel_arch" value="${item}" />
    </c:forEach>

  </rl:listset>
  </body>
</html>
