<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<c:choose>
  <c:when test="${requestScope.type == 'central'}">
    <c:set var="channeltrans" value="copycentral.jsp.channel" />
  </c:when>
  <c:when test="${requestScope.type == 'local'}">
    <c:set var="channeltrans" value="copylocal.jsp.channel" />
  </c:when>
  <c:otherwise>
    <c:set var="channeltrans" value="copysandbox.jsp.channel" />
  </c:otherwise>
</c:choose>

  <rhn:list pageList="${requestScope.pageList}" noDataText="copycentral.jsp.noChannels">
    <rhn:listdisplay filterBy="${channeltrans}"
                     set="${requestScope.set}"
                     button="copycentral.jsp.copy">
      <rhn:set value="${current.id}"/>

      <rhn:column header="${channeltrans}"
                  url="/rhn/configuration/ChannelOverview.do?ccid=${current.id}">
        <c:choose>
          <c:when test="${requestScope.type == 'central'}">
            <rhn:icon type="header-channel" title="<bean:message key='config.common.globalAlt' />" />
          </c:when>
          <c:when test="${requestScope.type == 'local'}">
            <rhn:icon type="header-system-physical" title="<bean:message key='config.common.localAlt' />" />
          </c:when>
          <c:otherwise>
            <rhn:icon type="header-sandbox" title="<bean:message key='config.common.sandboxAlt' />" />
          </c:otherwise>
        </c:choose>
        ${current.nameDisplay}
      </rhn:column>

      <rhn:column header="copycentral.jsp.label">
        ${current.label}
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
