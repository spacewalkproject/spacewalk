<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ include file="/WEB-INF/pages/common/fragments/user/user_attribute_sizes.jspf"%>
<html:xhtml/>
<html>
    <body>
        <rhn:toolbar base="h1" img="/img/rhn-icon-users.gif"
                     helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-sm-your-rhn-account"
                     imgAlt="users.jsp.imgAlt">
            <bean:message key="yourchangeemail.jsp.title"/>
        </rhn:toolbar>
        <p class="lead">${pageinstructions}</p>
        <html:form action="/account/ChangeEmailSubmit"
                   styleClass="form-horizontal">
            <rhn:csrf />
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="channel.edit.jsp.emailaddress" />:
                </label>
                <div class="col-lg-6">
                    <html:text property="email"
                               styleClass="form-control"
                               maxlength="${emailLength}" />
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <button type="submit" class="btn btn-success" value="${button_label}">
                        ${button_label}
                    </button>
                </div>
            </div>
        </html:form>
    </body>
</html>
