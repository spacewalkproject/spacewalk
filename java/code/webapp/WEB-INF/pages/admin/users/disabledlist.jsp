<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
</head>
<body>
<rhn:toolbar base="h1" icon="header-user" imgAlt="users.jsp.imgAlt"
 helpUrl=""
 creationUrl="/rhn/users/CreateUser.do"
 creationType="user">
  <bean:message key="disabledlist.jsp.title"/>
</rhn:toolbar>

<c:set var="pageList" value="${requestScope.pageList}" />

<rl:listset name="disabledUserListSet">
    <rhn:csrf />
    <rhn:submitted />
        <rl:list dataset="pageList"
         width="100%"
         name="disabledUserList"
         decorator="SelectableDecorator"
         filter="com.redhat.rhn.frontend.action.multiorg.UserListFilter"
         styleclass="list"
         emptykey="disabledlist.jsp.noUsers"
                 alphabarcolumn="userLogin">

                <rl:selectablecolumn value="${current.id}"
                        selected="${current.selected}"
                        disabled="${not current.selectable}"/>

                <rl:column bound="false"
                        sortable="true"
                        headerkey="username.nopunc.displayname"
                        sortattr="userLogin">
                        <c:out value="<a href=\"UserDetails.do?uid=${current.id}\">${current.userLogin}</a>" escapeXml="false" />
                </rl:column>


                <rl:decorator name="PageSizeDecorator"/>

                <%@ include file="/WEB-INF/pages/common/fragments/user/userlist_columns.jspf" %>

            <rl:column
                headerkey="disabledlist.jsp.disabledBy">
                <c:out value="${current.changedByFirstName} ${current.changedByLastName}" />
            </rl:column>

            <rl:column headerkey="disabledlist.jsp.disabledOn"
                bound="true"
                attr="changeDateString"
                sortattr="changeDate"/>

        </rl:list>
        <div class="row">
                <div class="col-xs-6 text-left">
                        <input type="submit" class="btn btn-success" name="dispatch" value="<bean:message key='disabledlist.jsp.reactivate'/>" />
                </div>
                <div class="col-xs-6 text-right">
                        <rl:csv dataset="pageList"
                                name="disabledUserList"
                                exportColumns="userLogin,userLastName,userFirstName,email,roleNames,lastLoggedIn,changedByFirstName,changedByLastName,changeDate"/>
                </div>
        </div>

</rl:listset>

<rhn:submitted/>
</body>
</html>
