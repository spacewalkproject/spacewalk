<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
    <head>
    </head>
    <body>
        <rhn:toolbar base="h1" icon="header-user"
                     helpUrl=""
                     imgAlt="users.jsp.imgAlt">
            <bean:message key="details.jsp.account_details" />
        </rhn:toolbar>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4><bean:message key="details.jsp.personal_info" /></h4>
            </div>
            <div class="panel-body">
                <p><bean:message key="yourdetails.jsp.summary" /></p>
                <hr />
                <html:form action="/account/UserDetailsSubmit" styleClass="form-horizontal">
                    <rhn:csrf />
                    <%@ include file="/WEB-INF/pages/common/fragments/user/edit_user_table_rows.jspf"%>
                    <div class="form-group">
                        <label class="col-sm-3 control-label"><bean:message key="created.displayname"/></label>
                        <div class="col-sm-6">
                            <rhn:formatDate humanStyle="calendar" value="${created}"
                                        type="both" dateStyle="short" timeStyle="long"/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-3 control-label"><bean:message key="last_sign_in.displayname"/></label>
                        <div class="col-sm-6">
                            <c:choose>
                                <c:when test="${empty lastLoggedIn}">
                                    <bean:message key="neverinparens" />
                                </c:when>
                                <c:otherwise>
                                    <rhn:formatDate humanStyle="from" value="${lastLoggedIn}"
                                                type="both" dateStyle="short" timeStyle="long"/>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-sm-offset-3 col-sm-6">
                            <button type="submit" value="<bean:message key='message.Update'/>"
                                <c:choose>
                                   <c:when test="${empty mailableAddress}">
                                       disabled class="btn"
                                   </c:when>
                                   <c:otherwise>
                                       class="btn btn-success"
                                    </c:otherwise>
                                </c:choose>
                            >
                                <bean:message key="message.Update"/>
                            </button>
                        </div>
                    </div>
                    <html:hidden property="uid"/>
                </html:form>
            </div>
        </div>
    </body>
</html>
