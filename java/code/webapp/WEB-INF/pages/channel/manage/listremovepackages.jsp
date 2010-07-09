<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
<BR>

<h2><img src="/img/rhn-icon-packages.gif"> <bean:message key="channel.jsp.package.list"/></h2>



<rl:listset name="packageSet" legend="system-group">

<input type="hidden" name="cid" value="${cid}" />

	<rl:list dataset="pageList"
			name="packageList"
			decorator="SelectableDecorator"
			emptykey="package.jsp.emptylist"
			alphabarcolumn="nvrea"
			filter="com.redhat.rhn.frontend.taglibs.list.filters.PackageFilter" >


			<rl:decorator name="PageSizeDecorator"/>

		    <rl:selectablecolumn value="${current.id}"
								selected="${current.selected}"
								disabled="${not current.selectable}"
								styleclass="first-column"/>



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

                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="package.jsp.provider"
                           styleclass="last-column"
                          >
                        ${current.provider}
                </rl:column>

	</rl:list>
	<rl:csv dataset="pageList"
		        name="packageList"
		        exportColumns="id, nvrea, provider" />
	<div align="right">
	  <hr />
		<input type="submit" name="confirm"
				value="<bean:message key="channel.jsp.package.removebutton"/>" />
	</div>
		<rhn:submitted/>


</rl:listset>

</body>
</html>