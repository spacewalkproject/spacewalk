<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/header.jspf" %>
<h2><bean:message key="comparefile.jsp.header"/></h2>

<div class="page-summary">
  <p>
    <c:set var="beanarg" scope="request">
      <cfg:channel id="${ochannel.id}"
                   name="${ochannel.displayName}"
                   type="${ochannel.configChannelType.label}" />
    </c:set>
    <bean:message key="comparefile.jsp.summary"
                  arg0="/rhn/configuration/file/FileDetails.do?cfid=${file.id}&amp;crid=${revision.id}"
                  arg1="${revision.revision}"
                  arg2="${beanarg}" />
  </p>
</div>

<form method="post" name="rhn_list" action="/rhn/configuration/file/CompareFile.do?cfid=${file.id}&amp;crid=${revision.id}&amp;ccid=${ochannel.id}">
<rhn:list pageList="${requestScope.pageList}" noDataText="comparefile.jsp.noFiles">
  <rhn:listdisplay filterBy="comparefile.jsp.path">
    <rhn:column header="comparefile.jsp.path">
        <cfg:file id="${current.id}"
                  revisionId="${current.latestConfigRevisionId}"
                  path="${current.path}"
                  type="${current.type}" />
    </rhn:column>

    <rhn:column header="comparefile.jsp.modified">
        ${current.modifiedDisplay}
    </rhn:column>

    <rhn:column header="comparefile.jsp.size">
      ${current.latestRevisionSizeDisplay}
    </rhn:column>

    <rhn:column header="comparefile.jsp.comparison">
        <a class="link-button" href="/rhn/configuration/file/Diff.do?cfid=${file.id}&amp;crid=${revision.id}&amp;ocrid=${current.latestConfigRevisionId}">
            <bean:message key="comparefile.jsp.compare" />
        </a>
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>
</form>

</body>
</html>

