<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html xhtml="true">
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_header.jspf" %>
<BR>




<div>
  <h2><img src="/img/rhn-icon-packages.gif"> <bean:message key="systemlist.jsp.packages"/></h2>
    <bean:message key="package.jsp.list"/>



    <rl:listset name="packageSet">

    <input type="hidden" name="cid" value="${cid}" />

    	<rl:list dataset="pageList"
    	         name="packageList"
                emptykey="package.jsp.emptylist"
                alphabarcolumn="nvrea"
                  filter="com.redhat.rhn.frontend.taglibs.list.filters.PackageFilter">

            <rl:decorator name="PageSizeDecorator"/>

                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="download.jsp.package"
                           sortattr="nvrea"
					defaultsort="asc"
                           styleclass="first-column">

                        <a href="/rhn/software/packages/Details.do?pid=${current.id}">${current.nvrea}</a>
                </rl:column>


                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="packagesearch.jsp.summary"
                          >
                        <c:out value="${current.summary}" />
                </rl:column>

                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="package.jsp.provider"
                           styleclass="last-column"
                          >
                          <c:out value="${current.provider}" />
                </rl:column>


        </rl:list>

	<rl:csv dataset="pageList"
		        name="packageList"
		        exportColumns="id, nvrea, provider" />

    </rl:listset>
    	
    		

</div>

</body>
</html:html>

