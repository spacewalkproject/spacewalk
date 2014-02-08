<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html>
    <head>
        <script type="text/javascript">
         /*
          * Config option value and help are already
          * concatenated. Split them to display the help
          * in the form correctly.
          */
          $(function() {
            var textMixedWithHelp = /^(.+)\((.+)\)\s*$/;
            $('label').each(function(idx, lbl) {
              var match = textMixedWithHelp.exec($(lbl).html());
              var input = $(lbl).attr('for');
              if (match != null && input != undefined) {
                $("[name='" + input + "']").after(
                  '<span class="help-block">' + match[2] + '</span>'
                );
                $(lbl).html(match[1]);
              }
            });
          });
        </script>
    </head>
    <body>
        <rhn:toolbar base="h1" icon="header-info"
                     helpUrl="">
            <bean:message key="generalconfig.jsp.header1"/>
        </rhn:toolbar>
        <p><bean:message key="generalconfig.jsp.summary"/></p>
        <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <h2><bean:message key="generalconfig.jsp.header2"/></h2>
        <rhn:require acl="user_role(satellite_admin)">
            <html:form action="/admin/config/MonitoringConfig"
                       styleClass="form-horizontal"
                       method="POST">
                <rhn:csrf />
                <div class="form-group">
                    <label class="col-lg-3 control-label" for="is_monitoring_scout">
                         <bean:message key="general.jsp.monitoring_scout"/>
                    </label>
                    <div class="col-lg-6">
                        <div class="checkbox">
                            <html:checkbox property="is_monitoring_scout" styleId="is_monitoring_scout" />
                        </div>
                    </div>
                </div>
                <c:forEach items="${configList}" var="config">
                    <div class="form-group">
                        <label class="col-lg-3 control-label" for="${config.name}">${config.description}</label>
                        <div class="col-lg-6">
                            <input type="text" size="30" name="${config.name}" class="form-control"
                                   value="${config.value}" maxlength="255" styleId="${config.name}" />
                        </div>
                    </div>
                </c:forEach>
                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <html:submit styleClass="btn btn-success">
                            <bean:message key="generalconfig.jsp.update_config"/>
                        </html:submit>
                    </div>
                    <input type="hidden" name="submitted" value="true" />
                </div>
            </html:form>
        </rhn:require>
        <rhn:require acl="not user_role(satellite_admin)">
            <bean:message key="monitoring.jsp.monitoringdisabled"/>
        </rhn:require>
    </body>
</html>

