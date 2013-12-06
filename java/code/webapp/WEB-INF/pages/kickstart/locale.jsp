<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>
        <rhn:dialogmenu mindepth="0" maxdepth="1"
                        definition="/WEB-INF/nav/kickstart_details.xml"
                        renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <h2><bean:message key="kickstart.locale.jsp.header1"/></h2>
        <p><bean:message key="kickstart.locale.jsp.summary1"/></p>
        <html:form method="post" action="/kickstart/LocaleEdit.do" styleClass="form-horizontal">
            <rhn:csrf />
            <html:hidden property="ksid" value="${ksdata.id}"/>
            <html:hidden property="submitted" value="true"/>
                <div class="form-group">
                    <label class="col-md-3 control-label">
                        <bean:message key="kickstart.locale.jsp.timezone" />
                    </label>
                    <div class="col-md-6">
                        <html:select property="timezone" styleClass="form-control">
                            <html:options collection="timezones"
                                          property="value"
                                          labelProperty="display" />
                        </html:select>
                    </div>
                </div>
                <div class="form-group">
                    <div class="col-md-offset-3 col-md-6">
                        <div class="checkbox">
                            <label>
                                <html:checkbox property="use_utc"/>
                                <bean:message key="kickstart.locale.jsp.hardwareclock" />
                            </label>
                        </div>
                    </div>
                </div>
                <div class="form-group">
                    <div class="col-md-offset-3 col-md-6">
                        <html:submit styleClass="btn btn-success">
                            <bean:message key="kickstart.locale.jsp.updatekickstart"/>
                        </html:submit>
                    </div>
                </div>
        </html:form>
    </body>
</html:html>

