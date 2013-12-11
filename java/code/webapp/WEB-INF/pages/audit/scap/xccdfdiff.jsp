<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
</head>
<body>

<rhn:toolbar base="h1" icon="header-search">
  <bean:message key="scapdiff.jsp.toolbar"/>
</rhn:toolbar>

<p><bean:message key="scapdiff.jsp.summary"/></p>

<html:form method="get" action="/audit/scap/DiffSubmit.do">
  <rhn:csrf/>
    <div class="panel panel-default">
      <div class="panel-heading">
        <bean:message key="scapdiff.jsp.instructions"/>
      </div>
      <div class="panel-body">
        <div class="form-group row">
          <div class="col-md-2 text-right">
            <bean:message key="xccdfdiff.firstscan"/>:
          </div>
          <div class="col-md-4">
            <html:text styleClass="form-control" property="first"/>
          </div>
        </div>
        <div class="form-group row">
          <div class="col-md-2 text-right">
            <bean:message key="xccdfdiff.secondscan"/>:
          </div>
          <div class="col-md-4">
            <html:text property="second" styleClass="form-control"/>
          </div>
        </div>
        <div class="form-group row">
          <div class="col-md-offset-2 col-md-4">
            <html:submit styleClass="btn btn-success"><bean:message key="xccdfdiff.schedulescan"/></html:submit>
          </div>
        </div>
      </div>
    </div>
</html:form>

</body>
</html>

