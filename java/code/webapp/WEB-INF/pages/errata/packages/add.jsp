<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

  <html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
  </html:messages>
	
  <rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif" imgAlt="errata.common.errataAlt"
	           helpUrl="/rhn/help/channel-mgmt/en/channel-mgmt-Custom_Errata_Management-Managed_Errata_Details.jsp">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>
  
  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml" 
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
  
  <h2><bean:message key="errata.edit.packages.addpackages"/></h2>
  
  <p><bean:message key="errata.edit.packages.add.instructions"/></p>

<form method="POST" name="rhn_list" action="/rhn/errata/manage/AddPackagesSubmit.do">
  <p>
    <bean:message key="errata.edit.packages.add.viewlabel"/>
    <select name="view_channel">
      <c:forEach items="${viewoptions}" var="option">
        <option value="<c:out value="${option.value}"/>"
          <c:if test="${option.value == param.view_channel}">selected="1"</c:if>>
          <c:out value="${option.label}"/>
        </option>
      </c:forEach>
    </select>
    <html:submit property="dispatch">
      <bean:message key="errata.edit.packages.add.viewsubmit"/>
    </html:submit>
  </p>
  
<rhn:list pageList="${requestScope.pageList}" noDataText="errata.edit.packages.add.nopackages">
  <rhn:listdisplay filterBy="errata.edit.packages.add.package" 
      button="errata.edit.packages.add.addpackages"
      set="${requestScope.set}" hiddenvars="${requestScope.newset}">
      
    <%@ include file="/WEB-INF/pages/common/fragments/errata/nvre-set-display.jspf" %>
 
  </rhn:listdisplay>
</rhn:list>
<input type="hidden" name="eid" value="<c:out value="${param.eid}"/>" />
</form>
  
</body>
</html>
