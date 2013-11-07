<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
<BR>

<h2><i class="fa spacewalk-icon-packages"></i> <bean:message key="header.jsp.errata.sync.packagepush"/></h2>

  <bean:message key="channel.jsp.errata.sync.packages.message"/>

<rl:listset name="packageSet" legend="system-group">

<rhn:csrf />

<input type="hidden" name="cid" value="${cid}" />

	<rl:list
			decorator="SelectableDecorator"
			emptykey="package.jsp.emptylist"
			alphabarcolumn="nvrea"
			filter="com.redhat.rhn.frontend.taglibs.list.filters.PackageFilter" >


			<rl:decorator name="PageSizeDecorator"/>

		    <rl:selectablecolumn value="${current.id}"
								selected="${current.selected}"
								disabled="${not current.selectable}"/>



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
                           headerkey="packagesearch.jsp.summary"
                          >
                        ${current.summary}
                </rl:column>
	</rl:list>

	<div class="text-right">
	  <hr />
		<input type="submit" name="dispatch"
				value="<bean:message key='confirm'/>" />
	</div>
		<rhn:submitted/>


</rl:listset>

</body>
</html>
