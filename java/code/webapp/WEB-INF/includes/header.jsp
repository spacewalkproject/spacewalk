<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<!-- header.jsp -->

<c:set var="custom_header" scope="page" value="${rhn:getConfig('java.custom_header')}" />
<c:if test="${! empty custom_header}">
    <center><p><c:out value="${custom_header}" escapeXml="false"/></p></center>
</c:if>

<div class="spacewalk-header-container">
  <div id="logo" class="spacewalk-logo">
    <a href="<bean:message key='layout.jsp.vendor.website'/>" title="<bean:message key='layout.jsp.vendor.title'/>">
      <img src="/img/logo_vendor.png" alt="<bean:message key='layout.jsp.vendor.name'/>" id="rhLogo" />
    </a>
    <a href="/" title="<bean:message key="layout.jsp.productname"/> homepage">
      <img src="/img/logo_product.png" alt="<bean:message key='layout.jsp.productname'/>" id="rhnLogo" accesskey="2"/>
    </a>
  </div>
  <div class="spacewalk-header-links">
    <rhn:require acl="user_authenticated()">
      <ul class="nav nav-pills">
        <li class="hidden-sm hidden-xs"><a href="/rhn/account/LocalePreferences.do"><c:out value="${rhnActiveLang}" /> (<bean:message key="header.jsp.change"/>)</a></li>
      </ul>
      <ul class="nav nav-pills">
        <li class="hidden-sm hidden-xs"><a href="http://kbase.redhat.com/"><bean:message key="header.jsp.knowledgebase" /></a></li>
        <li class="hidden-sm hidden-xs"><a href="/help"><bean:message key="header.jsp.documentation" /></a></li>
      </ul>
      <ul class="nav nav-pills">
        <li>
          <a href="/rhn/account/UserDetails.do"><i class="fa fa-user"></i><c:out escapeXml="true" value="${requestScope.session.user.login}" /></a>
        </li>
        <li class="hidden-sm hidden-xs hidden-md">
          <span class="spacewalk-header-non-link"><i class="fa fa-sitemap"></i><c:out escapeXml="true" value="${requestScope.session.user.org.name}" /></span>
        </li>
        <li>
          <a href="/rhn/account/UserPreferences.do"><i class="fa fa-cogs" title="<bean:message key='header.jsp.preferences' />"></i></a>
        </li>
        <li>
          <html:link forward="logout"><i class="fa fa-sign-out" title="<bean:message key='header.jsp.signout' />"></i></html:link>
        </li>
      </ul>

      <form name="form1" class="form-inline hidden-xs" role="form" action="/rhn/Search.do" method="get">
        <div class="form-group">
          <select name="search_type" class="form-control input-sm">
            <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
              <option value="systems"><bean:message key="header.jsp.systems" /></option>
            </rhn:require>
            <option value="packages"><bean:message key="header.jsp.packages" /></option>
            <option value="errata"><bean:message key="header.jsp.errata" /></option>
            <option value="docs"><bean:message key="header.jsp.documentation" /></option>
          </select>
        </div>
        <div class="form-group">
          <input type="search" class="form-control input-sm" name="search_string" maxlength="40" size="20" accesskey="4" autofocus="autofocus" placeholder="<bean:message key='button.search'/>" />
        </div>
        <div class="form-group">
          <input type="hidden" name="submitted" value="true" />
          <button type="submit" class="btn btn-info input-sm">
            <i class="fa fa-search"></i>
          </button>
        </div>
      </form>
    </rhn:require>
  </div>
</div>

<nav class="navbar navbar-inverse spacewalk-main-nav" role="navigation">
  <button class="pull-left main-menu-mobile" data-toggle="collapse" data-target=".main-menu-hor"></button>
  <rhn:require acl="user_authenticated()">
    <div id="bar">
      <div class="spacewalk-bar pull-right">
          <span id="header_selcount">
            <rhn:setdisplay user="${requestScope.session.user}" />
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
          <a id="clear-btn" class="button" href="/rhn/systems/Overview.do?empty_set=true&amp;return_url=${rhn:urlEncode(rurl)}">
            <bean:message key="clear"/>
          </a>
      </div>
    </div>
  </rhn:require>
  <div class="clear-responsive-btn"></div>
  <rhn:require acl="user_authenticated()">
      <rhn:menu mindepth="0" maxdepth="0"
                definition="/WEB-INF/nav/sitenav-authenticated.xml"
                renderer="com.redhat.rhn.frontend.nav.TopnavRenderer" />
  </rhn:require>
  <rhn:require acl="not user_authenticated()">
      <rhn:menu mindepth="0" maxdepth="0"
               definition="/WEB-INF/nav/sitenav.xml"
               renderer="com.redhat.rhn.frontend.nav.TopnavRenderer" />
  </rhn:require>

</nav>
<!-- end header.jsp -->
