<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="name" value="System Details" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><i class="fa spacewalk-icon-patches"></i><bean:message key="errataconfirm.jsp.header"/></h2>

<rhn:systemtimemessage server="${system}" />


<rl:listset name="erratConfirmListSet">
    <rhn:csrf />
    <rhn:submitted />
	<rl:list
			width="100%"
         	styleclass="list"
         	emptykey="erratalist.jsp.noerrata">
         	
    <rl:decorator name="PageSizeDecorator"/>
    <rl:decorator name="ElaborationDecorator"/>

    <rl:column headerkey="erratalist.jsp.type" styleclass="text-align: center;">
      <c:if test="${current.securityAdvisory}">
        <i class="fa fa-lock"></i>
      </c:if>
      <c:if test="${current.bugFix}">
        <i class="fa fa-bug"></i>
      </c:if>
      <c:if test="${current.productEnhancement}">
        <i class="fa  spacewalk-icon-enhancement"></i>
      </c:if>
    </rl:column>

    <rl:column headerkey="erratalist.jsp.advisory">
      <a href="/rhn/errata/details/Details.do?eid=${current.id}">
        ${current.advisoryName}</a>
    </rl:column>

    <rl:column headerkey="erratalist.jsp.synopsis">
      ${current.advisorySynopsis}
    </rl:column>

    <rl:column headerkey="erratalist.jsp.updated">
      ${current.updateDate}
    </rl:column>
  	</rl:list>

	<table class="schedule-action-interface" align="center">
  		<tr>
    		<td><input type="radio" name="use_date" value="false" checked="checked"/></td>
    		<th><bean:message key="syncprofile.jsp.now"/></th>
  		</tr>
  		<tr>
    		<td><input type="radio" name="use_date" value="true" /></td>
    		<th><bean:message key="syncprofile.jsp.than"/></th>
  		</tr>
  		<tr>
    		<th><i class="fa spacewalk-icon-schedule" title="<bean:message key='syncprofile.jsp.selection'/>"></i>
    		</th>
    		<td>
      			 <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
        			<jsp:param name="widget" value="date"/>
			</jsp:include>
    		</td>
  		</tr>
	</table>

  <div class="text-right">
    <hr />
    <html:submit property="dispatch">
      <bean:message key="errataconfirm.jsp.confirm"/>
    </html:submit>
  </div>
  <html:hidden property="sid" value="${param.sid}"/>

</rl:listset>
</body>
</html>
