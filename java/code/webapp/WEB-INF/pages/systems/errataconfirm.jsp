<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="name" value="System Details" />
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<h2><img src="/img/rhn-icon-errata.gif" /><bean:message key="errataconfirm.jsp.header"/></h2>

<rhn:systemtimemessage server="${system}" />


<rl:listset name="erratConfirmListSet"> 
	<rl:list dataset="pageList"
  			width="100%"        
         	name="errataConfirmList"
         	styleclass="list"
         	emptykey="erratalist.jsp.noerrata">
         	
    <rl:decorator name="PageSizeDecorator"/>
    
    <rl:column headerkey="erratalist.jsp.type" styleclass="first-column text-align: center;">
      <c:if test="${current.securityAdvisory}">
        <img src="/img/wrh-security.gif"
             title="<bean:message key="erratalist.jsp.securityadvisory"/>" />
      </c:if>
      <c:if test="${current.bugFix}">
        <img src="/img/wrh-bug.gif"
             title="<bean:message key="erratalist.jsp.bugadvisory"/>" />
      </c:if>
      <c:if test="${current.productEnhancement}">
        <img src="/img/wrh-product.gif"
             title="<bean:message key="erratalist.jsp.productenhancementadvisory"/>" />
      </c:if>
    </rl:column>

    <rl:column headerkey="erratalist.jsp.advisory">
      <a href="/rhn/errata/details/Details.do?eid=${current.id}">
        ${current.advisoryName}</a>
    </rl:column>

    <rl:column headerkey="erratalist.jsp.synopsis">
      ${current.advisorySynopsis}
    </rl:column>

    <rl:column headerkey="erratalist.jsp.updated" styleclass="last-column">
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
    		<th><img src="/img/rhn-icon-schedule.gif" alt="<bean:message key="syncprofile.jsp.selection"/>"
             	title="<bean:message key="syncprofile.jsp.selection"/>"/>
    		</th>
    		<td>
      			 <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
        			<jsp:param name="widget" value="date"/>
      			</jsp:include> 
    		</td>
  		</tr>
	</table>

  <div align="right">
    <hr />
    <html:submit property="dispatch">
      <bean:message key="errataconfirm.jsp.confirm"/>
    </html:submit>
  </div>
  <html:hidden property="sid" value="${param.sid}"/>
  
</rl:listset>
</body>
</html>
