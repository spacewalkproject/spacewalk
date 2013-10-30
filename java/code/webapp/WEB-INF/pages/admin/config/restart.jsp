<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >

<head>
	<c:if test="${requestScope.restart == 'true'}">
	    <script src="/javascript/restart.js" type="text/javascript"> </script>
	</c:if>
</head>
<body  <c:if test="${requestScope.restart == 'true'}">onload="checkConnection(${requestScope.restartDelay})"</c:if> >
    <rhn:toolbar base="h1" icon="fa-info-circle" imgAlt="info.alt.img">
      <bean:message key="restart.jsp.toolbar"/>
    </rhn:toolbar>
    <p>
        <bean:message key="restart.jsp.summary"/>
    </p>
    <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/sat_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
    <div class="panel panel-default">
        <div class="panel-heading">
            <h4><bean:message key="restart.jsp.header2"/></h4>
        </div>

        <div class="panel-body">
            <html:form action="/admin/config/Restart">
                <rhn:csrf />
                <div class="row">
                    <div class="col-md-2 text-right">
                        <label for="restart"><bean:message key="restart.jsp.restart_satellite"/></label>
                    </div>
                    <div class="col-md-10">
                        <html:checkbox property="restart" styleId="restart" />
                    </div>
                </div>
                <hr />
                <div class="row">
                    <div class="col-md-offset-2 col-md-10">
                        <html:submit styleClass="btn btn-success"><bean:message key="restart.jsp.restart"/></html:submit>
                    </div>
                </div>
            <rhn:submitted/>
            </html:form>
        </div>
    </div>
</body>
</html:html>

