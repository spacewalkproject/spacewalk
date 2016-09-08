<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>

<h2><rhn:icon type="header-package" /> <bean:message key="repos.jsp.channel.repos"/></h2>
<rhn:icon type="item-add" /><bean:message key="repos.jsp.createRepo"
                                          arg0="/rhn/channels/manage/repos/RepoCreate.do?cid=${cid}"/>

<rl:listset name="packageSet">
<rhn:csrf />

<rhn:hidden name="cid" value="${cid}" />

        <rl:list
                        decorator="SelectableDecorator"
                        emptykey="repos.jsp.norepos"
                        alphabarcolumn="label"
         >

                        <rl:decorator name="PageSizeDecorator"/>

                    <rl:selectablecolumn value="${current.id}"/>

                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="repos.jsp.channel.header"
                           sortattr="label"
                           defaultsort="asc">
                        <a href="/rhn/channels/manage/repos/RepoEdit.do?id=${current.id}">${current.label}</a>
                </rl:column>

        </rl:list>
        <div class="text-right">
          <hr />
                <input class="btn btn-default" type="submit" name="dispatch"
                                value="<bean:message key='repos.jsp.update.channel'/>" />
        </div>
                <rhn:submitted/>

</rl:listset>

</body>
</html>
