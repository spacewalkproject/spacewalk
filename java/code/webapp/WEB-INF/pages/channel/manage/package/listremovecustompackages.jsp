<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
    <!-- disables the enter key from submitting the form -->
    <script type="text/javascript" language="JavaScript">
      $(document).ready(function() {
        $(window).keydown(function(event){
          if(event.keyCode == 13) {
            event.preventDefault();
            return false;
          }
        });
      });
    </script>
</head>
<body>
<rhn:toolbar base="h1" icon="header-package" iconAlt="overview.jsp.alt"
 helpUrl="/rhn/help/getting-started/en-US/sect-Getting_Started_Guide-Channel_Management-Creating_and_Managing_Custom_Channels-Removing_Software_Packages.jsp">
   <bean:message key="channel.jsp.manage.package.title"/>
</rhn:toolbar>

<rl:listset name="packageSet">
<rhn:csrf />
<bean:message key="channel.jsp.manage.package.message"/>
<h2><bean:message key="channel.jsp.manage.package.subtitle"/></h2>

<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/channel_selector.jspf" %>

		  <rl:list dataset="pageList" name="packageList"
		  decorator="SelectableDecorator"
					emptykey="channel.jsp.package.addemptylist"
					alphabarcolumn="nvrea"
					 filter="com.redhat.rhn.frontend.taglibs.list.filters.PackageFilter"
					>

				<rl:decorator name="ElaborationDecorator"/>
				<rl:decorator name="PageSizeDecorator"/>

				<rl:selectablecolumn value="${current.selectionKey}"
					selected="${current.selected}"/>


                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="download.jsp.package"
                           sortattr="nvrea"
					defaultsort="asc"
                           >

                        <a href="/rhn/software/packages/Details.do?pid=${current.id}">${current.nvrea}</a>
                </rl:column>


                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="channel.jsp.manage.package.channels"
                          >
                          <c:if test="${empty current.packageChannels}">
				(<bean:message key="channel.jsp.manage.package.none"/>)
                          </c:if>

                          <c:forEach var="channel" items="${current.packageChannels}">
				${channel}
				<BR>
                          </c:forEach>

                </rl:column>

                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="package.jsp.provider"
                          >
                        ${current.provider}
                </rl:column>

			  </rl:list>

			<div class="text-right">
			 <input type="submit" name="confirm" value="<bean:message key='channel.jsp.manage.package.confirmbutton'/>"
           <c:choose>
               <c:when test="${empty pageList}">
                   class="btn" disabled
               </c:when>
               <c:otherwise>
                   class="btn btn-default"
               </c:otherwise>
           </c:choose>
        ></input>
			</div>
     <rhn:submitted/>
</rl:listset>
</body>
</html>

