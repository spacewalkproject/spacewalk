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
<rhn:toolbar base="h1" img="/img/rhn-config_namespace-2.gif" imgAlt="config.jsp.imgAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-configuration.jsp#configuration-files-central"
 creationUrl="/rhn/configuration/ChannelCreate.do?editing=true"
 creationType="configchannel"
 creationAcl="user_role(config_admin)">
  <bean:message key="globalconfiglist.jsp.toolbar"/>
</rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="globalconfiglist.jsp.summary"/>
    </p>
  </div>

<form method="post" name="rhn_list" action="/rhn/configuration/GlobalConfigChannelList.do">

  <rhn:list pageList="${requestScope.pageList}" noDataText="globalconfiglist.jsp.noChannels">
    <rhn:listdisplay filterBy="globalconfiglist.jsp.name">
      <rhn:column header="globalconfiglist.jsp.name"
                  url="/rhn/configuration/ChannelOverview.do?ccid=${current.id}">
        <img alt='<bean:message key="config.common.globalAlt" />'
             src="/img/rhn-listicon-channel.gif" />
        ${current.name}
      </rhn:column>

      <rhn:column header="globalconfiglist.jsp.label">
        ${current.label}
      </rhn:column>

      <rhn:column header="globalconfiglist.jsp.files"
                  url="/rhn/configuration/ChannelFiles.do?ccid=${current.id}"
                  renderUrl="${current.fileCount > 0}">
        <c:if test="${current.fileCount == 1}">
          <bean:message key="config.common.onefile" />
        </c:if>
        <c:if test="${current.fileCount != 1}">
          <bean:message key="config.common.numfiles" arg0="${current.fileCount}"/>
        </c:if>
      </rhn:column>

      <rhn:column header="globalconfiglist.jsp.systems"
                  url="/rhn/configuration/channel/ChannelSystems.do?ccid=${current.id}"
                  renderUrl="${current.systemCount > 0}">
        <c:if test="${current.systemCount == 0}">
          <bean:message key="none.message" />
        </c:if>
        <c:if test="${current.systemCount == 1}">
          <bean:message key="system.common.onesystem" />
        </c:if>
        <c:if test="${current.systemCount > 1}">
          <bean:message key="system.common.numsystems" arg0="${current.systemCount}"/>
        </c:if>
      </rhn:column>
    </rhn:listdisplay>
  </rhn:list>

</form>

</body>
</html>
