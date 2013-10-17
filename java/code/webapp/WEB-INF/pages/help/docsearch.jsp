<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
<script type="text/javascript" src="/javascript/highlander.js"></script>
</head>
<body>
<rhn:toolbar base="h1" icon="icon-search" imgAlt="docsearch.jsp.imgAlt"
               helpUrl="">
    <bean:message key="docsearch.jsp.toolbar"/>
  </rhn:toolbar>

  <p><bean:message key="docsearch.jsp.pagesummary"/></p>

  <p><bean:message key="docsearch.jsp.instructions"/></p>

  <html:form action="/help/Search.do">
  <rhn:csrf />

  <!-- Search Box -->
    <div class="search-choices">

       <div class="search-choices-group">
         <table class="details">
           <tr><th><bean:message key="docsearch.jsp.searchfor"/></th>
             <td>
               <html:text property="search_string" name="search_string" value="${search_string}" accesskey="4"/>
               <button type="submit" class="btn btn-default btn-sm">
                   <span class="glyphicon glyphicon-search" />
                   <bean:message key="button.search"/>
               </button>
             </td>
           </tr>
           <tr><th><bean:message key="docsearch.jsp.whatsearch"/></th>
             <td>
               <div style="text-align: left">
                 <html:select property="view_mode" value="${view_mode}" >
                   <html:options collection="searchOptions"
                                 property="value"
                                 labelProperty="display" />
                 </html:select>
               </div>
             </td>
           </tr>
         </table>
       </div>

    </div>
    <input type="hidden" name="submitted" value="true" />
  </html:form>

  <c:if test="${search_string != null && search_string != ''}">

  <hr />
  <c:set var="pageList" value="${requestScope.pageList}" />
  <!-- collapse the params into a string -->
  <rl:listset name="searchSet">
    <rhn:csrf />
    <rl:list name="searchResults" dataset="pageList"
             emptykey="docsearch.jsp.nopages" width="100%">
      <rl:decorator name="PageSizeDecorator"/>
      <rl:column bound="false" sortable="false" headerkey="docsearch.jsp.pagetitle">
	 <a href="${current.url}">
	     <rhn:highlight tag="strong" text="${search_string}">
	         ${current.title}
	     </rhn:highlight>
	</a>
      </rl:column>
      <rl:column bound="false" sortable="false" headerkey="docsearch.jsp.summary">
     <a href="${current.url}">
         <rhn:highlight tag="strong" text="${search_string}">
             ${current.summary}
         </rhn:highlight>
     </a>
      </rl:column>
    </rl:list>

    <!-- there are two forms here, need to keep the formvars around for pagination -->
    <input type="hidden" name="submitted" value="true" />
    <html:hidden property="search_string" name="search_string" value="${search_string}" />
    <input type="hidden" name="view_mode" value="${view_mode}" />
    <input type="hidden" name="relevant" value="${relevant}" />

  </rl:listset>

  </c:if>

</body>
</html>
