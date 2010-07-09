<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/header.jspf" %>
<h2><bean:message key="comparerevision.jsp.header"/></h2>

<div class="page-summary">
  <p>
    <bean:message key="comparerevision.jsp.summary"
                  arg0="/rhn/configuration/file/FileDetails.do?cfid=${file.id}&amp;crid=${revision.id}"
                  arg1="${revision.revision}"
                  arg2="/rhn/configuration/ChannelOverview.do?ccid=${channel.id}"
                  arg3="${channel.name}"/>
  </p>
</div>

<form method="post" name="rhn_list" action="/rhn/configuration/file/CompareRevision.do?cfid=${file.id}&amp;crid=${revision.id}">
<rhn:list pageList="${requestScope.pageList}" noDataText="comparerevision.jsp.noRevisions">
  <rhn:listdisplay filterBy="comparerevision.jsp.revision">
    <rhn:column header="comparerevision.jsp.revision"
                url="/rhn/configuration/file/FileDetails.do?cfid=${file.id}&amp;crid=${current.id}">
        <bean:message key="comparerevision.jsp.revnum" arg0="${current.revisionNumber}"/>
    </rhn:column>

    <rhn:column header="comparerevision.jsp.created">
        ${current.createdDisplay}
    </rhn:column>

    <rhn:column header="comparerevision.jsp.comparison">
        <a class="link-button" href="/rhn/configuration/file/Diff.do?cfid=${file.id}&amp;crid=${revision.id}&amp;ocrid=${current.id}">
            <bean:message key="comparerevision.jsp.compare" />
        </a>
    </rhn:column>
  </rhn:listdisplay>
</rhn:list>
</form>

</body>
</html>

