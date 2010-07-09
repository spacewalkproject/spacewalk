<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/header.jspf" %>
<h2><bean:message key="copysandbox.jsp.header"/></h2>

<div class="page-summary">
  <p>
    <bean:message key="copysandbox.jsp.summary" arg0="/rhn/configuration/file/FileDetails.do?cfid=${file.id}&amp;crid=${revision.id}" arg1="${revision.revision}"/>
    <br />
    <bean:message key="copycentral.jsp.select" />
  </p>
</div>

<form method="post" name="rhn_list" action="/rhn/configuration/file/CopyFileSandboxSubmit.do?type=${requestScope.type}&amp;cfid=${file.id}&amp;crid=${revision.id}">

  <rhn:list pageList="${requestScope.pageList}" noDataText="copycentral.jsp.noChannels">
    <rhn:listdisplay filterBy="copysandbox.jsp.channel"
                     set="${requestScope.set}"
                     button="copycentral.jsp.copy">
      <rhn:set value="${current.id}"/>

      <rhn:column header="copysandbox.jsp.channel"
                  url="/rhn/systems/details/configuration/ViewModifySandboxPaths.do?sid=${current.id}">
        <img alt='<bean:message key="config.common.sandboxAlt" />' src="/img/rhn-listicon-sandbox.png" />
        ${fn:escapeXml(current.name)}
      </rhn:column>

      <rhn:column header="copycentral.jsp.current">
        <c:choose>
          <c:when test="${current.configRevision == null}">
            <bean:message key="none.message"/>
          </c:when>
          <c:otherwise>
            <a href="/rhn/configuration/file/FileDetails.do?cfid=${current.configFileId}&amp;crid=${current.configRevisionId}">
              <bean:message key="copycentral.jsp.revision" arg0="${current.configRevision}"/>
            </a>
            (<a href="/rhn/configuration/file/Diff.do?cfid=${file.id}&amp;crid=${revision.id}&amp;ocrid=${current.configRevisionId}">
              <bean:message key="copycentral.jsp.compare"/>
            </a>)
          </c:otherwise>
        </c:choose>
      </rhn:column>
    </rhn:listdisplay>
  </rhn:list>
  <rhn:submitted/>
</form>

</body>
</html>
