<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<!-- header.jsp -->

<c:set var="custom_header" scope="page" value="${rhn:getConfig('java.custom_header')}" />
<c:if test="${! empty custom_header}">
    <center><p><c:out value="${custom_header}" escapeXml="false"/></p></center>
</c:if>

<div id="logo">
  <a href="<bean:message key="layout.jsp.vendor.website"/>" title="<bean:message key="layout.jsp.vendor.title"/>">
    <img src="/img/logo_vendor.png" alt="<bean:message key="layout.jsp.vendor.name"/>" id="rhLogo" />
  </a>
  <a href="/" title="<bean:message key="layout.jsp.productname"/> homepage">
    <img src="/img/logo_product.png" alt="<bean:message key="layout.jsp.productname"/>" id="rhnLogo" accesskey="2"/>
  </a>
</div>

<rhn:require acl="user_authenticated()">
  <div id="geo">
    <c:out value="${rhnActiveLang} "/>(<a href="/rhn/account/LocalePreferences.do"><bean:message key="header.jsp.change"/></a>)
  </div>

  <div id="linx">
    <span class="hide">
      <strong><bean:message key="header.jsp.shortcuts"/></strong>
    </span>
    <a href="http://kbase.redhat.com/"><bean:message key="header.jsp.knowledgebase"/></a>
    <span class="navPipe">|</span>
    <a href="/help"><bean:message key="header.jsp.documentation"/></a>
  </div>

  <div id="utilityAccount">
    <ul>
      <li id="acc-logged-user">
        <bean:message key="header.jsp.loggedin"/>
        <a href="/rhn/account/UserDetails.do">
          <c:out escapeXml="true" value="${requestScope.session.user.login}" />
        </a>
      </li>
      <li id="acc-logged-user-org">
        <bean:message key="header.jsp.org"/>
        <a>
          <c:out escapeXml="true" value="${requestScope.session.user.org.name}" />
        </a>
      </li>
      <li id="acc-prefs">
        <a href="/rhn/account/UserPreferences.do">
          <bean:message key="header.jsp.preferences"/>
        </a>
      </li>
      <li id="acc-logout">
        <html:link forward="logout">
          <bean:message key="header.jsp.signout"/>
        </html:link>
      </li>

    </ul>
  </div>
</rhn:require>

<rhn:require acl="user_authenticated()">
  <form id="splk-search" name="form1" action="/rhn/Search.do" method="get">
    <select name="search_type">
      <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
        <option value="systems"><bean:message key="header.jsp.systems"/></option>
      </rhn:require>
      <option value="packages"><bean:message key="header.jsp.packages"/></option>
      <option value="errata"><bean:message key="header.jsp.errata"/></option>
      <option value="docs"><bean:message key="header.jsp.documentation"/></option>
    </select>
    <input type="text" name="search_string" maxlength="40" size="20" accesskey="4" autofocus="autofocus"/>
    <input type="hidden" name="submitted" value="true"/>
    <button type="submit" class="btn btn-default btn-sm">
        <span class="glyphicon glyphicon-search" />
        <bean:message key="button.search"/>
    </button>
  </form>
</rhn:require>

</div>

<nav>
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

<div id="bar">
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

<!-- end header.jsp -->

