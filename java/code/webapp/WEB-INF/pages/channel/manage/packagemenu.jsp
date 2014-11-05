<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>

    <h2>
      <rhn:icon type="header-package" title="package.jsp.alt" /> <bean:message key="package.jsp.menu.packages" />
    </h2>

    <ul>
      <li>
        <a href="/rhn/channels/manage/ChannelPackages.do?cid=${channel.id}">
	  <bean:message key="channel.jsp.package.menu.list"/>
	</a>
      </li>

      <li>
        <a href="/rhn/channels/manage/ChannelPackagesAdd.do?cid=${channel.id}">
          <bean:message key="channel.jsp.package.menu.add"/>
        </a>
      </li>

      <li>
        <a href="/rhn/channels/manage/ChannelPackagesCompare.do?cid=${channel.id}">
	  <bean:message key="channel.jsp.package.menu.compare"/>
	</a>
      </li>

    </ul>


</body>
</html>
