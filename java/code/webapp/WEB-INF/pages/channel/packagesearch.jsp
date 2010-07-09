<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
<script type="text/javascript" src="/javascript/highlander.js"></script>
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-search.gif" imgAlt="packagesearch.jsp.imgAlt"
               helpUrl="/rhn/help/reference/en-US/s1-sm-channels-packages.jsp#s2-sm-software-search">
    <bean:message key="packagesearch.jsp.toolbar"/>
  </rhn:toolbar>

  <p><bean:message key="packagesearch.jsp.pagesummary"/></p>

  <p><bean:message key="packagesearch.jsp.instructions"/></p>

  <html:form action="/channels/software/Search.do">

  <!-- Search Box -->
    <div class="search-choices">

       <div class="search-choices-group">
         <table class="details">
           <tr><th><bean:message key="packagesearch.jsp.searchfor"/></th>
             <td>
               <html:text property="search_string" name="search_string" value="${search_string}" />
               <html:submit>
                 <bean:message key="button.search" />
               </html:submit>
             </td>
           </tr>
           <tr><th><bean:message key="packagesearch.jsp.whatsearch"/></th>
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
           <tr><th><bean:message key="packagesearch.jsp.wheresearch"/></th>
             <td rowspan="2">

                 <div style="text-align: left;">
                    <input type="radio" name="whereCriteria" value="relevant" <c:if test="${whereCriteria eq 'relevant'}">checked</c:if> /><bean:message key="packagesearch.jsp.relevant"/>
                 </div>
                 <div style="text-align: left;">
                   <input type="radio" name="whereCriteria" value="channel" <c:if test="${whereCriteria eq 'channel'}">checked</c:if> /><bean:message key="packagesearch.jsp.specificchannel"/><br/>
                   <div style="margin-left: 30px; margin-top: 5px;">
                     <html:select property="channel_filter">
                         <html:options collection="allChannels"
                                       property="id"
                                       labelProperty="name" />
                     </html:select><br/>
                   </div>
                 </div>
                 <div style="text-align: left;">
                    <input type="radio" name="whereCriteria" value="architecture" <c:if test="${whereCriteria eq 'architecture'}">checked</c:if> /><bean:message key="packagesearch.jsp.specificarch"/><br/>
                    <div style="margin-left: 30px; margin-top: 5px;">
                     <html:select property="channel_arch" multiple="multiple"
                                  size="5" onclick="javascript:highlander(this);">
                         <html:options collection="channelArches"
                                       property="value"
                                       labelProperty="display" />
                     </html:select><br/>

                     <bean:message key="packagesearch.jsp.searchwherelegend"/>
                    </div>
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
  <c:forEach items="${requestScope.channel_arch}" var="item">
    <c:set var="archparams" value="${archparams}&channel_arch=${item}"/>
  </c:forEach>
  <rl:listset name="searchSet">
    <rl:list name="searchResults" dataset="pageList"
             emptykey="packagesearch.jsp.nopackages" width="100%"
             filter="com.redhat.rhn.frontend.action.channel.PackageNameFilter">
      <rl:decorator name="PageSizeDecorator"/>
      <rl:column bound="false" sortable="false" headerkey="packagesearch.jsp.name" styleclass="first-column">
        <a href="/rhn/software/packages/NameOverview.do?package_name=${current.urlEncodedPackageName}${archparams}&search_subscribed_channels=${requestScope.relevant}&channel_filter=${requestScope.channel_filter}">
            <rhn:highlight tag="strong" text="${search_string}">
                ${current.packageName}
            </rhn:highlight>
        </a>
      </rl:column>
      <rl:column bound="false" sortable="false" headerkey="packagesearch.jsp.summary" styleclass="last-column">
        <c:choose>
          <c:when test="${param.view_mode != 'search_name'}">
            <rhn:highlight tag="strong" text="${search_string}">
              ${current.summary}
            </rhn:highlight>
          </c:when>
          <c:otherwise>
             ${current.summary}
          </c:otherwise>
        </c:choose>

      </rl:column>
    </rl:list>
    <rl:csv dataset="pageList"
            name="searchResults"
            exportColumns="packageName,summary"/>

    <!-- there are two forms here, need to keep the formvars around for pagination -->
    <input type="hidden" name="submitted" value="true" />
    <input type="hidden" name="search_string" value="${search_string}" />
    <input type="hidden" name="view_mode" value="${view_mode}" />
    <input type="hidden" name="whereCriteria" value="${whereCriteria}" />
    <input type="hidden" name="channel_filter" value="${channel_filter}" />

    <c:forEach items="${requestScope.channel_arch}" var="item">
    <input type="hidden" name="channel_arch" value="${item}" />
    </c:forEach>

  </rl:listset>

  </c:if>
</body>
</html>
