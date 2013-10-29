<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html xhtml="true">
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
        <div class="panel panel-default">
            <html:form action="/users/UserDetailsSubmit?uid=${user.id}" styleClass="form-horizontal">
                <rhn:csrf />
                <div class="panel-heading">
                    <h4><bean:message key="userdetails.jsp.header"/></h4>
                    <p><bean:message key="userdetails.jsp.summary"/></p>
                </div>
                <div class="panel-body">
                    <%@ include file="/WEB-INF/pages/common/fragments/user/edit_user_table_rows.jspf"%>
                    <div class="form-group">
                        <label class="col-lg-3 control-label"><bean:message key="userdetails.jsp.adminRoles"/>:</label>
                        <div class="col-lg-6">
                            <c:forEach items="${adminRoles}" var="role">
                                <label>
                                    <input type="checkbox" name="role_${role.value}"
                                           <c:if test="${role.selected}">checked="true"</c:if>
                                           <c:if test="${role.disabled}">disabled="true"</c:if>/>
                                    ${role.name}
                                </label>
                            </c:forEach>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="userdetails.jsp.roles"/>:
                        </label>
                        <div class="col-lg-6">
                            <c:forEach items="${regularRoles}" var="role">
                                <label>
                                    <input type="checkbox" name="role_${role.value}"
                                           <c:if test="${role.selected}">checked="true"</c:if>
                                           <c:if test="${role.disabled}">disabled="true"</c:if>/>
                                    ${role.name}
                                </label>
                            </c:forEach>
                            <c:if test="${orgAdmin}">
                                
                                <bean:message key="userdetails.jsp.grantedByOrgAdmin"/>
                            </c:if>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="created.displayname"/>
                        </label>
                        <label class="col-lg-6">
                            ${created}
                        </label>
                    </div>

                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="last_sign_in.displayname"/>
                        </label>
                        <label class="col-lg-6">
                            ${lastLoggedIn}
                        </label>
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
                                    <button type="button" class="btn btn-success" disabled="disabled">
                                        <bean:message key="button.update"/>
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </html:form>
        </div>
    </body>
</html:html>
