<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html>
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif"
               creationUrl="CobblerSnippetCreate.do"
               creationType="snippets"
               imgAlt="info.alt.img">
  <bean:message key="snippets.jsp.toolbar"/>
</rhn:toolbar>

<div>
    <bean:message key="snippets.jsp.summary"/>
</div>

<hr>
<div>
    <form method="post" name="rhn_list" action="/rhn/kickstart/cobbler/CobblerSnippetList.do">

 <rl:listset name="keySet">
  <rl:list dataset="pageList"
         width="100%"
         name="keysList"
         styleclass="list"
         emptykey="cobbler.snippet.jsp.nosnippets"
         alphabarcolumn="displayPath">

        <rl:decorator name="PageSizeDecorator"/>

        <!-- Description name column -->
        <rl:column bound="false"
                   sortable="true"
                   headerkey="cobbler.snippet.name"
                   styleclass="first-column"
                   sortattr= "displayPath"
                   filterattr="displayPath">
              <c:choose>
              	<c:when test = "${current.editable}">
              		<c:out value="<a href=\"/rhn/kickstart/cobbler/CobblerSnippetEdit.do?name=${current.name}\">${current.displayPath}</a>" escapeXml="false" />
              	</c:when>
              	<c:otherwise>
	              	<c:out value="<a href=\"/rhn/kickstart/cobbler/CobblerSnippetView.do?path=${current.displayPath}\">${current.displayPath}</a>" escapeXml="false" />
              	</c:otherwise>      
                
              </c:choose>
        </rl:column>
            <rl:column headerkey="kickstart.distro.sw_managed.jsp"  styleclass="last-column">
            	<c:choose>
                    <c:when test="${not current.editable}">
                    	<img src="/img/rhn-listicon-error.gif">
                    </c:when>
					<c:otherwise>
						<img src="/img/rhn-listicon-checked.gif">
                	</c:otherwise>
                </c:choose>
            </rl:column>
      </rl:list>
     </rl:listset>

</div>

</body>
</html>

