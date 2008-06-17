<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>


<c:forEach items="${requestScope.legends}" var="legend">
  <jsp:include page="/WEB-INF/includes/legends/${legend}-legend.jsp"/>
</c:forEach>

