<%@ page
    pageEncoding="iso-8859-1"
    contentType="text/html;charset=utf-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%--
  @param widget name of the date picker bean which should be in the request
                scope. The bean should be DatePickerBean
--%>
<c:set value="${requestScope[param.widget]}" var="picker"/>
<rhn:datepicker data="${picker}"/>
