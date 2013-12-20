<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<rhn:toolbar base="h1" icon="header-configuration" imgAlt="config.jsp.imgAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-configuration.jsp#configuration-overview" >
  <bean:message key="configoverview.jsp.toolbar"/>
</rhn:toolbar>

    <p>
    <bean:message key="configoverview.jsp.summary"/>
    </p>

  <!-- TODO: fix these first two tables when the new list constructs come out. -->

  <!-- simple summary table -->
  <div class="row-0">
    <div class="col-md-6">
      <div class="panel panel-default">
        <%@ include file="/WEB-INF/pages/common/fragments/configuration/overview/summary.jspf" %>
      </div>
    </div>

    <!-- simple link table -->
    <div class="col-md-6">
      <div class="panel panel-default">
        <%@ include file="/WEB-INF/pages/common/fragments/configuration/overview/links.jspf" %>
      </div>
    </div>
  </div>

  <div class="panel panel-default">
    <div class="panel-heading">
      <h4><bean:message key="configoverview.jsp.modconfig"/></h4>
    </div>
    <div class="panel-body">

      <rhn:list pageList="${requestScope.recentFiles}" noDataText="configoverview.jsp.noFiles">
        <rhn:listdisplay>
          <rhn:column header="configoverview.jsp.filename"
                      url="/rhn/configuration/file/FileDetails.do?cfid=${current.id}">
            <c:choose>
              <c:when test="${current.type == 'file'}">
                <rhn:icon type="header-file" />
                ${fn:escapeXml(current.path)}
              </c:when>
              <c:when test="${current.type == 'directory'}">
                <rhn:icon type="header-folder" />
                ${fn:escapeXml(current.path)}
              </c:when>
              <c:otherwise>
                <rhn:icon type="header-symlink" />
                ${fn:escapeXml(current.path)}
              </c:otherwise>
            </c:choose>
          </rhn:column>

          <rhn:column header="config.common.configChannel"
                      url="/rhn/configuration/ChannelOverview.do?ccid=${current.configChannelId}">

            <c:if test="${current.configChannelType == 'normal'}">
              <rhn:icon type="header-channel" />
              ${current.channelNameDisplay}
            </c:if>

            <c:if test="${current.configChannelType == 'local_override'}">
              <rhn:icon type="header-system" />
              ${current.channelNameDisplay}
            </c:if>

            <c:if test="${current.configChannelType == 'server_import'}">
              <rhn:icon type="header-sandbox" />
              ${current.channelNameDisplay}
            </c:if>

          </rhn:column>

          <rhn:column header="configoverview.jsp.modified">
            ${current.modifiedDisplay}
          </rhn:column>

        </rhn:listdisplay>
      </rhn:list>
    </div>
  </div>

  <div class="panel panel-default">
    <div class="panel-heading">
      <h4><bean:message key="configoverview.jsp.schedconfig"/></h4>
    </div>
    <div class="panel-body">
      <rhn:list pageList="${requestScope.recentActions}" noDataText="configoverview.jsp.noActions">
        <rhn:listdisplay>
          <rhn:column header="configoverview.jsp.system"
                      url="/rhn/systems/details/configuration/Overview.do?sid=${current.serverId}">
            <rhn:icon type="header-system-physical" />
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
            <rhn:icon type="header-user" title="user.common.userAlt" />
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
    </div>
  </div>

</body>
</html>
