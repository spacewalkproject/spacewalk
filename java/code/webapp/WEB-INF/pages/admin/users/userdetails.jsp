<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html >
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
        <html:form action="/users/UserDetailsSubmit?uid=${user.id}" styleClass="form-horizontal">
            <div class="panel panel-default">
                <rhn:csrf />
                <div class="panel-heading">
                    <h4><bean:message key="userdetails.jsp.header"/></h4>
                </div>
                <div class="panel-body">
                    <p><bean:message key="userdetails.jsp.summary"/></p>
                    <hr/>
                    <%@ include file="/WEB-INF/pages/common/fragments/user/edit_user_table_rows.jspf"%>
                    <div class="form-group">
                        <label class="col-lg-3 control-label"><bean:message key="userdetails.jsp.adminRoles"/>:</label>
                        <div class="col-lg-6">
                            <c:forEach items="${adminRoles}" var="role">
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" name="role_${role.value}"
                                               <c:if test="${role.selected}">checked="true"</c:if>
                                               <c:if test="${role.disabled}">disabled="true"</c:if>/>
                                        ${role.name}
                                    </label>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="userdetails.jsp.roles"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:forEach items="${regularRoles}" var="role">
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" name="role_${role.value}"
                                               <c:if test="${role.selected}">checked="true"</c:if>
                                               <c:if test="${role.disabled}">disabled="true"</c:if>/>
                                        ${role.name}
                                    </label>
                                </div>
                            </c:forEach>
                            <c:if test="${orgAdmin}">
                                <p class="form-control-static">
                                    <small><bean:message key="userdetails.jsp.grantedByOrgAdmin"/></small>
                                </p>
                            </c:if>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="created.displayname"/>
                        </label>
                        <div class="col-lg-6">
                            <p class="form-control-static">
                                ${created}
                            </p>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="last_sign_in.displayname"/>
                        </label>
                        <div class="col-lg-6">
                             <p class="form-control-static">
                                 ${lastLoggedIn}
                             </p>
                        </div>
                    </div>

                    <input type="hidden" name="disabledRoles" value="${disabledRoles}"/>

                    <div class="form-group">
                        <div class="col-lg-offset-3 col-lg-6">
                            <c:choose>
                                <c:when test="${!empty mailableAddress}">
                                    <button type="submit" class="btn btn-success">
                                        <bean:message key="button.update"/>
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <button type="button" class="btn" disabled>
                                        <bean:message key="button.update"/>
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </html:form>
    </body>
</html:html>
