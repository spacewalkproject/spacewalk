<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <rhn:icon type="header-configuration" title="config.common.channelsAlt" />
  <bean:message key="ssmsystemchannels.jsp.header" />
</h2>

  <div class="page-summary">
    <p>
      <c:set var="beanarg" scope="request">
        <a href="/rhn/systems/details/configuration/Overview.do?sid=${system.id}"
          <rhn:icon type="header-system-physical" title="system.common.systemAlt" />
          ${system.name}
        </a>
      </c:set>
      <bean:message key="ssmsystemchannels.jsp.summary"
                    arg0="${beanarg}"
                    arg1="/rhn/systems/details/configuration/ConfigChannelList.do?sid=${system.id}"/>
    </p>
  </div>

<form method="post" name="rhn_list" action="/rhn/systems/ssm/config/SystemChannels.do?sid=${param.sid}">
  <rhn:csrf />
  <rhn:submitted />
  <rhn:list pageList="${requestScope.pageList}"
            noDataText="ssmsystemchannels.jsp.noChannels">
    <rhn:listdisplay filterBy="config.common.configChannel">
      <rhn:column header="config.common.configChannel"
                  url="/rhn/configuration/ChannelOverview.do?ccid=${current.id}">
        <rhn:icon type="header-channel" title="config.common.globalAlt" />
        ${current.name}
      </rhn:column>

      <rhn:column header="ssmsystemchannels.jsp.files">
        <c:choose>
          <c:when test="${current.fileCount == 1}">
            <bean:message key="ssmsystemchannels.jsp.onefile" />
          </c:when>
          <c:otherwise>
            <bean:message key="ssmsystemchannels.jsp.numfiles" arg0="${current.fileCount}"/>
          </c:otherwise>
        </c:choose>
      </rhn:column>
    </rhn:listdisplay>
  </rhn:list>
</form>

</body>
</html>
