<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <i class="fa spacewalk-icon-manage-configuration-files" title="<bean:message key="ssmdiff.jsp.imgAlt" />"></i>
  <bean:message key="difffiles.jsp.header" />
</h2>

  <div class="page-summary">
    <p>
      <bean:message key="difffiles.jsp.summary"
                    arg0="/rhn/systems/details/configuration/Overview.do?sid=${system.id}"
                    arg1="${requestScope.system.name}"/>
      <c:if test="${requestScope.datasize < requestScope.setsize}">
        <br /><bean:message key="difffiles.jsp.note" />
      </c:if>
    </p>
  </div>

<form method="post" name="rhn_list" action="/rhn/systems/ssm/config/DiffFiles.do?sid=${param.sid}">
  <rhn:csrf />
  <rhn:submitted />
  <rhn:list pageList="${requestScope.pageList}"
            noDataText="difffiles.jsp.noFiles">
    <rhn:listdisplay filterBy="difffiles.jsp.filename">
      <rhn:column header="difffiles.jsp.filename">
        <c:choose>
          <c:when test="${current.configFileType == 'file'}">
            <i class="fa fa-file-text-o" title="<bean:message key="config.common.fileAlt" />"></i>
            <c:out value="${current.path}" />
          </c:when>
          <c:when test="${current.configFileType == 'directory'}">
            <i class="fa fa-folder-open-o" title="<bean:message key="config.common.dirAlt" />"></i>
            <c:out value="${current.path}" />
          </c:when>
          <c:otherwise>
            <i class="fa spacewalk-icon-listicon-cfg-symlink" title="<bean:message key="config.common.symlinkAlt" />"></i>
          </c:otherwise>
        </c:choose>
      </rhn:column>

      <rhn:column header="difffiles.jsp.revision"
                  url="/rhn/configuration/file/FileDetails.do?cfid=${current.configFileId}&crid=${current.configRevisionId}">
        <bean:message key="difffiles.jsp.filerev" arg0="${current.configRevision}" />
      </rhn:column>

      <rhn:column header="config.common.configChannel"
                  url="/rhn/configuration/ChannelOverview.do?ccid=${current.configChannelId}">
        <c:if test="${current.configChannelType == 'normal'}">
    	  <i class="fa spacewalk-icon-software-channels" title="<bean:message key="config.common.globalAlt" />"></i>
          ${current.channelNameDisplay}
        </c:if>

        <c:if test="${current.configChannelType == 'local_override'}">
          <i class="fa fa-desktop" title="<bean:message key="config.common.localAlt" />"></i>
          ${current.channelNameDisplay}
        </c:if>

        <%-- There is no sandbox possibility in this list. --%>
      </rhn:column>
    </rhn:listdisplay>
  </rhn:list>
</form>

</body>
</html>
