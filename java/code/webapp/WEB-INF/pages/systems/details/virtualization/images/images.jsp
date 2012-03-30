<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>

<head>
  <script type="text/javascript" src="/rhn/dwr/interface/ImagesRenderer.js"></script>
  <script type="text/javascript" src="/rhn/dwr/engine.js"></script>
  <script type="text/javascript" src="/javascript/scriptaculous.js"></script>
  <script type="text/javascript" src="/javascript/render.js"></script>
  <script type="text/javascript" src="/javascript/images.js"></script>
</head>

<body>
  <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

  <c:choose>
    <c:when test="${requestScope.loadAsync == true}">
      <div id="images-content">
        <div style="padding: 1em;">
          <img src="/img/spinner.gif" style="vertical-align: middle;" />
          <span style="padding-left: 0.3em;">Loading ...</span>
        </div>
        <script type="text/javascript">
          ImagesRenderer.renderAsync(makeAjaxCallback("images-content", false));
        </script>
      </div>
    </c:when>
    <c:otherwise>
      <%@ include file="/WEB-INF/pages/systems/details/virtualization/images/images-content.jspf" %>
    </c:otherwise>
  </c:choose>
</body>
</html>
