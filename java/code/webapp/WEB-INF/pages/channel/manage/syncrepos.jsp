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
                <button type="submit" name="dispatch" value="<bean:message key='repos.jsp.button-sync'/>"
                        class="btn btn-success"
                        <c:if test="${inactive}">disabled="disabled"</c:if>>
                    <rhn:icon type="repo-sync"/>
                    <bean:message key='repos.jsp.button-sync'/>
                </button>
            </div>
            <rhn:submitted/>

            <jsp:include page="/WEB-INF/pages/common/fragments/repeat-task-picker.jspf">
                <jsp:param name="widget" value="date"/>
            </jsp:include>

            <div class="text-right">
                <button type="submit" value="<bean:message key='schedule.button'/>" class="btn btn-default"
                        name="dispatch" <c:if test="${inactive}">disabled="disabled"</c:if> >
                    <rhn:icon type="repo-schedule-sync"/>
                    <bean:message key="schedule.button"/>
                </button>
            </div>

        </rl:listset>

    </body>
</html>
