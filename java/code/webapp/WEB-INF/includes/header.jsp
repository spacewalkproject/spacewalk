<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<!-- header.jsp -->

<c:set var="custom_header" scope="page" value="${rhn:getConfig('java.custom_header')}" />

<div class="navbar-header">
  <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
    <span class="sr-only">Toggle navigation</span>
    <span class="icon-bar"></span>
    <span class="icon-bar"></span>
    <span class="icon-bar"></span>
  </button>
  <a class="navbar-brand" href="<bean:message key='layout.jsp.vendor.website'/>" title="<bean:message key='layout.jsp.vendor.title'/>">
    <img src="/img/logo_vendor.png" alt="<bean:message key='layout.jsp.vendor.name'/>" id="rhLogo" />
  </a>
  <a class="navbar-brand" href="/" title="<bean:message key="layout.jsp.productname"/> homepage">
    <img src="/img/logo_product.png" alt="<bean:message key='layout.jsp.productname'/>" id="rhnLogo" accesskey="2"/>
  </a>
  <c:if test="${! empty custom_header}">
    <div class="custom-text">
      <c:out value="${custom_header}" escapeXml="false"/>
    </div>
  </c:if>
</div>

<div class="navbar-collapse collapse">
  <rhn:require acl="user_authenticated()">
    <ul class="nav navbar-nav navbar-utility">
      <li class="hidden-sm hidden-xs"><a href="/rhn/account/LocalePreferences.do"><c:out value="${rhnActiveLang}" /> (<bean:message key="header.jsp.change"/>)</a></li>
      <li class="hidden-xs"><a href="https://access.redhat.com/knowledgebase"><bean:message key="header.jsp.knowledgebase" /></a></li>
      <li class="hidden-xs"><a href="/rhn/help/index.do"><bean:message key="header.jsp.documentation" /></a></li>
      <li><a href="/rhn/account/UserDetails.do"><rhn:icon type="header-user" /> <c:out escapeXml="true" value="${requestScope.session.user.login}" /></a></li>
      <li class="hidden-sm hidden-xs hidden-md"><a><rhn:icon type="header-sitemap" /> <c:out escapeXml="true" value="${requestScope.session.user.org.name}" /></a></li>
      <li><a href="/rhn/account/UserPreferences.do"><rhn:icon type="header-preferences" title="header.jsp.preferences" /></a></li>
      <li><a href="/rhn/Logout.do"><rhn:icon type="header-signout" title="header.jsp.signout" /></a></li>
      <li class="search hidden-xs">
        <form name="form1" class="form-inline" role="form" action="/rhn/Search.do">
          <rhn:csrf />
          <rhn:submitted />
          <div class="form-group">
            <select name="search_type" class="form-control input-sm">
              <option value="systems"><bean:message key="header.jsp.systems" /></option>
              <option value="packages"><bean:message key="header.jsp.packages" /></option>
              <option value="errata"><bean:message key="header.jsp.errata" /></option>
              <option value="docs"><bean:message key="header.jsp.documentation" /></option>
            </select>
            <input type="search" class="form-control input-sm" name="search_string" size="20" accesskey="4" autofocus="autofocus" placeholder="<bean:message key='button.search'/>" />
            <button type="submit" class="btn btn-primary input-sm" id="search-btn">
              <rhn:icon type="header-search" />
            </button>
          </div>
        </form>
      </li>
    </ul>
  </rhn:require>

  <rhn:require acl="user_authenticated()">
    <ul class="nav navbar-nav navbar-primary navbar-right spacewalk-bar">
      <div class="btn-group">
        <button id="header_selcount" class="btn btn-default btn-link disabled">
          <rhn:setdisplay user="${requestScope.session.user}" />
        </button>
        <a href="/rhn/ssm/index.do">
          <button class="btn btn-primary" type="button">
            <bean:message key="manage"/>
          </button>
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
        <a id="clear-btn" href="/rhn/systems/Overview.do?empty_set=true&amp;return_url=${rhn:urlEncode(rurl)}">
          <button class="btn btn-danger" type="button">
            <bean:message key="clear"/>
          </button>
        </a>
      </div>
    </ul>
    <rhn:menu mindepth="0" maxdepth="0"
              definition="/WEB-INF/nav/sitenav-authenticated.xml"
              renderer="com.redhat.rhn.frontend.nav.TopnavRenderer" />
  </rhn:require>
  <rhn:require acl="not user_authenticated()">
    <rhn:menu mindepth="0" maxdepth="0"
              definition="/WEB-INF/nav/sitenav.xml"
              renderer="com.redhat.rhn.frontend.nav.TopnavRenderer" />
  </rhn:require>
</div>
<!-- end header.jsp -->
