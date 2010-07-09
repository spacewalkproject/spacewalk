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
  <bean:message key="unsubscribeconfirm.jsp.header"/>
</h2>

<div class="page-summary">
  <p>
    <c:choose>
      <c:when test="${requestScope.channum == 1}">
        <bean:message key="unsubscribeconfirm.jsp.summary.one" />
      </c:when>
      <c:otherwise>
        <bean:message key="unsubscribeconfirm.jsp.summary" arg0="${requestScope.channum}"/>
      </c:otherwise>
    </c:choose>
  </p>
</div>
<form method="post" name="rhn_list" action="/rhn/systems/ssm/config/UnsubscribeConfirmSubmit.do">
  <rhn:list pageList="${requestScope.pageList}"
            noDataText="unsubscribeconfirm.jsp.noSystems">
    <rhn:listdisplay filterBy="unsubscribeconfirm.jsp.system"
                     button="unsubscribeconfirm.jsp.confirm">
      <rhn:column header="unsubscribeconfirm.jsp.system"
                  url="/rhn/systems/details/configuration/Overview.do?sid=${current.id}">
        <img src="/img/rhn-listicon-system.gif"
             alt="<bean:message key='system.common.systemAlt' />" />
        ${current.name}
      </rhn:column>

      <rhn:column header="unsubscribeconfirm.jsp.channels"
                  url="/rhn/systems/ssm/config/SystemChannels.do?sid=${current.id}">
        <c:choose>
          <c:when test="${current.configChannelCount == 1}">
            <bean:message key="unsubscribeconfirm.jsp.onechannel" />
          </c:when>
          <c:otherwise>
            <bean:message key="unsubscribeconfirm.jsp.numchannels" arg0="${current.configChannelCount}"/>
          </c:otherwise>
        </c:choose>
      </rhn:column>

    </rhn:listdisplay>
  </rhn:list>
</form>
</body>
</html>

