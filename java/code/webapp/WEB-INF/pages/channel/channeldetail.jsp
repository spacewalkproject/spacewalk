<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html xhtml="true">
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>


 <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_header.jspf" %>
<BR>

<h2>
<bean:message key="channel.jsp.details.title"/>
</h2>

<div>

<form action="/rhn/channels/ChannelDetail.do" method="POST">


	<input type="hidden" name="cid" value="${channel.id}" />

    <table class="details" width="100%">
       
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
        <th><bean:message key="channel.jsp.label"/>:</th>
        <td><c:out value="${channel.label}" /></td>

      </tr>
      <tr>
        <th><bean:message key="channelfiles.jsp.lastmod"/>:</th>
        <td><c:out value="${channel.lastModified}" /></td>
      </tr>
      
      <tr>
        <th><bean:message key="channel.jsp.chanent"/>:</th>
        <td><c:out value="${channel.channelFamily.name}" /></td>
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
        <th><bean:message key="packagelist.jsp.packagearch"/>:</th>
        <td><c:out value="${channel.channelArch.name}" /></td>
      </tr>
      
      <tr>
        <th><bean:message key="header.jsp.packages"/>:</th>
        <td><a href="/rhn/channels/ChannelPackages.do?cid=${channel.id}">
        		${pack_size}</a></td>
      </tr>

      <tr>
        <th><bean:message key="channel.jsp.globallysubtitle"/>:</th>
        <td>
          <input type="checkbox" name="global" value="1" 
          	<c:if test="${globally}">
          		checked
          	</c:if>
          	<c:if test="${!globally}">
          		
          	</c:if>          	
          	
          	<c:if test="${checkbox_disabled}">
          		disabled
          	</c:if>
            />
			<bean:message key="channel.jsp.globallysub"/>
        </td>
      </tr>
      
      <tr>
        <th><bean:message key="channel.jsp.systemssubsribed"/>:</th>
        <td><a href="/rhn/channels/ChannelSubscribers.do?cid=${channel.id}">${systems_subscribed}</a></td>
      </tr>
 	<c:if test="${channel.GPGKeyUrl !=  null}">
  		<tr>
  			<th>
  				<bean:message key="channel.jsp.gpgtitle"/>:
  			</th>
  			<td>
  				<bean:message key="channel.jsp.gpgheader"/> <br><br>
  				<b><bean:message key="channel.jsp.gpglocation"/>:</b> <c:out value="${channel.GPGKeyUrl}" /><br><br> 		
  				<b><bean:message key="channel.jsp.gpgid"/>: </b> <c:out value="${channel.GPGKeyId}" />
  				 	<c:if test="${channel.GPGKeyId ==  null}">
  				 		<bean:message key="channel.jsp.gpgunknown"/>
  				 	</c:if>
  				    <br><br>
  				<b><bean:message key="channel.jsp.gpgfp"/>:</b> <c:out value="${channel.GPGKeyFp}" /> 
			 	<c:if test="${channel.GPGKeyFp ==  null}">
  				 		<bean:message key="channel.jsp.gpgunknown"/>
  				 	</c:if>  				
  				<br><br>
  				<bean:message key="channel.jsp.gpgfooter"/>
  				
  			
  			</td>
  		</tr>
  	</c:if>        
    </table>
    
      <c:if test="${!checkbox_disabled}">
	    <p align="right">
	    	<input type="submit"  name="Update" value="Update" />
	    </p>
      </c:if>
 <rhn:submitted/> 
</form>
    	   
    		
    
</div>

</body>
</html:html>

