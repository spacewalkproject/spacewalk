<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html>
    <body>
        <rhn:toolbar base="h1" icon="spacewalk-icon-software-channels"
                     deletionUrl="/rhn/admin/DeleteSchedule.do?schid=${param.schid}"
                     deletionAcl="user_role(satellite_admin); formvar_exists(schid)"
                     deletionType="schedule">
            <bean:message key="schedule.edit.jsp.toolbar" arg0="${schedulename}"/>
        </rhn:toolbar>
        <html:form action="/admin/ScheduleDetail" styleClass="form-horizontal">
            <rhn:csrf/>
            <h2><bean:message key="schedule.edit.jsp.basicscheduledetails"/></h2>
            <p>
                <c:if test="${empty param.schid or active}">
                    <bean:message key="schedule.edit.jsp.introparagraph"/>
                </c:if>
                <c:if test="${not empty param.schid and not active}">
                    <bean:message key="schedule.edit.jsp.notactive"/>
                </c:if>
            </p>

            <div class="form-group">
                <label for="joblabel" class="col-lg-3 control-label">
                    <rhn:required-field key="schedule.edit.jsp.name"/>:
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test='${empty param.schid}'>
                            <html:text property="schedulename" maxlength="256"
                                       styleClass="form-control"
                                       size="48" styleId="name"/>
                        </c:when>
                        <c:otherwise>
                            <div class="form-control">
                                <c:out value="${schedulename}"/>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="form-group">
                <label for="bunch" class="col-lg-3 control-label">
                    <rhn:required-field key="schedule.edit.jsp.bunch"/>:
                </label>
                <div class="col-lg-6">
                    <c:choose>
                        <c:when test='${empty param.schid}'>
                            <html:select property="bunch" styleClass="form-control">
                                <html:options collection="bunches"
                                              property="value"
                                              labelProperty="label" />
                            </html:select>
                        </c:when>
                        <c:otherwise>
                            <a href="/rhn/admin/BunchDetail.do?label=${bunch}" class="btn btn-default">${bunch}</a>
                        </c:otherwise>
                    </c:choose>
                    <html:hidden property="bunch" value="${bunch}" />
                </div>
            </div>

            <c:if test="${empty param.schid or active}">
                <div class="form-group">
                    <label for="parent" class="col-lg-3 control-label">
                        <bean:message key="schedule.edit.jsp.frequency"/>:
                    </label>
                    <div class="">
                        <jsp:include page="/WEB-INF/pages/common/fragments/repeat-task-picker.jspf">
                            <jsp:param name="widget" value="date"/>
                        </jsp:include>
                    </div>
                </div>
            </c:if>
                    <c:if test="${not active}">
                        <c:if test="${cron}">
                            <div class="form-group">
                                <label class="col-lg-3 control-label">
                                    <bean:message key="schedule.edit.jsp.frequency"/>
                                </label>
                                <div class="col-lg-6">
                                    <div class="form-control">
                                        <c:out value="${cronexpr}"/>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                        <c:if test='${not empty param.schid}'>
                            <div class="form-group">
                                <label class="col-lg-3 control-label">
                                    <bean:message key="schedule.edit.jsp.activetill"/>:
                                </label>
                                <div class="col-lg-6">
                                    <fmt:formatDate pattern="yyyy-MM-dd HH:mm:ss z" value="${activetill}"/>
                                </div>
                            </div>
                        </c:if>
                    </c:if>

                    <div class="form-group">
                        <div class="col-lg-offset-3 col-lg-6">
                            <c:choose>
                                <c:when test='${empty param.schid}'>
                                    <html:submit property="create_button" styleClass="btn btn-success">
                                        <bean:message key="schedule.edit.jsp.createschedule"/>
                                    </html:submit>
                                </c:when>
                                <c:otherwise>
                                    <c:if test="${active}">
                                        <html:submit property="edit_button" styleClass="btn btn-success">
                                            <bean:message key="schedule.edit.jsp.editschedule"/>
                                        </html:submit>
                                    </c:if>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <html:hidden property="submitted" value="true" />
                    <c:if test='${not empty param.schid}'>
                        <html:hidden property="schid" value="${param.schid}" />
                    </c:if>
        </html:form>
    </body>
</html>
