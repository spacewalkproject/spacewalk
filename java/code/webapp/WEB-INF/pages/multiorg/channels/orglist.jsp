<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html"%>
<html:xhtml/>
<html>
<head>
    <meta name="name" value="activationkeys.jsp.header" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif"
             deletionUrl="/rhn/channels/manage/Delete.do?cid=${param.cid}"
             deletionAcl="user_role(channel_admin); formvar_exists(cid)"
             deletionType="software.channel">
  <bean:message key="channel.edit.jsp.toolbar" arg0="${channel_name}"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1"
                definition="/WEB-INF/nav/manage_channel.xml"
                renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<p>
<h2><bean:message key="channel.edit.jsp.orgaccess.header"/></h2>
</p>
<p>
	<bean:message key="channel.edit.jsp.orgaccess.summary" arg0="${channel_name}"/>
</p>

<rl:listset name="orgChannelProtectionSet">
    <html:hidden property="cid" value="${param.cid}"/>

	<!-- Start of Files list -->
	<rl:list dataset="dataset"
	         name="list"
	         decorator="SelectableDecorator"
             width="100%"
             emptykey = "org.channels.trusted.protection"
	         >

      <rl:selectablecolumn value="${current.selectionKey}"
						selected="${current.selected}"
						styleclass="first-column"/>
		<!-- Organization column -->
		<rl:column  headerkey="general.jsp.org.tbl.header1" filterattr="name">
		   ${current.name}
		</rl:column>
		
		<!-- Subscribed Systems column -->
		<rl:column bound="true"
		           headerkey="org.channel.subscribed.systems"
		           attr="systems"
					/>
	</rl:list>
<hr/>
<c:if test="${not empty requestScope.dataset}">
<div align="right">
   <rhn:submitted/>
    <input type="submit"
		name ="dispatch"
    	value="${rhn:localize('orgchannel.jsp.submit')}"/>
</div>
</c:if>
</rl:listset>
</body>
</html>
