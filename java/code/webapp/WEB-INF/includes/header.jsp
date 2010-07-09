<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<!-- header.jsp -->

<rhn:require acl="user_authenticated()">
<div id="utility">
	<div id="utilityLinks">

<p id="geo"><c:out value="${rhnActiveLang} "/> (<a href="/rhn/account/LocalePreferences.do"><bean:message key="header.jsp.change"/></a>)</p>
		<p id="linx"><span class="hide"><strong><bean:message key="header.jsp.shortcuts"/></strong> </span><a href="http://kbase.redhat.com/"><bean:message key="header.jsp.knowledgebase"/></a> <span class="navPipe">|</span> <a href="/help"><bean:message key="header.jsp.documentation"/></a></p>

	</div>
	<div id="utilityAccount">
        <p>
         <span class="label"><bean:message key="header.jsp.loggedin"/></span> <a href="/rhn/account/UserDetails.do"><c:out escapeXml="true" value="${requestScope.session.user.login}" /></a><span class="navPipe">|</span><span class="label"><bean:message key="header.jsp.org"/></span> <a><c:out escapeXml="true" value="${requestScope.session.user.org.name}" /></a><span class="navPipe">|</span><a href="/rhn/account/UserPreferences.do"><bean:message key="header.jsp.preferences"/></a><span class="navPipe">|</span><html:link forward="logout"><span><bean:message key="header.jsp.signout"/></span></html:link>
        </p>
	</div>
</div>
</rhn:require>

<div id="header">
      <a href="<bean:message key="layout.jsp.vendor.website"/>" title="<bean:message key="layout.jsp.vendor.title"/>"><img src="/img/logo_vendor.png" alt="<bean:message key="layout.jsp.vendor.name"/>" id="rhLogo" /></a>
        <a href="/" title="<bean:message key="layout.jsp.productname"/> homepage">
          <img src="/img/logo_product.png" alt="<bean:message key="layout.jsp.productname"/>" id="rhnLogo" />
        </a>
      <rhn:require acl="user_authenticated()">
 <div id="searchbar">
    <div id="searchbarinner">
      <form name="form1" action="/rhn/Search.do" method="get">
      <select name="search_type">
      <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
            <option value="systems"><bean:message key="header.jsp.systems"/></option>
          </rhn:require>
      <option value="packages"><bean:message key="header.jsp.packages"/></option>
      <option value="errata"><bean:message key="header.jsp.errata"/></option>
      <option value="docs"><bean:message key="header.jsp.documentation"/></option>
      </select><input type="text" name="search_string" maxlength="40" size="20" />
      <input type="hidden" name="submitted" value="true"/>
      <input type="submit" class="button" name="image-1" value="Search" align="top" /></form>
    </div>
  </div>
	</rhn:require>

</div>

<div id="navWrap">
<div id="mainNavWrap">
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
</div> <!-- close div mainNavWrap -->

</div> <!-- close div navWrap -->

<div id="bar">
  <div id="systembar">
    <div id="systembarinner">
      <div>
      <rhn:require acl="user_authenticated()">
        <span id="header_selcount">
          <rhn:setdisplay user="${requestScope.session.user}"/>
        </span>
        <a class="button" href="/network/systems/ssm/index.pxt">
	Manage
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
        <a class="button" href="/rhn/systems/Overview.do?empty_set=true&amp;return_url=<c:out escapeXml="true" value="${rurl}"/>">
	Clear
        </a>
      </rhn:require>
      </div>
    </div>
  </div>
</div> <!-- end div bar -->
<!-- end header.jsp -->

