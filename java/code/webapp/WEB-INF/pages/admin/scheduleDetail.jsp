<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-channels.gif"
             deletionUrl="/rhn/admin/DeleteSchedule.do?schid=${param.schid}"
             deletionAcl="user_role(satellite_admin); formvar_exists(schid)"
             deletionType="schedule">
  <bean:message key="schedule.edit.jsp.toolbar" arg0="${schedulename}"/>
</rhn:toolbar>

<div>
   <html:form action="/admin/ScheduleDetail">

   <h2><bean:message key="schedule.edit.jsp.basicscheduledetails"/></h2>
   <div class="page-summary">
      <c:if test="${empty param.schid or active}">
          <bean:message key="schedule.edit.jsp.introparagraph"/>
      </c:if>
      <c:if test="${not empty param.schid and not active}">
          <bean:message key="schedule.edit.jsp.notactive"/>
      </c:if>
   </div>

   <br/>

   <table class="details">
      <tr>
         <th nowrap="nowrap">
            <label for="joblabel"><rhn:required-field key="schedule.edit.jsp.name"/>:</label>
         </th>
         <td class="small-form">
           <c:choose>
             <c:when test='${empty param.schid}'>
               <html:text property="schedulename" maxlength="256" size="48" styleId="name"/>
             </c:when>
             <c:otherwise>
                <c:out value="${schedulename}"/>
             </c:otherwise>
           </c:choose>
         </td>
      </tr>
      <tr>
         <th nowrap="nowrap">
            <label for="bunch"><rhn:required-field key="schedule.edit.jsp.bunch"/>:</label>
         </th>
         <td class="small-form">
             <c:choose>
               <c:when test='${empty param.schid}'>
                   <html:select property="bunch" >
                       <html:options collection="bunches"
                                     property="value"
                                     labelProperty="label" />
                   </html:select>
               </c:when>
               <c:otherwise>
                  <a href="/rhn/admin/BunchDetail.do?label=${bunch}">${bunch}</a>
               </c:otherwise>
             </c:choose>
             <html:hidden property="bunch" value="${bunch}" />
         </td>
      </tr>
      <c:if test="${empty param.schid or active}">
          <tr>
             <th nowrap="nowrap">
                <label for="parent"><bean:message key="schedule.edit.jsp.frequency"/>:</label>
             </th>
             <td class="small-form">
                <jsp:include page="/WEB-INF/pages/common/fragments/repeat-task-picker.jspf">
                   <jsp:param name="widget" value="date"/>
                </jsp:include>
             </td>
          </tr>
      </c:if>
      <c:if test="${not active}">
          <c:if test="${cron}">
              <tr>
                  <th nowrap="nowrap">
                      <bean:message key="schedule.edit.jsp.frequency"/>
                  </th>
                  <td class="small-form">
                      <c:out value="${cronexpr}"/>
                  </td>
              </tr>
          </c:if>
        <c:if test='${not empty param.schid}'>
          <tr>
             <th nowrap="nowrap">
                <bean:message key="schedule.edit.jsp.activetill"/>:
             </th>
             <td class="small-form">
               <fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss z" value="${activetill}"/>
             </td>
          </tr>
        </c:if>
      </c:if>
   </table>

   <div align="right">
      <hr />
      <c:choose>
         <c:when test='${empty param.schid}'>
         <html:submit property="create_button">
            <bean:message key="schedule.edit.jsp.createschedule"/>
         </html:submit>
         </c:when>
         <c:otherwise>
            <c:if test="${active}">
              <html:submit property="edit_button">
                <bean:message key="schedule.edit.jsp.editschedule"/>
              </html:submit>
            </c:if>
         </c:otherwise>
      </c:choose>
   </div>

   <html:hidden property="submitted" value="true" />
   <c:if test='${not empty param.schid}'>
       <html:hidden property="schid" value="${param.schid}" />
   </c:if>
</html:form>
</div>

</body>
</html>
