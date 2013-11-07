<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
        <h2><bean:message key="message.Update"/> ${editAddressForm.map.typedisplay}</h2>
        <p><bean:message key="edit_address.jsp.summary"/></p>
        <html:form action="/users/EditAddressSubmit" styleClass="form-horizontal">
            <rhn:csrf />
            <%@ include file="/WEB-INF/pages/common/fragments/user/edit_address_form.jspf" %>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <button type="submit" class="btn btn-success" value="<bean:message key='message.Update'/>">
                            <bean:message key="message.Update" />
                    </button>
                </div>
            </div>
            <html:hidden property="uid" />
            <html:hidden property="type"/>
        </html:form>
    </body>
</html>
