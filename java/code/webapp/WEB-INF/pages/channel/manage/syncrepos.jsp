<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
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
<rhn:csrf />

<input type="hidden" name="cid" value="${cid}" />

	<rl:list
			emptykey="repos.jsp.channel.norepos"
			alphabarcolumn="label"
	 >

			<rl:decorator name="PageSizeDecorator"/>


                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="repos.jsp.channel.header"
                           sortattr="label"
					defaultsort="asc"
                           >

                        <a href="/rhn/channels/manage/repos/RepoEdit.do?id=${current.id}">${current.label}</a>
                </rl:column>

	</rl:list>
	<div class="text-right">
	  <hr />
		<input type="submit" name="dispatch"
				value="<bean:message key="repos.jsp.button-sync"/>"    <c:if test="${inactive}">disabled="disabled"</c:if>/>
	</div>
		<rhn:submitted/>



      <jsp:include page="/WEB-INF/pages/common/fragments/repeat-task-picker.jspf">
        <jsp:param name="widget" value="date"/>
      </jsp:include>

	<div class="text-right">
				<input type="submit" name="dispatch" <c:if test="${inactive}">disabled="disabled"</c:if>
						value="<bean:message key="schedule.button"/>" />
	</div>

</rl:listset>

</body>
</html>
