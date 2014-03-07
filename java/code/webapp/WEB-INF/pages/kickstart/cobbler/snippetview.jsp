<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<head>
<%@ include file="/WEB-INF/pages/common/fragments/editarea.jspf" %>
</head>

<html:html >
<body>
<rhn:toolbar base="h1" icon="header-info" imgAlt="info.alt.img">
  ${requestScope.snippet.displayName}
</rhn:toolbar>

<form role="form" class="form-horizontal">
    <fieldset>
	<legend><h2><bean:message key="snippetdetails.jsp.header2"/></h2></legend>
	    <div class="form-group">
	    <label class="col-sm-2 control-label">
		<bean:message key="cobbler.snippet.path"/>:
	    </label>
	    <div class="col-sm-6">
		<c:out value="${requestScope.snippet.displayPath}"/><br/>
		<p class="help-block"><rhn:tooltip key="cobbler.snippet.path.tip"/></p>
	    </div>
	    </div>
	    <div class="form-group">
	    <label class="col-sm-2 control-label">
		<bean:message key="cobbler.snippet.macro"/>:
	    </label>
	    <div class="col-sm-6">
		<c:out value="${requestScope.snippet.fragment}"/><br/>
		<p class="help-block"><rhn:tooltip key="cobbler.snippet.copy-paste-snippet-tip"/></p>
	    </div>
	    </div>
	    <div class="form-group">
	    <label class="col-sm-2 control-label">
		<bean:message key="cobbler.snippet.type"/>:
	    </label>
	    <div class="col-sm-6">
		<bean:message key="cobbler.snippet.default"/><br />
		<p class="help-block"><rhn:tooltip key ="cobbler.snippet.default.tip"/></p>
	    </div>
	    </div>
    </fieldset>
</form>
<form role="form" class="form-horizontal">
    <fieldset>
	<legend><h2><bean:message key="snippetcreate.jsp.contents.header"/></h2></legend>

	<div class="form-group">
	    <label class="col-sm-2 control-label">
		<bean:message key="snippetcreate.jsp.contents"/>:
	    </label>
	    <div class="col-sm-6">
		<textarea style="resize:none" class="form-control col-sm-6" rows="24" disabled><c:out value="${data}" escapeXml="true"/>""</textarea>
	    </div>
	</div>

    </fieldset>
</form>
</body>
</html:html>

