<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
<body>
<rhn:toolbar base="h1" icon="header-channel">
    <bean:message key="schedule.edit.jsp.toolbar" arg0="${schedulename}"/>
</rhn:toolbar>

<div>
    <html:form action="/admin/DeleteSchedule">
        <rhn:csrf/>

        <h2><bean:message key="schedule.delete.jsp.deleteschedule"/></h2>

        <div class="page-summary">
            <p><bean:message key="schedule.delete.jsp.introparagraph"/></p>
        </div>

        <table class="details">
            <!-- Channel Name -->
            <tr>
                <th nowrap="nowrap">
                    <bean:message key="schedule.edit.jsp.name"/>:
                </th>
                <td class="small-form">
                    <strong><c:out value="${schedulename}"/></strong>
                </td>
            </tr>

            <tr>
                <th nowrap="nowrap">
                    <bean:message key="schedule.edit.jsp.bunch"/>:
                </th>
                <td class="small-form">
                    <c:out value="${bunch}"/>
                </td>
            </tr>
            <c:if test="${cronexpr}">
                <tr>
                    <th nowrap="nowrap">
                        <bean:message key="schedule.edit.jsp.frequency"/>
                    </th>
                    <td class="small-form">
                        <c:out value="${cronexpr}"/>
                    </td>
                </tr>
            </c:if>
        </table>

        <div class="text-right">
            <hr/>
             <html:submit property="edit_button">
                <bean:message key="schedule.delete.jsp.deleteschedule"/>
             </html:submit>
        </div>
        <html:hidden property="submitted" value="true"/>
        <c:if test='${not empty param.schid}'>
            <html:hidden property="schid" value="${param.schid}"/>
        </c:if>
    </html:form>
</div>

</body>
</html>
