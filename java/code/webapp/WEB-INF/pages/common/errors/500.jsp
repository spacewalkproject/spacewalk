<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page" prefix="page" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<html:xhtml/>
<page:applyDecorator name="layout_c">
<body>
    <h1>
      <img src="/img/rhn-icon-warning.gif"
           alt="<bean:message key='500.jsp.imgAlt' />" />
      <bean:message key="500.jsp.title"/>
    </h1>
    <p><bean:message key="500.jsp.summary"/></p>
    <p><bean:message key="500.jsp.message"/></p>
</body>
</page:applyDecorator>
