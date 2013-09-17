<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<nav id="sidenav">
  <rhn:require acl="not user_authenticated()">
  <rhn:menu mindepth="1" maxdepth="3" definition="/WEB-INF/nav/sitenav.xml" renderer="com.redhat.rhn.frontend.nav.SidenavRenderer" />
  </rhn:require>
  <rhn:require acl="user_authenticated()">
  <rhn:menu mindepth="1" maxdepth="3" definition="/WEB-INF/nav/sitenav-authenticated.xml" renderer="com.redhat.rhn.frontend.nav.SidenavRenderer" />
  </rhn:require>
</nav>
