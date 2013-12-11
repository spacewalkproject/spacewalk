<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"
%><%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"
%><%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"
%><%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"
%><!-- enclosing head tags in layout_c.jsp -->
    <c:if test="${pageContext.request.requestURI == '/rhn/Load.do'}">
      <meta http-equiv="refresh" content="0; url=<c:out value="${param.return_url}" />" />
    </c:if>
    <c:if test="${pageContext.request.requestURI == '/rhn/kickstart/cobbler/CobblerSnippetView.do' || pageContext.request.requestURI == '/rhn/kickstart/cobbler/CobblerSnippetCreate.do' || pageContext.request.requestURI == '/rhn/kickstart/cobbler/CobblerSnippetEdit.do' || pageContext.request.requestURI == '/rhn/kickstart/KickstartScriptCreate.do' || pageContext.request.requestURI == '/rhn/kickstart/KickstartScriptEdit.do' || pageContext.request.requestURI == '/rhn/kickstart/KickstartScriptCreate.do' || pageContext.request.requestURI == '/rhn/kickstart/AdvancedModeEdit.do' || pageContext.request.requestURI == '/rhn/kickstart/AdvancedModeCreate.do' || pageContext.request.requestURI == '/rhn/configuration/file/FileDetails.do' || pageContext.request.requestURI == '/rhn/configuration/file/FileDownload.do' || pageContext.request.requestURI == '/rhn/systems/details/configuration/addfiles/CreateFile.do' || pageContext.request.requestURI == '/rhn/configuration/ChannelCreateFiles.do' || pageContext.request.requestURI == '/rhn/admin/Catalina.do'}">
      <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7"/>
      <!-- If we are loading a page that uses editarea, tell IE to use IE7 Compatability mode. This has to be the first thing in head if its gonna work. Only necessary for IE, but doesnt hurt other browsers. Conditional comments are going away in IE 10, so not including them here so this will continue to work. -->
    </c:if>
    <meta http-equiv="content-type" content="text/html;charset=UTF-8"/>
    <title>
      <bean:message key="layout.jsp.productname"/>
      <rhn:require acl="user_authenticated()">
        <rhn:menu definition="/WEB-INF/nav/sitenav-authenticated.xml"
                  renderer="com.redhat.rhn.frontend.nav.TitleRenderer" />
      </rhn:require>
      <rhn:require acl="not user_authenticated()">
        <rhn:menu definition="/WEB-INF/nav/sitenav.xml"
                  renderer="com.redhat.rhn.frontend.nav.TitleRenderer" />
      </rhn:require>
      ${requestScope.innernavtitle}
    </title>
    <link rel="shortcut icon" href="/img/favicon.ico" />

    <link rel="stylesheet" href="/fonts/font-awesome/css/font-awesome.css" />
    <link rel="stylesheet" href="/fonts/font-spacewalk/css/spacewalk-font.css" />
    <meta name="viewport" content="initial-scale=1">

    <rhn:require acl="is(development_environment)">
      <link rel="stylesheet/less" type="text/css" href="/css/spacewalk.less" />
      <script>less = { env: 'development' };</script>
      <script src="/javascript/less.js"></script>
    </rhn:require>
    <rhn:require acl="not is(development_environment)">
      <link rel="stylesheet" href="/css/spacewalk.css" />
    </rhn:require>
    <link rel="stylesheet" href="/css/jquery.timepicker.css" />
    <link rel="stylesheet" href="/css/bootstrap-datepicker.css" />

    <script src="/javascript/jquery.js"></script>
    <script src="/javascript/bootstrap.js"></script>
    <script src="/javascript/spacewalk-essentials.js"></script>
    <script src="/javascript/spacewalk-checkall.js"></script>

    <script src="/rhn/dwr/engine.js"></script>
    <script src="/rhn/dwr/util.js"></script>
    <script src="/rhn/dwr/interface/DWRItemSelector.js"></script>
    <script src="/javascript/jquery.timepicker.js"></script>
    <script src="/javascript/bootstrap-datepicker.js"></script>
