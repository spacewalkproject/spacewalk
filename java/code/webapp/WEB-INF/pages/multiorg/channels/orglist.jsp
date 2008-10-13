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


<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif"
             deletionUrl="/network/software/channels/manage/delete_confirm.pxt?cid=${param.cid}"
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

<rl:listset name="activationKeysSet">
	<!-- Start of Files list -->
	<rl:list dataset="pageList"
	         name="activationKeys"
	         decorator="SelectableDecorator"
             width="100%"
             emptykey = "kickstart.activationkeys.jsp.nokeys"             
	         >
	        
      <rl:selectablecolumn value="${current.selectionKey}" 
	    					selected="${current.selected}" 
	    					styleclass="first-column"
	    					headerkey="activation-keys.jsp.enabled"/>	        
		<!-- Description column -->
		<rl:column  headerkey="kickstart.activationkeys.jsp.description" filterattr="note">
			<c:choose>
               <c:when test="${current.note != null}">
				<a href="/rhn/activationkeys/Edit.do?tid=${current.id}">
					     <c:out value="${current.note}"/></a>            					
               </c:when>
               <c:otherwise>
				<a href="/rhn/activationkeys/Edit.do?tid=${current.id}">
					     <bean:message key="kickstart.activationkeys.jsp.description.none"/></a>
               </c:otherwise>
            </c:choose>
			<c:if test="${current.orgDefault}"><c:out value=" *"/></c:if>		           
		</rl:column>
		
		<!-- Key -->
		<rl:column bound="true" 
		           headerkey="kickstart.activationkeys.jsp.key"
		           attr="token" 
					/>
		
		           
		<!-- Usage Limit -->
		<rl:column bound="false" 
		           headerkey="kickstart.activationkeys.jsp.usagelimit"
		           styleclass="last-column"
					>
			<c:choose>
               <c:when test="${current.usageLimit != null}">
					    ${current.systemCount}/${current.usageLimit}   					
               </c:when>
               <c:otherwise>
					    ${current.systemCount}/<bean:message key="kickstart.activationkeys.jsp.nousagelimit"/>
               </c:otherwise>
            </c:choose>		           
					
		</rl:column>				
	</rl:list>
<hr/>

<div align="right">
   <rhn:submitted/>
    <input type="submit" 
		name ="dispatch"
    	value="${rhn:localize('orgchannel.jsp.submit')}"/>
</div>
</rl:listset>
</body>
</html>
