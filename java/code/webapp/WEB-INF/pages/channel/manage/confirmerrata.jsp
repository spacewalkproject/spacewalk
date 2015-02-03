<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
</head>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>

<p><bean:message key="channel.manage.errata.confirmmsg"/></p>

<rl:listset name="packageConfirm">
  <rhn:csrf />
  <rhn:submitted />
  <input type="hidden" name="cid" value="${cid}">

  <div class="row-0">
    <div class="col-md-6">
      <div class="panel panel-default">
        <div class="panel-heading">
            <h4><bean:message key="channel.manage.errata.confirm.erratasummary"/></h4>
        </div>
        <div class="panel-body">
          <div class="form-horizontal">
            <div class="form-group">
              <label class="col-md-6">
                <rhn:icon type="errata-bugfix"/>
                <bean:message key="erratalist.jsp.bugadvisory"/>:
              </label>
              <div class="col-md-3">${bug_count}</div>
            </div>
            <div class="form-group">
              <label class="col-md-6">
                <rhn:icon type="errata-enhance"/>
                <bean:message key="erratalist.jsp.productenhancementadvisory"/>:
              </label>
              <div class="col-md-3">${enhance_count}</div>
            </div>
            <div class="form-group">
              <label class="col-md-6">
                <rhn:icon type="errata-security"/>
                <bean:message key="erratalist.jsp.securityadvisory"/>:
              </label>
              <div class="col-md-3">${secure_count}</div>
            </div>
            <div class="form-group">
              <label class="col-md-6"><bean:message key="channel.manage.errata.confirm.totalerrata"/>:</label>
              <div class="col-md-3">${bug_count + enhance_count + secure_count}</div>
            </div>
          </div>
        </div>
      </div>
      <rl:csv  name="errataList" dataset="errataList" exportColumns="advisory, advisorySynopsis, advisoryType, updateDate" />
    </div>
    <div class="col-md-6">
      <div class="panel panel-default">
        <div class="panel-heading">
            <h4><bean:message key="channel.manage.errata.confirm.packagesummary"/></h4>
        </div>
        <div class="panel-body">
          <div class="form-horizontal">
            <c:forEach var="option" items="${arch_count}">
              <div class="form-group">
                <label class="col-md-6">${option.name}</label>
                <div class="col-md-3">${option.size}</div>
              </div>
            </c:forEach>
            <div class="form-group">
              <label class="col-md-6">
                <bean:message key="channel.manage.errata.confirm.totalpackages"/>:
              </label>
              <div class="col-md-3">
                ${totalSize}
              </div>
            </div>
          </div>
        </div>
      </div>
      <rl:csv  name="packageList" dataset="packageList" exportColumns="id,packageName,packageNvre,packageArch,summary" />
    </div>
  </div>

  <div class="text-right">
    <hr />
    <input class="btn btn-default" type="submit" name="dispatch"  value="<bean:message key='frontend.actions.channels.manager.add.submit'/>"
      <c:choose>
        <c:when test="${totalSize < 1}">disabled</c:when>
      </c:choose>
    >
  </div>
</rl:listset>


</body>
</html>
