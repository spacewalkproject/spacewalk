<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <img src="/img/rhn-config_files.gif" alt='<bean:message key="ssmdiff.jsp.imgAlt" />' />
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
  <rhn:list pageList="${requestScope.pageList}"
            noDataText="difffiles.jsp.noFiles">
    <rhn:listdisplay filterBy="difffiles.jsp.filename">
      <rhn:column header="difffiles.jsp.filename">
        <c:choose>
          <c:when test="${current.configFileType == 'file'}">
            <img alt='<bean:message key="config.common.fileAlt" />'
                 src="/img/rhn-listicon-cfg_file.gif" />
            <c:out value="${current.path}" />
          </c:when>
          <c:when test="${current.configFileType == 'directory'}">
            <img alt='<bean:message key="config.common.dirAlt" />'
                 src="/img/rhn-listicon-cfg_folder.gif" />
            <c:out value="${current.path}" />
          </c:when>
          <c:otherwise>
            <img alt='<bean:message key="config.common.symlinkAlt" />'
                 src="/img/rhn-listicon-cfg_symlink.gif" />
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
    	  <img alt='<bean:message key="config.common.globalAlt" />'
    	       src="/img/rhn-listicon-channel.gif" />
          ${current.channelNameDisplay}
        </c:if>

        <c:if test="${current.configChannelType == 'local_override'}">
          <img alt='<bean:message key="config.common.localAlt" />'
               src="/img/rhn-listicon-system.gif" />
          ${current.channelNameDisplay}
        </c:if>

        <%-- There is no sandbox possibility in this list. --%>
      </rhn:column>
    </rhn:listdisplay>
  </rhn:list>
</form>

</body>
</html>
