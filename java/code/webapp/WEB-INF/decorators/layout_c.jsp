<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
    <div class="wrap" id="top-wrap">
      <jsp:include page="/WEB-INF/includes/header.jsp" />
    </div>
    <div class="wrap" id="bottom-wrap">
      <div id="content">
        <!-- MAIN table -->
        <table width="100%" cellspacing="0">
          <tr>
            <td class="sidebar">
              <!-- left nav -->

                <jsp:include page="/WEB-INF/includes/leftnav.jsp" />

                <jsp:include page="/WEB-INF/includes/legends.jsp" />

                <jsp:include page="/WEB-INF/includes/advertisements.jsp" />

            </td>
            <td class="page-content">
            <html:errors/>
			<html:messages id="message" message="true">
				<rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
			</html:messages>
              <decorator:body />
            </td>
          </tr>
        </table>
        <!-- END MAIN table -->
        <jsp:include page="/WEB-INF/includes/footer.jsp" />
      </div><!-- end content -->
    </div><!-- end bottom-wrap -->
   </div><!-- end wrap -->
  </body>
</html:html>
