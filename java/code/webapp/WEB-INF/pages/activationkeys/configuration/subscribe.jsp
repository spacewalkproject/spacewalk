<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>
<html:xhtml/>
<html>
<head>
    <meta name="name" value="activation-keys.config.jsp.header" />
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/activationkeys/common-header.jspf" %>
<h2> <img src="${cfg:channelHeaderIcon('central')}"
					alt="${cfg:channelAlt('central')}"/>
			<bean:message key="sdc.config.subscriptions.jsp.header"/></h2>	
<h3><bean:message key="ssm.config.subscribe.jsp.step"/></h3>
<p><bean:message key="activation-key.config.subscriptions.jsp.para1"
			arg0="${rhn:localize('sdc.config.subscriptions.jsp.continue')}"/></p>
<noscript>
	<p><bean:message key="common.config.rank.jsp.warning.noscript"/></p>
</noscript>	


<c:set var="pageList" value="${requestScope.all}" />

<rl:listset name="channelListSet">
<c:choose>
<c:when test="${not empty pageList}">
	<rl:list dataset="pageList"
         width="100%"
         name="list"
         emptykey="activation-keys.config.subscriptions.jsp.noChannels"
         alphabarcolumn="name">
 			<rl:decorator name="PageSizeDecorator"/>
 		<rl:decorator name="SelectableDecorator"/>
 		<rl:decorator name="ElaborationDecorator"/>
	 		<rl:selectablecolumn value="${current.selectionKey}"
	 			selected="${current.selected}"
	 			disabled="${not current.selectable}"
	 			styleclass="first-column"/>

		  <rl:column headerkey="sdc.config.subscriptions.jsp.channel" bound="false"
		  	sortattr="name"
		  	sortable="true" filterattr="name">
						<cfg:channel id = "${current.id}"
							name ="${current.nameDisplay}"
							type = "central" nolink="${not current.canAccess}"/>
		  </rl:column>
        <rl:column headerkey="sdc.config.subscriptions.jsp.files"
        attr="filesAndDirsDisplayString" bound="true"/>
	</rl:list>
 			
<c:if test="${not empty requestScope.all}">
<div align="right">
   <rhn:submitted/>
   <hr/>
	
    <input type="submit"
    	name ="dispatch"
	    value='<bean:message key="sdc.config.subscriptions.jsp.continue"/>'/>		
</div>
</c:if> 	
</c:when>
<c:otherwise>
	<p><strong><bean:message key="activation-keys.config.subscriptions.jsp.noChannels"
				arg0="/rhn/activationkeys/configuration/List.do?tid=${param.tid}"/>
	</strong></p>
</c:otherwise>
</c:choose>	
</rl:listset>
</body>
</html>
