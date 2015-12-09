<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<!-- TODO make this more generic -->
<rhn:require acl="is(java.chat_enabled);">
  <jsp:include page="/WEB-INF/includes/advertisements/chat-advertisement.jsp"/>
</rhn:require>

