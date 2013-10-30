<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page" prefix="page" %>
<%@ page contentType="text/html; charset=UTF-8" %>

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
