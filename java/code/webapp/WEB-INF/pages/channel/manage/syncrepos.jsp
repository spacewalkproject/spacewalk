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

<h2><img src="/img/rhn-icon-packages.gif"> <bean:message key="repos.jsp.channel.repos"/></h2>

<rl:listset name="packageSet">

<input type="hidden" name="cid" value="${cid}" />

	<rl:list 
			decorator="SelectableDecorator"
			emptykey="repos.jsp.norepos"
			alphabarcolumn="label"
	 >

			<rl:decorator name="PageSizeDecorator"/>

		    <rl:selectablecolumn value="${current.id}"								
								styleclass="first-column"/>

                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="repos.jsp.channel.header"
                           sortattr="label"
					defaultsort="asc"
                           >

                        <a href="/rhn/channels/manage/repos/RepoEdit.do?id=${current.id}">${current.label}</a>
                </rl:column>

	</rl:list>
	<div align="right">
	  <hr />
		<input type="submit" name="dispatch"
				value="<bean:message key="repos.jsp.update.channel"/>" />
	</div>
		<rhn:submitted/>

</rl:listset>

</body>
</html>