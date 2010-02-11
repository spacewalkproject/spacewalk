<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html xhtml="true">
<body>
<%@ include file="/WEB-INF/pages/common/fragments/package/package_header.jspf" %>

<h2>
<bean:message key="channel.jsp.details.title"/>
</h2>

<div>

    <table class="details" width="100%">
       
      <tr>
        <th><bean:message key="package.jsp.description"/>:</th>
        <td>${description}</td>
      </tr>

      <tr>
        <th><bean:message key="package.jsp.arch"/>:</th>
        <td><c:out value="${pack.packageArch.label}" /></td>
      </tr>
      
      <tr>
        <th><bean:message key="package.jsp.availarch"/>:</th>
        <td>
        	${pack.packageArch.name}
			<c:forEach items="${packArches}" var="tmpPack">   
			  , <a href="/rhn/software/packages/Details.do?pid=${tmpPack.id}">
			  		${tmpPack.packageArch.name} 
			   </a>
			</c:forEach>        		
        </td>
      </tr>      
       
      
      <tr>
        <th><bean:message key="package.jsp.availfrom"/>:</th>
        <td>
			<c:forEach items="${pack.channels}" var="channel">   
			  <a href="/rhn/channels/ChannelDetail.do?cid=${channel.id}">
			  		${channel.name} 
			   </a><br>
			</c:forEach>   
        </td>
      </tr>
      
      <tr>
        <th><bean:message key="package.jsp.vendor"/>:</th>
        <td><c:out value="${pack.vendor}" /></td>
      </tr>      
      
      <tr>
        <th><bean:message key="package.jsp.key"/>:</th>
        <c:if test="${package_key !=  null}">
		<td><c:out value="${package_key}" /></td>
        </c:if>
        <c:if test="${package_key ==  null}">
		<td><bean:message key="package.jsp.key.unkown"/></td>
        </c:if>

      </tr>

      <tr>
        <th><c:out value="${pack.checksum.checksumType.description}"/>:</th>
        <td><c:out value="${pack.checksum.checksum}" /></td>
      </tr>

      <tr>
        <th><bean:message key="package.jsp.path"/>:</th>
        <td><c:out value="${pack.path}" /></td>
      </tr>              
      
      <tr>
        <th><bean:message key="package.jsp.packagesize"/>:</th>
        <td><c:out value="${pack.packageSizeString}" /> </td>
      </tr>      
      
      
   <!-- Patch stuff -->   
   <rhn:require acl="package_type_capable(solaris_patch)"
		mixins="com.redhat.rhn.common.security.acl.PackageAclHandler">
       <tr>
        <th><bean:message key="package.jsp.solarisrelease"/>:</th>
        <td><c:out value="${pack.solarisRelease}" /></td>
      </tr>    
      
       <tr>
        <th><bean:message key="package.jsp.sunosrelease"/>:</th>
        <td><c:out value="${pack.sunosRelease}" /></td>
      </tr>    
      
       <tr>
        <th><bean:message key="package.jsp.patchtype"/>:</th>
        <td><c:out value="${pack.patchType.name}" /></td>
      </tr>          
       
       <tr>
        <th><bean:message key="package.jsp.patchinfo"/>:</th>
        <td><c:out value="${pack.patchInfo}" /></td>
      </tr>  
        	        
      <tr>
        <th><bean:message key="package.jsp.readme"/>:</th>
        <td><a href="<c:out value="${readme_url}" />">
        	<bean:message key="package.jsp.readmedownload"/>
        	</a>
        </td>
      </tr>           
  
  </rhn:require>      
  
  
  
  
  <!-- Patch Set stuff -->   
  <rhn:require acl="package_type_capable(solaris_patchset)"
		mixins="com.redhat.rhn.common.security.acl.PackageAclHandler">
      <tr>
        <th><bean:message key="package.jsp.readme"/>:</th>
        <td><a href="<c:out value="${readme_url}" />">
        	<bean:message key="package.jsp.readmedownload"/>
        	</a>
        </td>
      </tr>               	        
  
  
  </rhn:require>        
      
      
      
      
  <!-- RPM stuff -->   
  <rhn:require acl="package_type_capable(rpm)"
    mixins="com.redhat.rhn.common.security.acl.PackageAclHandler">

	      <tr>
	        <th><bean:message key="package.jsp.payloadsize"/>:</th>
	        <td><c:out value="${pack.payloadSizeString}" /> </td>
	      </tr>           
	      
	      <tr>
	        <th><bean:message key="package.jsp.buildhost"/>:</th>
	        <td><c:out value="${pack.buildHost}" /></td>
	      </tr>          
	      
	      <tr>
	        <th><bean:message key="package.jsp.builddate"/>:</th>
	        <td><c:out value="${pack.buildTime}" /></td>
	      </tr>             
	
	      <tr>
	        <th><bean:message key="package.jsp.license"/>:</th>
	        <td><c:out value="${pack.copyright}" /></td>
	      </tr>            
	      
	      <tr>
	        <th><bean:message key="package.jsp.group"/>:</th>
	        <td><c:out value="${pack.packageGroup.name}" /> </td>
	      </tr>                       
	
	      <tr>
	        <th><bean:message key="package.jsp.rpmversion"/>:</th>
	        <td><c:out value="${pack.rpmVersion}" /> </td>
	      </tr>             
      </rhn:require>
  
      <tr>
        <th><bean:message key="package.jsp.download"/>:</th>
        <td>
        	<c:if test="${url !=  null}">
        		<a href="${url}">${pack.file}</a> ${pack.packageSizeString}
        	</c:if>
        	<c:if test="${url eq null}">
        		<div style="font-weight: bold;">  
        			<bean:message key="package.jsp.missingfile"/>: ${pack.file}</div> 
        	    </div>
        	</c:if>       
        	
        </td>
      </tr>          
      
      
      <tr>
      	<th>
      	  <bean:message key="package.jsp.source"/>:
      	</th>
      	<td>
        	<c:if test="${srpm_url !=  null}">
			<a href="${srpm_url}">${srpm_path}</a>
        	</c:if>
        	<c:if test="${srpm_url eq null}">
        		<div style="font-weight: bold;">  
        			<bean:message key="package.jsp.unavailable"/>
        		</div>	
        	</c:if>          	
      	</td>
     </tr>
    		   
    
</div>

</body>
</html:html>

