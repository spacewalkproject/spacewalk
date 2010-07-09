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
<h2><bean:message key="comparedeployed.jsp.header"/></h2>

<div class="page-summary">
  <p>
    <bean:message key="comparedeployed.jsp.summary"
                  arg0="/rhn/configuration/file/FileDetails.do?cfid=${file.id}&amp;crid=${revision.id}"
                  arg1="${revision.revision}"/>
  </p>
</div>

<form method="post" name="rhn_list" action="/rhn/configuration/file/CompareDeployedSubmit.do?cfid=${file.id}&amp;crid=${revision.id}">
<rhn:list pageList="${requestScope.pageList}" noDataText="comparedeployed.jsp.noSystems">
  <rhn:listdisplay filterBy="system.common.systemName"
                   set="${requestScope.set}"
                   button="comparedeployed.jsp.schedule">
    <rhn:set value="${current.id}"/>

    <rhn:column header="system.common.systemName">
      <cfg:system id="${current.id}" name="${current.name}" />
    </rhn:column>

    <rhn:column header="comparedeployed.jsp.deployed">
        <%-- The c:choose statement here creates the correct image with alt message
             for the channel type we are dealing with. These are later used in a
             bean:message tag. --%>
        <c:choose>
          <c:when test="${current.configChannelType == 'normal'}">
            <c:set var="image" scope="request" value="/img/rhn-listicon-channel.gif" />
            <c:set var="imagealt" scope="request">
              <bean:message key="config.common.globalAlt" />
            </c:set>
          </c:when>
          <c:when test="${current.configChannelType == 'local_override'}">
            <c:set var="image" scope="request" value="/img/rhn-listicon-system.gif" />
            <c:set var="imagealt" scope="request">
              <bean:message key="config.common.localAlt" />
            </c:set>
          </c:when>
          <c:when test="${current.configChannelType == 'server_import'}">
            <c:set var="image" scope="request" value="/img/rhn-listicon-sandbox.gif" />
            <c:set var="imagealt" scope="request">
              <bean:message key="config.common.sandboxAlt" />
            </c:set>
          </c:when>
        </c:choose>

        <c:choose>
          <c:when test="${current.configRevision != null}">
            <%-- Rather ugly bean message here, lots of code and few words.
                 basically it says 'Revision 3 from ConfigChan23' with links on both
                 elements and an img indicating what type the channel is. --%>
            <bean:message key="comparedeployed.jsp.lastknown"
                          arg0="/rhn/configuration/file/FileDetails.do?cfid=${current.configFileId}&amp;crid=${current.configRevisionId}"
                          arg1="${current.configRevision}"
                          arg2="/rhn/configuration/ChannelOverview.do?ccid=${current.configChannelId}"
                          arg3="<img src=\"${image}\" alt=\"${imagealt}\" />"
                          arg4="${fn:escapeXml(current.configChannelName)}" />
          </c:when>
          <c:otherwise>
            <bean:message key="comparedeployed.jsp.never" />
          </c:otherwise>
        </c:choose>
    </rhn:column>

  </rhn:listdisplay>
</rhn:list>
</form>

</body>
</html>

