<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"
%><%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"
%><%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"
%><%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"
%><!-- enclosing head tags in layout_c.jsp -->
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script type='text/javascript' src="/javascript/html5.js"></script>
      <script type='text/javascript' src="/javascript/respond.js"></script>
    <![endif]-->
    <c:if test="${pageContext.request.requestURI == '/rhn/Load.do'}">
      <meta http-equiv="refresh" content="0; url=<c:out value="${param.return_url}" />" />
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

    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

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

    <link rel="stylesheet" href="/javascript/select2/select2.css" />
    <link rel="stylesheet" href="/javascript/select2/select2-bootstrap.css" />

    <link rel="stylesheet" href="/fonts/font-awesome/css/font-awesome.css" />
    <link rel="stylesheet" href="/fonts/font-spacewalk/css/spacewalk-font.css" />

    <script src="/javascript/jquery.js"></script>
    <script src="/javascript/bootstrap.js"></script>
    <script src="/javascript/select2/select2.js"></script>
    <script src="/javascript/spacewalk-essentials.js"></script>
    <script src="/javascript/spacewalk-checkall.js"></script>

    <script src="/rhn/dwr/engine.js"></script>
    <script src="/rhn/dwr/util.js"></script>
    <script src="/rhn/dwr/interface/DWRItemSelector.js"></script>
    <script src="/javascript/jquery.timepicker.js"></script>
    <script src="/javascript/bootstrap-datepicker.js"></script>
