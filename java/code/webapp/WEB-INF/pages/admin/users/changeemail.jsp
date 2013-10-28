<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
        <%@ include file="/WEB-INF/pages/common/fragments/user/user_attribute_sizes.jspf"%>
        <rhn:toolbar base="h2" helpUrl="/rhn/help/reference/en-US/s1-sm-users.jsp#s2-sm-user-active">
            <bean:message key="yourchangeemail.jsp.title" />
        </rhn:toolbar>
        <p>${pageinstructions}</p>
        <html:form action="/users/ChangeEmailSubmit.do?uid=${param.uid}"
                   styleClass="form-horizontal">
            <rhn:csrf />
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="channel.edit.jsp.emailaddress" />:
                </label>
                <div class="col-lg-6">
                    <html:text property="email"
                               styleClass="form-control"
                               maxlength="${emailLength}"/>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <button type="submit" class="btn btn-success" value="${button_label}">
                        ${button_label}
                    </button>
                </div>
            </div>
            <html:hidden property="uid"/>
        </html:form>
    </body>
</html>
