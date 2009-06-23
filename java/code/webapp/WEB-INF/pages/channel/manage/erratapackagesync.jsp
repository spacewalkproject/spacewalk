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

<html:errors/>
<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<html:errors/>
<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

 <%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
<BR>

<h2><img src="/img/rhn-icon-packages.gif"> <bean:message key="header.jsp.errata.sync.packagepush"/></h2>

  <bean:message key="channel.jsp.errata.sync.packages.message"/>

<rl:listset name="packageSet" legend="system-group">

<input type="hidden" name="cid" value="${cid}" />

	<rl:list
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
                           styleclass="last-column"
                          >
                        ${current.summary}
                </rl:column>
	</rl:list>

	<div align="right">
	  <hr />
		<input type="submit" name="dispatch"
				value="<bean:message key="confirm"/>" />
	</div>
		<rhn:submitted/>


</rl:listset>

</body>
</html>