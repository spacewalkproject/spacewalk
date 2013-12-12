<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<head>
<script src="/javascript/prototype.js" type="text/javascript"> </script>
<script src="/javascript/rank_options.js" type="text/javascript"> </script>
</head>
<body>
    <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>

<h2>
  <rhn:icon type="header-configuration" title="<bean:message key='config.common.channelsAlt' />" />
  <bean:message key="ssm.config.rank.jsp.header" />
</h2>
<h3><bean:message key="ssm.config.rank.jsp.step"/></h3>
<div class="page-summary">
  <p>
    <bean:message key="ssm.config.rank.jsp.summary" />
  </p>
	<noscript>
		<p><bean:message key="common.config.rank.jsp.warning.noscript"/></p>
	</noscript>
</div>
<html:form method="POST"
               action="/systems/ssm/config/Rank.do">
        <rhn:csrf />
        <rhn:submitted />
		<h2><bean:message key="sdc.config.rank.jsp.subscribed_channels"/></h2>
		<table style="width:60%;">
			<tr>
			<%@ include file="/WEB-INF/pages/common/fragments/configuration/rankchannels.jspf" %>
			<td>
			  <table class="schedule-action-interface">
                <tr>
                  <td><html:radio property="priority" value="lowest" /></td>
                  <th><bean:message key="ssm.config.rank.jsp.lowest" /></th>
                </tr>
                <tr>
                  <td><html:radio property="priority" value="highest" /></td>
                  <th><bean:message key="ssm.config.rank.jsp.highest" /></th>
                </tr>
                <tr>
                  <td><html:radio property="priority" value="replace" /></td>
                  <th><bean:message key="ssm.config.rank.jsp.replace" /></th>
                </tr>
              </table>
			</td>
			</tr>
		</table>

	<div class="text-right">
      <hr />
      <html:hidden property="dispatch" value="${rhn:localize('ssm.config.rank.jsp.apply')}"/>
      <input type=submit name="dispatcher"
			value="${rhn:localize('ssm.config.rank.jsp.apply')}"
                   onclick="handle_ranking_dispatch('ranksWidget','rankedValues','channelRanksForm');"/>
    </div>
	</html:form>
</body>
</html>
