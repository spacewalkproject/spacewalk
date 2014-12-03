<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ include file="/WEB-INF/pages/common/fragments/user/user_attribute_sizes.jspf"%>

<html>
    <body>
        <rhn:toolbar base="h1" icon="header-user"
                     helpUrl=""
                     imgAlt="users.jsp.imgAlt">
            <bean:message key="yourchangeemail.jsp.title"/>
        </rhn:toolbar>
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">${pageinstructions}</h3>
            </div>
            <div class="panel-body">
                <html:form action="/account/ChangeEmailSubmit"
                           styleClass="form-horizontal">
                    <rhn:csrf />
                    <div class="form-group">
                        <label class="col-sm-3 control-label">
                            <bean:message key="channel.edit.jsp.emailaddress" />:
                        </label>
                        <div class="col-sm-6">
                            <html:text property="email"
                                       styleClass="form-control"
                                       maxlength="${emailLength}" />
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-sm-offset-3 col-sm-6">
                            <button type="submit" class="btn btn-success" value="${button_label}">
                                ${button_label}
                            </button>
                        </div>
                    </div>

                </html:form>
            </div>
        </div>
    </body>
</html>
