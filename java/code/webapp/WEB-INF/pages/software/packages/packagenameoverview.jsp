<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-packages.gif" imgAlt="packagesearch.jsp.imgAlt"
               helpUrl="/rhn/help/reference/en-US/s1-sm-channels-packages.jsp#s2-sm-software-search">
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
    <rl:list name="pkgResults" dataset="pageList"
             emptykey="packagesearch.jsp.nopackages" width="100%"
             filter="com.redhat.rhn.frontend.action.channel.PackageNVREAFilter">
      <rl:decorator name="PageSizeDecorator"/>
      <rl:column bound="false" sortable="false" headerkey="packagesearch.jsp.name" styleclass="first-column">
        <a href="/rhn/software/packages/Details.do?pid=${current.package_id}">${current.nvrea}</a>
      </rl:column>
      <rl:column bound="false" sortable="false" headerkey="ssmchildsubs.jsp.channelname" styleclass="last-column">
        ${current.channel_name}
      </rl:column>
    </rl:list>
    <input type="hidden" name="package_name" value="${param.package_name}" />
    <input type="hidden" name="search_subscribed_channels" value="${param.search_subscribed_channels}" />
    <input type="hidden" name="channel_filter" value="${param.channel_filter}" />
    <c:forEach items="${paramValues.channel_arch}" var="item">
    <input type="hidden" name="channel_arch" value="${item}" />
    </c:forEach>

  </rl:listset>
  </body>
</html>
