<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page" prefix="page" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html:xhtml/>
<html:html xhtml="true">
  <head>
	  <jsp:include page="layout_head.jsp" />
	  <decorator:head />
  </head>
  <body onload="<decorator:getProperty property="body.onload" />">
   <div id="wrap">
    <div id="top-wrap" class="wrap">
      <jsp:include page="/WEB-INF/includes/header.jsp" />
    </div>
    <div id="bottom-wrap" class="wrap">
    <div id="content">
        <decorator:body />
      </div><!-- end content -->
      <jsp:include page="/WEB-INF/includes/footer.jsp" />
    </div><!-- end bottom-wrap -->
   </div><!-- end wrap -->
  </body>
</html:html>
