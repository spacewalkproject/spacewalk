<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <img src="/img/rhn-config_channels.gif" alt='<bean:message key="config.common.channelsAlt" />' />
  <bean:message key="unsubscribe.jsp.header"/>
</h2>

<div class="page-summary">
  <p>
    <bean:message key="unsubscribe.jsp.summary"/>
  </p>
</div>
<form method="post" name="rhn_list" action="/rhn/systems/ssm/config/UnsubscribeSubmit.do">
  <rhn:list pageList="${requestScope.pageList}"
            noDataText="unsubscribe.jsp.noChannels">
    <rhn:listdisplay filterBy="config.common.configChannel"
                     set="${requestScope.set}"
                     button="unsubscribe.jsp.unsubscribe">
      <rhn:set value="${current.id}"/>

      <rhn:column header="config.common.configChannel"
                  url="/rhn/configuration/ChannelOverview.do?ccid=${current.id}">
        <img alt='<bean:message key="config.common.globalAlt" />' src="/img/rhn-listicon-channel.gif">
        ${current.name}
      </rhn:column>

      <rhn:column header="unsubscribe.jsp.systems"
                  url="/rhn/systems/ssm/config/ChannelSystems.do?ccid=${current.id}">
        <c:choose>
          <c:when test="${current.systemCount == 1}">
            <bean:message key="system.common.onesystem" />
          </c:when>
          <c:otherwise>
            <bean:message key="system.common.numsystems" arg0="${current.systemCount}"/>
          </c:otherwise>
        </c:choose>
      </rhn:column>

    </rhn:listdisplay>
  </rhn:list>
</form>
</body>
</html>

