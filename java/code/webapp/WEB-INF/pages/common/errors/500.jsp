<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page" prefix="page" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<page:applyDecorator name="layout_c">
<body>
    <h1>
      <i class="fa fa-warning text-warning" title="<bean:message key='500.jsp.imgAlt' />"></i>
      <bean:message key="500.jsp.title"/>
    </h1>
    <p><bean:message key="500.jsp.summary"/></p>
    <p><bean:message key="500.jsp.message"/></p>
</body>
</page:applyDecorator>
