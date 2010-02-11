<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html xhtml="true">
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_header.jspf" %>
<BR>

<h2><bean:message key="channel.edit.jsp.basicchanneldetails"/></h2>

<div>

<html:form action="/channels/ChannelDetail">


    <table class="details" width="100%">
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.name"/>:
         </th>
         <td class="small-form">
            <c:out value="${channel.name}" />
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.label"/>:
         </th>
         <td class="small-form">
            <c:out value="${channel.label}"/>
         </td>
      </tr>
      <tr>
        <th><bean:message key="channel.jsp.parentchannel"/>:</th>
        <td>
        	<c:if test="${empty channel.parentChannel}">
        		<span class="no-details">(none)</span>
        	</c:if>
        	<c:if test="${!empty channel.parentChannel}">
        		<a href="/rhn/channels/ChannelDetail.do?cid=${channel.parentChannel.id}">
        		<c:out value="${channel.parentChannel.name}" />
        		</a>
        	</c:if>           	
        </td>
      </tr>
      <tr>
        <th><bean:message key="channel.edit.jsp.checksum"/>:</th>
        <td>
            <c:if test="${empty channel.checksumType}">
                <span class="no-details">(none)</span>
            </c:if>
            <c:if test="${!empty channel.checksumType}">
                <c:out value="${channel.checksumType}" />
            </c:if>
        </td>
      </tr>
      <tr>
        <th><bean:message key="packagelist.jsp.packagearch"/>:</th>
        <td><c:out value="${channel.channelArch.name}" /></td>
      </tr>
      <tr>
        <th><bean:message key="channel.jsp.summary"/>:</th>
        <td><c:out value="${channel.summary}" /></td>
      </tr>
      <tr>
        <th><bean:message key="details.jsp.description"/>:</th>
        <td>
        	<c:if test="${empty channel.description}">
        		<span class="no-details">(none)</span>
        	</c:if>
        	<c:if test="${!empty channel.description}">
        		<c:out value="${channel.description}" />
        	</c:if>        	
        </td>
      </tr>
      <tr>
        <th><bean:message key="channel.jsp.chanent"/>:</th>
        <td><c:out value="${channel.channelFamily.name}" /></td>
      </tr>
      <tr>
        <th><bean:message key="channelfiles.jsp.lastmod"/>:</th>
        <td><c:out value="${channel.lastModified}" /></td>
      </tr>
      <tr>
        <th><bean:message key="channel.jsp.repolastbuild"/>:</th>
        <td>
        <c:choose>
              <c:when test="${repo_last_build != null}">
		        <c:out value="${repo_last_build}" /></td>
              </c:when>
              <c:otherwise>
                <span class="no-details">(none)</span>
              </c:otherwise>
        </c:choose>
      </tr>
      <tr>
        <th><bean:message key="channel.jsp.repodata"/>:</th>
        <td>
           <c:choose>
               <c:when test="${repo_status ==  null}">
               <span class="no-details">(none)</span>
               </c:when>
               <c:when test="${repo_status == true}">
                  <bean:message key="channel.jsp.repodata.inProgress"/>
               </c:when>
               <c:when test="${repo_status == false && repo_last_build != null}">
                    <bean:message key="channel.jsp.repodata.completed"/>
               </c:when>
               <c:otherwise>
                <span class="no-details">(none)</span>
              </c:otherwise>
           </c:choose>
        </td>
      </tr>
      <tr>
        <th><bean:message key="header.jsp.packages"/>:</th>
        <td><a href="/rhn/channels/ChannelPackages.do?cid=${channel.id}">
        		${pack_size}</a></td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.perusersub"/>:
         </th>
         <td class="small-form">
            <table>
            <tr>
	            <c:choose>
		            <c:when test="${has_access}">
		                <td><html:radio property="global" value="all" /></td>
		            </c:when>
		            <c:otherwise>
		                <td><html:radio property="global" value="all" disabled="true"/></td>
		            </c:otherwise>
	            </c:choose>
            <td><bean:message key="channel.edit.jsp.allusers"/></td>
            </tr><tr>
	            <c:choose>
		            <c:when test="${has_access == true}">
		                <td><html:radio property="global" value="selected" /></td>
		            </c:when>
		            <c:otherwise>
		                <td><html:radio property="global" value="selected" disabled="true"/></td>
		            </c:otherwise>  
	            </c:choose>
            <td><bean:message key="channel.edit.jsp.selectedusers"/></td>
            </tr>
            </table>
         </td>
      </tr>
      
      <tr>
        <th><bean:message key="channel.jsp.systemssubsribed"/>:</th>
        <td><a href="/rhn/channels/ChannelSubscribers.do?cid=${channel.id}">${systems_subscribed}</a></td>
      </tr>
    </table>
   <h2><bean:message key="channel.edit.jsp.contactsupportinfo"/></h2>
   <table class="details">
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.maintainername"/>:
         </th>
         <td class="small-form">
            <c:out value="${channel.maintainerName}" />
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.maintainercontactinfo"/>:
         </th>
         <td class="small-form">
            <table>
            <tr>
            <td><bean:message key="channel.edit.jsp.emailaddress"/>:</td>
            <td><c:out value="${channel.maintainerEmail}" /></td>
            </tr><tr>
            <td><bean:message key="channel.edit.jsp.phonenumber"/>:</td>
            <td><c:out value="${channel.maintainerPhone}" /></td>
            </tr>
            </table>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.supportpolicy"/>:
         </th>
         <td class="small-form">
            <c:out value="${channel.supportPolicy}" />
         </td>
      </tr>
   </table>
   <h2><bean:message key="channel.edit.jsp.security.gpg"/></h2>
   <table class="details">
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.gpgkeyurl"/>:
         </th>
         <td class="small-form">
            <c:choose>
              <c:when test="${channel.GPGKeyUrl !=  null}">
                <c:out value="${channel.GPGKeyUrl}" /><br><br> 		
              </c:when>
              <c:otherwise>
                (none entered)<br><br> 		
              </c:otherwise>
            </c:choose>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.gpgkeyid"/>:
         </th>
         <td class="small-form">
            <c:choose>
              <c:when test="${channel.GPGKeyId !=  null}">
                <c:out value="${channel.GPGKeyId}" /><br><br> 		
              </c:when>
              <c:otherwise>
                (none entered)<br><br> 		
              </c:otherwise>
            </c:choose>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <bean:message key="channel.edit.jsp.gpgkeyfingerprint"/>:
         </th>
         <td class="small-form">
            <c:choose>
              <c:when test="${channel.GPGKeyFp !=  null}">
                <c:out value="${channel.GPGKeyFp}" /><br><br> 		
              </c:when>
              <c:otherwise>
                (none entered)<br><br> 		
              </c:otherwise>
            </c:choose>
         </td>
      </tr>
   </table>
    
      <c:if test="${has_access}">
	    <p align="right">
            <html:submit property="Update">
                <bean:message key="message.Update"/>
            </html:submit>
	    </p>
      </c:if>
 <rhn:submitted/> 
 <html:hidden property="cid" value="${channel.id}" />
</html:form>
    	   
    		
    
</div>

</body>
</html:html>

