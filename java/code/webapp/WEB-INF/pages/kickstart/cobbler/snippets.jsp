<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html>
<body>
<rhn:toolbar base="h1" icon="header-info"
               creationUrl="CobblerSnippetCreate.do"
               creationType="snippets"
               iconAlt="info.alt.img">
  <bean:message key="snippets.jsp.toolbar"/>
</rhn:toolbar>
<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/snippet_tabs.xml"
                renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
<div class="page-summary">
<p><bean:message key="snippets.jsp.summary"/></p>
<c:if test="${not empty requestScope['default']}">
	<rhn:note key = "snippets.jsp.note.default"/>
</c:if>
</div>


 <rl:listset name="keySet">
  <rhn:csrf />
  <rhn:submitted />
  <rl:list dataset="pageList"
         width="100%"
         name="keysList"
         styleclass="list"
         emptykey="cobbler.snippet.jsp.nosnippets"
         alphabarcolumn="name">

        <rl:decorator name="PageSizeDecorator"/>

        <!-- Description name column -->
        <rl:column bound="false"
                   sortable="true"
                   headerkey="cobbler.snippet.name"
                   sortattr= "name"
                   filterattr="name">
              <c:choose>
		<c:when test = "${current.editable}">
			<c:out value="<a href=\"/rhn/kickstart/cobbler/CobblerSnippetEdit.do?name=${current.name}\">${current.name}</a>" escapeXml="false" />
		</c:when>
		<c:otherwise>
			<c:out value="<a href=\"/rhn/kickstart/cobbler/CobblerSnippetView.do?path=${current.displayPath}\">${current.name}</a>" escapeXml="false" />
		</c:otherwise>

              </c:choose>
        </rl:column>
            <rl:column headerkey="cobbler.snippet.macro">
		<c:out value="${current.fragment}"/>
            </rl:column>
      </rl:list>
     </rl:listset>

		<rhn:tooltip key="cobbler.snippet.copy-paste-snippet-tip"/>

</body>
</html>

