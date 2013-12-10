<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/groups/header.jspf" %>

<h2>
    <bean:message key="systemgroup.admins.title"/>
</h2>

<div class="page-summary">
<bean:message key="systemgroup.admins.summary"/>
</div>

<rl:listset name="groupAdmins">
    <rhn:csrf />
    <input type="hidden" name="sgid" value="${systemgroup.id}" />

    <rl:list>

        <rl:decorator name="SelectableDecorator"/>
        <rl:decorator name="PageSizeDecorator"/>

        <rl:selectablecolumn value="${current.id}"
            selected="${current.selected}"
            disabled="${current.disabled}">
        </rl:selectablecolumn>

         <rl:column sortable="true"
            bound="false"
            headerkey="username.nopunc.displayname"
            sortattr="login"
            filterattr="name"
            defaultsort="asc" >

            <a href="/rhn/users/UserDetails.do?uid=${current.id}">
                ${current.login}
            </a>
         </rl:column>

         <rl:column sortable="false"
            bound="false"
            headerkey="realname.displayname" >
            ${current.userLastName}, ${current.userFirstName}
         </rl:column>

         <rl:column sortable="true"
            sortattr="status"
            bound="false"
            headerkey="userlist.jsp.status" >
            ${current.status}
         </rl:column>

    </rl:list>

    <div class="text-right">
        <hr />
        <input type="submit" name="confirm"
                value="<bean:message key='message.Update'/>" />
    </div>
    <rhn:submitted/>

</rl:listset>

</body>
</html>
