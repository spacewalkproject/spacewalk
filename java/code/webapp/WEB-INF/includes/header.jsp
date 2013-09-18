<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<!-- header.jsp -->

<c:set var="custom_header" scope="page" value="${rhn:getConfig('java.custom_header')}" />
<c:if test="${! empty custom_header}">
    <center><p><c:out value="${custom_header}" escapeXml="false"/></p></center>
</c:if>

<div class="row">
  <div id="logo" class="col-md-3 logo">
    <a href="<bean:message key="layout.jsp.vendor.website"/>" title="<bean:message key="layout.jsp.vendor.title"/>">
      <img src="/img/logo_vendor.png" alt="<bean:message key="layout.jsp.vendor.name"/>" id="rhLogo" />
    </a>
    <a href="/" title="<bean:message key="layout.jsp.productname"/> homepage">
      <img src="/img/logo_product.png" alt="<bean:message key="layout.jsp.productname"/>" id="rhnLogo" accesskey="2"/>
    </a>
  </div>
  <div class="col-md-9 text-right">
    <rhn:require acl="user_authenticated()">
      <ul class="nav nav-pills">
        <li><a href="/rhn/account/LocalePreferences.do"><c:out value="${rhnActiveLang} "/>(<bean:message key="header.jsp.change"/>)</a></li>
      </ul>
      <ul class="nav nav-pills">
        <li><a href="http://kbase.redhat.com/"><bean:message key="header.jsp.knowledgebase" /></a></li>
        <li><a href="/help"><bean:message key="header.jsp.documentation" /></a></li>
      </ul>
      <ul class="nav nav-pills">
        <li>
          <a href="/rhn/account/UserDetails.do"><i class="icon-user"></i>:<c:out escapeXml="true" value="${requestScope.session.user.login}" /></a>
        </li>
        <li>
          <a><i class="icon-sitemap"></i>:<c:out escapeXml="true" value="${requestScope.session.user.org.name}" /></a>
        </li>
        <li>
          <a href="/rhn/account/UserPreferences.do"><i class="icon-cogs"></i></a>
        </li>
        <li>
          <html:link forward="logout"><i class="icon-signout"></i></html:link>
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
          <input type="search" class="input-sm" name="search_string" maxlength="40" size="20" accesskey="4" autofocus="autofocus" />
        </div>
        <div class="form-group">
          <input type="hidden" name="submitted" value="true" />
          <button type="submit" class="btn btn-info input-sm">
            <i class="icon-search"></i><bean:message key="button.search" />
          </button>
        </div>
      </form>
    </rhn:require>
  </div>
</div>

<nav class="navbar navbar-inverse spacewalk-main-nav" role="navigation">
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
