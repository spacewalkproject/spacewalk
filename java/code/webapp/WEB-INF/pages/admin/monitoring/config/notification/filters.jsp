<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-system_group.gif"
	           creationUrl="FilterCreate.do"
               creationType="filter"
               helpUrl="/rhn/help/reference/en-US/s1-sm-monitor.jsp#s2-sm-monitor-notif">
    <bean:message key="filters.jsp.header1"/>
  </rhn:toolbar>


<h2><bean:message key="filters.jsp.header2"/></h2>

<div>
  <p>
    <bean:message key="filters.jsp.summary"/>
    <form method="POST" name="rhn_list" action="/rhn/monitoring/config/notification/FiltersSubmit.do">

    <rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/filters.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
    <br>

    <rhn:list pageList="${requestScope.pageList}" noDataText="filters.jsp.nofilters">
      <%-- There is only one list, but we have to define the same columns
           twice since we can't just stick the opening tags into the c:if --%>
      <c:if test="${allowSelection}">
      <rhn:listdisplay   set="${requestScope.set}"
        hiddenvars="${requestScope.newset}" button="filters.jsp.expirefilters">
        <rhn:set value="${current.recid}" />
        <rhn:column header="filters.jsp.description">
            <A HREF="FilterEdit.do?filter_id=${current.recid}">${current.description}</A>
        </rhn:column>
        <rhn:column header="filters.jsp.type">
            <bean:message key="${current.redirectType}"/>
        </rhn:column>
        <rhn:column header="filters.jsp.expiration">
            <fmt:formatDate value="${current.expiration}" type="both" dateStyle="short" timeStyle="long"/>
        </rhn:column>
      </rhn:listdisplay>
      </c:if>
      <c:if test="${not allowSelection}">
      <rhn:listdisplay  >
        <rhn:column header="filters.jsp.description">
            <A HREF="FilterEdit.do?filter_id=${current.recid}">${current.description}</A>
        </rhn:column>
        <rhn:column header="filters.jsp.type">
            <bean:message key="${current.redirectType}"/>
        </rhn:column>
        <rhn:column header="filters.jsp.expiration">
            <fmt:formatDate value="${current.expiration}" type="both" dateStyle="short" timeStyle="long"/>
        </rhn:column>
      </rhn:listdisplay>
      </c:if>
    </rhn:list>
    </form>
  </p>
</div>


</body>
</html>


