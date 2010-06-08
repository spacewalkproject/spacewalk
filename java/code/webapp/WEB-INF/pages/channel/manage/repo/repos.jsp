<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif"
               creationUrl="RepoCreate.do"
               creationType="repos"
               imgAlt="info.alt.img">
  <bean:message key="repos.jsp.header"/>
</rhn:toolbar>
<div class="page-summary">
<p><bean:message key="repos.jsp.summary"/></p>
<c:if test="${not empty requestScope.default}">
	<rhn:note key = "repos.jsp.note.default"/>
</c:if>
</div>


 <rl:listset name="keySet">
  <rl:list dataset="pageList"
         width="100%"
         name="keysList"
         styleclass="list"
         emptykey="repos.jsp.norepos"
         alphabarcolumn="label">

        <rl:decorator name="PageSizeDecorator"/>

        <!-- Description name column -->
        <rl:column bound="false"
                   sortable="true"
                   headerkey="repos.jsp.label"
                   styleclass="first-column"
                   sortattr= "label"
                   filterattr="label">                            
              		<c:out value="<a href=\"/rhn/channels/manage/repos/RepoEdit.do?id=${current.id}\">${current.label}</a>" escapeXml="false" />              	              
        </rl:column>
        <rl:column bound="false" 
	           sortable="false" 
	           headerkey="repo.jsp.channels" 
	           attr="channels"
	           styleclass="last-column">
	 	<c:out value="${current.channels}" />
	    </rl:column>
      </rl:list>
     </rl:listset>		
    
</body>
</html>

