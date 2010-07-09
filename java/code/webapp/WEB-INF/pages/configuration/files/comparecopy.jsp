<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/header.jspf" %>
<h2><bean:message key="comparecopy.jsp.header"/></h2>

<div class="page-summary">
  <p>
    <bean:message key="comparecopy.jsp.summary"
                  arg0="/rhn/configuration/file/FileDetails.do?cfid=${file.id}&amp;crid=${revision.id}"
                  arg1="${revision.revision}"/>
  </p>
</div>

<form method="post" name="rhn_list" action="/rhn/configuration/file/CompareCopy.do?cfid=${file.id}&amp;crid=${revision.id}">
<rhn:list pageList="${requestScope.pageList}" noDataText="comparecopy.jsp.noAlternates">
  <rhn:listdisplay filterBy="comparecopy.jsp.channel">
    <rhn:column header="comparecopy.jsp.channel">
      <cfg:channel id="${current.id}" name="${current.name}" type="${current.type}" />
    </rhn:column>

    <rhn:column header="comparecopy.jsp.type">
        ${current.typeDisplay}
    </rhn:column>

    <rhn:column header="comparecopy.jsp.revision"
                url="/rhn/configuration/file/FileDetails.do?cfid=${current.configFileId}&amp;crid=${current.configRevisionId}">
        <c:choose>
          <c:when test="${current.configFileType == 'file'}">
            <img alt='<bean:message key="config.common.fileAlt" />'
                 src="/img/rhn-listicon-cfg_file.gif" />
          </c:when>
          <c:when test="${current.configFileType == 'directory'}">
            <img alt='<bean:message key="config.common.dirAlt" />'
                 src="/img/rhn-listicon-cfg_folder.gif" />
          </c:when>
          <c:otherwise>
            <img alt='<bean:message key="config.common.symlinkAlt" />'
                 src="/img/rhn-listicon-cfg_symlink.gif" />
          </c:otherwise>
        </c:choose>
        <bean:message key="comparecopy.jsp.revnum" arg0="${current.configRevision}" />
    </rhn:column>

    <rhn:column header="comparerevision.jsp.comparison">
        <a class="link-button" href="/rhn/configuration/file/Diff.do?cfid=${file.id}&amp;crid=${revision.id}&amp;ocrid=${current.configRevisionId}">
            <bean:message key="comparerevision.jsp.compare" />
        </a>
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>
</form>


</body>
</html>

