<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/channel_header.jspf" %>

  <h2><i class="spacewalk-icon-packages"></i> <bean:message key="systemlist.jsp.packages"/></h2>
    <bean:message key="package.jsp.list"/>

    <rl:listset name="packageSet">
    <rhn:csrf />
    <rhn:submitted />

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
					defaultsort="asc">

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
                          >
                          <c:out value="${current.provider}" />
                </rl:column>


        </rl:list>

	<rl:csv dataset="pageList"
		        name="packageList"
		        exportColumns="id, nvrea, provider" />

    </rl:listset>

</body>
</html:html>