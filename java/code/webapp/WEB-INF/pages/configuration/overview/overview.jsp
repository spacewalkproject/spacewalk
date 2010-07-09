<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<rhn:toolbar base="h1" img="/img/rhn-config_management.gif" imgAlt="config.jsp.imgAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-configuration.jsp#configuration-overview" >
  <bean:message key="configoverview.jsp.toolbar"/>
</rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="configoverview.jsp.summary"/>
    </p>
  </div>

  <!-- TODO: fix these first two tables when the new list constructs come out. -->

  <!-- simple summary table -->
  <div class="half-table half-table-left">
    <%@ include file="/WEB-INF/pages/common/fragments/configuration/overview/summary.jspf" %>
  </div>

  <!-- simple link table -->
  <div class="half-table half-table-right">
    <%@ include file="/WEB-INF/pages/common/fragments/configuration/overview/links.jspf" %>
  </div>

  <div style="clear: both; padding-top: 10px;" />

  <h2><bean:message key="configoverview.jsp.modconfig"/></h2>

  <rhn:list pageList="${requestScope.recentFiles}" noDataText="configoverview.jsp.noFiles">
    <rhn:listdisplay>
      <rhn:column header="configoverview.jsp.filename"
                  url="/rhn/configuration/file/FileDetails.do?cfid=${current.id}">
        <c:choose>
          <c:when test="${current.type == 'file'}">
            <img alt='<bean:message key="config.common.fileAlt" />'
                 src="/img/rhn-listicon-cfg_file.gif" />
            ${fn:escapeXml(current.path)}
          </c:when>
          <c:when test="${current.type == 'directory'}">
            <img alt='<bean:message key="config.common.dirAlt" />'
                 src="/img/rhn-listicon-cfg_folder.gif" />
            ${fn:escapeXml(current.path)}
          </c:when>
          <c:otherwise>
            <img alt='<bean:message key="config.common.symlinkAlt" />'
                 src="/img/rhn-listicon-cfg_symlink.gif" />
            ${fn:escapeXml(current.path)}
          </c:otherwise>
        </c:choose>
      </rhn:column>

      <rhn:column header="config.common.configChannel"
                  url="/rhn/configuration/ChannelOverview.do?ccid=${current.configChannelId}">

        <c:if test="${current.configChannelType == 'normal'}">
    	  <img alt='<bean:message key="config.common.globalAlt" />'
    	       src="/img/rhn-listicon-channel.gif" />
          ${current.channelNameDisplay}
        </c:if>

        <c:if test="${current.configChannelType == 'local_override'}">
          <img alt='<bean:message key="config.common.localAlt" />'
               src="/img/rhn-listicon-system.gif" />
          ${current.channelNameDisplay}
        </c:if>

        <c:if test="${current.configChannelType == 'server_import'}">
          <img alt='<bean:message key="config.common.sandboxAlt" />'
               src="/img/rhn-listicon-sandbox.gif" />
          ${current.channelNameDisplay}
        </c:if>

      </rhn:column>

      <rhn:column header="configoverview.jsp.modified">
        ${current.modifiedDisplay}
      </rhn:column>

    </rhn:listdisplay>
  </rhn:list>

  <h2><bean:message key="configoverview.jsp.schedconfig"/></h2>

  <rhn:list pageList="${requestScope.recentActions}" noDataText="configoverview.jsp.noActions">
    <rhn:listdisplay>
      <rhn:column header="configoverview.jsp.system"
                  url="/rhn/systems/details/configuration/Overview.do?sid=${current.serverId}">
        <img alt='<bean:message key="system.common.systemAlt" />'
             src="/img/rhn-listicon-system.gif" />
        ${fn:escapeXml(current.serverName)}
      </rhn:column>

      <rhn:column header="configoverview.jsp.files">
        <c:if test="${current.fileCount == 1}">
          <bean:message key="config.common.onefile" />
        </c:if>
        <c:if test="${current.fileCount != 1}">
          <bean:message key="config.common.numfiles" arg0="${current.fileCount}"/>
        </c:if>
      </rhn:column>

      <rhn:column header="configoverview.jsp.scheduledBy"
                  url="/rhn/users/UserDetails.do?uid=${current.scheduledById}"
                  renderUrl="${requestScope.is_admin}">
        <img alt='<bean:message key="user.common.userAlt" />'
             src="/img/rhn-listicon-user.gif" />
        ${fn:escapeXml(current.scheduledByName)}
      </rhn:column>

      <rhn:column header="configoverview.jsp.scheduledFor">
        ${current.earliestDisplay}
      </rhn:column>

      <rhn:column header="configoverview.jsp.status"
                  url="/rhn/schedule/ActionDetails.do?aid=${current.id}">
        ${current.status}
      </rhn:column>

    </rhn:listdisplay>
  </rhn:list>

</body>
</html>
