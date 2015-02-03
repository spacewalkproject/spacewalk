<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://struts.apache.org/tags-bean"     prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html"     prefix="html"%>


<html>
<head></head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/manage_header.jspf"%>

<html:form action="/configuration/file/DeleteFile.do?cfid=${cfid}">
    <rhn:csrf />
    <html:hidden property="submitted" value="true"/>
    <div class="panel panel-default">
      <div class="panel-heading">
        <h2><bean:message key="deletefile.jsp.header2" /></h2>
        <bean:message key="deletefile.jsp.info" />
      </div>
      <ul class="list-group">
        <li class="list-group-item">
          <div class="row">
            <div class="col-xs-1 col-sm-2"><strong><bean:message key="deleterev.jsp.channelname" /></strong></div>
            <div class="col-xs-11 col-sm-10">${file.configChannel.displayName}</div>
          </div>
        </li>
        <li class="list-group-item">
          <div class="row">
            <div class="col-xs-1 col-sm-2"><strong><bean:message key="deleterev.jsp.revisionpath" /></strong></div>
            <div class="col-xs-11 col-sm-10">${file.configFileName.path}</div>
          </div>
        </li>
        <c:if test="${!revision.directory}">
          <li class="list-group-item">
            <div class="row">
              <div class="col-xs-1 col-sm-2"><strong><bean:message key="deletefile.jsp.totalspace" /></strong></div>
              <div class="col-xs-11 col-sm-10">${storage}</div>
            </div>
          </li>
        </c:if>
      </ul>
    </div>
    <hr />
    <div class="text-right">
      <html:submit styleClass="btn btn-primary"><bean:message key="deletefile.jsp.submit" /></html:submit>
    </div>
</html:form>

</body>
</html>
