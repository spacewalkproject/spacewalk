<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>

<ul>
    <c:forEach items="${entries}" var="entry">
        <li class="entry" data-entry-id="${entry.id}">
            <c:out value="${entry.server.name}" />
            <a class="delete-entry" href="#">
                <i class="fa fa-trash-o"></i><bean:message key="actionchain.jsp.deletesystem" />
            </a>
        </li>
    </c:forEach>
</ul>
