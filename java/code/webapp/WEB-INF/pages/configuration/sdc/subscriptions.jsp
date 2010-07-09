<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>
<html:xhtml/>
<html>
<head>
  <meta name="name" value="sdc.config.subscriptions.jsp.header"/>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2> <img src="${cfg:channelHeaderIcon('central')}"
					alt="${cfg:channelAlt('central')}"/>
			<bean:message key="sdc.config.subscriptions.jsp.header"/></h2>	
<h3><bean:message key="ssm.config.subscribe.jsp.step"/></h3>
<p><bean:message key="sdc.config.subscriptions.jsp.para1" /></p>
<noscript>
	<p><bean:message key="common.config.rank.jsp.warning.noscript"/></p>
</noscript>	
<c:choose>
<c:when test="${not empty pageList}">
<html:form  method="POST" action="/systems/details/configuration/SubscriptionsSubmit.do?sid=${param.sid}">

    <rhn:list pageList="${requestScope.pageList}"
    		  noDataText="sdc.config.subscriptions.jsp.noChannels">

      <rhn:listdisplay  set="${requestScope.set}"
	 filterBy = "sdc.config.subscriptions.jsp.channel"
      	 >
        <rhn:set value="${current.id}"/>
        <rhn:column header="sdc.config.subscriptions.jsp.channel"
                      url="/rhn/configuration/ChannelOverview.do?ccid=${current.id}">
            <img alt='<bean:message key="config.common.globalAlt" />' src="/img/rhn-listicon-channel.gif">
            ${current.name}
        </rhn:column>

      <rhn:column header="sdc.config.subscriptions.jsp.files">
            ${current.filesAndDirsDisplayString}
      </rhn:column>


      </rhn:listdisplay>
      <div align="right">
          <hr />
          <html:submit property="dispatch">
	          <bean:message key="sdc.config.subscriptions.jsp.continue"/>
          </html:submit>
      </div>
    </rhn:list>
	<rhn:noscript/>
	
	<rhn:submitted/>
	</html:form>
</c:when>
<c:otherwise>
	<p><strong><bean:message key="sdc.config.subscriptions.jsp.noChannels"
				arg0="/rhn/systems/details/configuration/ConfigChannelList.do?sid=${param.sid}"/>
	</strong></p>
</c:otherwise>
</c:choose>	
</body>
</html>