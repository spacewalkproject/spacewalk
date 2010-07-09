<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>
<html:xhtml/>
<html>
<head>
<script src="/javascript/config_channel_ranks.js" type="text/javascript"></script>
</head>
<body>
	<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>	
	<html:form  method="post"
					action="/systems/details/configuration/RankChannels.do?sid=${param.sid}"
					styleId="ranksForm">
		<h2> <img src="${cfg:channelHeaderIcon('central')}"
					alt="${cfg:channelAlt('central')}"/>
			<bean:message key="sdc.config.rank.jsp.header"/></h2>
		<c:if test="${not empty param.wizard_mode}">	
			<h3><bean:message key="ssm.config.rank.jsp.step"/></h3>
			<input type="hidden" name="wizard_mode" value="true"/>
		</c:if>
		<p><bean:message key="sdc.config.rank.jsp.para1"/></p>
		<p><bean:message key="sdc.config.rank.jsp.para2"
				arg0="${rhn:localize('sdc.config.rank.jsp.update')}"/></p>
		<c:if test="${not empty param.wizard_mode}">					
			<p><span class="small-text"><bean:message key="common.config.rank.jsp.warning"
					arg0="${rhn:localize('sdc.config.rank.jsp.update')}"/></span></p>
		</c:if>
		<noscript>
			<p><bean:message key="common.config.rank.jsp.warning.noscript"/></p>
		</noscript>				
        <h2><bean:message key="sdc.config.rank.jsp.subscribed_channels"/></h2>
		<table style="width:50%;">
          <tr>
            <%@ include file="/WEB-INF/pages/common/fragments/configuration/rankchannels.jspf" %>
          </tr>
		</table>
	<div align="right">
      <hr />
      <html:hidden property="dispatch" value="${rhn:localize('sdc.config.rank.jsp.update')}"/>
      <input type=submit name="dispatcher"
			value="${rhn:localize('sdc.config.rank.jsp.update')}"
                   onclick="handle_config_channels_dispatch('ranksWidget','rankedValues','ranksForm');"/>
	</div>
	</html:form>
</body>
</html>