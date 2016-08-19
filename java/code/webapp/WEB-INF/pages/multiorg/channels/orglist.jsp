<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<html>
<head>
    <meta name="name" value="activationkeys.jsp.header" />
</head>
<body>
<rhn:toolbar base="h1" icon="header-channel"
             deletionUrl="/rhn/channels/manage/Delete.do?cid=${param.cid}"
             deletionAcl="user_role(channel_admin); formvar_exists(cid)"
             deletionType="software.channel">
  <bean:message key="channel.edit.jsp.toolbar" arg0="${fn:escapeXml(channel_name)}"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1"
                definition="/WEB-INF/nav/manage_channel.xml"
                renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<p>
<h2><bean:message key="channel.edit.jsp.orgaccess.header"/></h2>
</p>
<p>
        <bean:message key="channel.edit.jsp.orgaccess.summary" arg0="${fn:escapeXml(channel_name)}"/>
</p>

<rl:listset name="orgChannelProtectionSet">
    <rhn:csrf />
    <html:hidden property="cid" value="${param.cid}"/>

        <!-- Start of Files list -->
        <rl:list dataset="dataset"
                 name="list"
                 decorator="SelectableDecorator"
             width="100%"
             emptykey = "org.channels.trusted.protection"
                 >

      <rl:selectablecolumn value="${current.selectionKey}"
                                                selected="${current.selected}"/>
                <!-- Organization column -->
                <rl:column  headerkey="general.jsp.org.tbl.header1" filterattr="name">
                   ${current.name}
                </rl:column>

                <!-- Subscribed Systems column -->
                <rl:column bound="true"
                           headerkey="org.channel.subscribed.systems"
                           attr="systems"/>
        </rl:list>
<hr/>
<c:if test="${not empty requestScope.dataset}">
<div class="text-right">
   <rhn:submitted/>
    <input type="submit" class="btn btn-success"
                name ="dispatch"
        value="${rhn:localize('orgchannel.jsp.submit')}"/>
</div>
</c:if>
</rl:listset>
</body>
</html>
