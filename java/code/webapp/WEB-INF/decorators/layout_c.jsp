<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page" prefix="page" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<!DOCTYPE HTML>
<html:html>
  <head>
	  <jsp:include page="layout_head.jsp" />
	  <decorator:head />
  </head>
  <body onload="<decorator:getProperty property="body.onload" />">
    <header>
      <jsp:include page="/WEB-INF/includes/header.jsp" />
    </header>
    <div class="body-container row">
      <aside class="col-md-2">
        <jsp:include page="/WEB-INF/includes/leftnav.jsp" />
        <jsp:include page="/WEB-INF/includes/legends.jsp" />
        <jsp:include page="/WEB-INF/includes/advertisements.jsp" />
      </aside>
      <section class="col-md-10">
        <!-- Alerts and messages -->
        <logic:messagesPresent>
          <div class="alert alert-info">
            <ul>
            <html:messages id="message">
              <li><c:out value="${message}"/></li>
            </html:messages>
            </ul>
          </div>
        </logic:messagesPresent>
        <html:messages id="message" message="true">
          <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
        </html:messages>
        <div id="bar">
          <div class="spacewalk-bar">
            <rhn:require acl="user_authenticated()">
              <span id="header_selcount">
                <rhn:setdisplay user="${requestScope.session.user}"/>
              </span>
              <a class="button" href="/rhn/ssm/index.do">
                <bean:message key="manage"/>
              </a>
              <%--
                -- Make sure we set the return_url variable correctly here. This will make is to
                -- the user is returned here after clearing the ssm.
                --%>
              <c:choose>
                <c:when test="${not empty pageContext.request.queryString}">
                  <c:set var="rurl" value="${pageContext.request.requestURI}?${pageContext.request.queryString}"/>
                </c:when>
                <c:otherwise>
                  <c:set var="rurl" value="${pageContext.request.requestURI}" />
                </c:otherwise>
              </c:choose>
              <a class="button" href="/rhn/systems/Overview.do?empty_set=true&amp;return_url=${rhn:urlEncode(rurl)}">
                <bean:message key="clear"/>
              </a>
            </rhn:require>
          </div>
        </div>
        <decorator:body />
      </section>
    </div>
    <footer class="row">
      <jsp:include page="/WEB-INF/includes/footer.jsp" />
    </footer>    
  </body>
</html:html>
