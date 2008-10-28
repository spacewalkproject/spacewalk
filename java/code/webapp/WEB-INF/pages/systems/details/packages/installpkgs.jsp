<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:import url="/WEB-INF/pages/systems/details/packages/packagelist.jspf">
   <c:param name="alt" value="Install Packages"/>
   <c:param name="header" value="installpkgs.jsp.header"/>
   <c:param name="summary" value="installpkgs.jsp.summary"/>
   <c:param name="dispatch" value="installpkgs.jsp.installpackages"/>
   <c:param name="showArch" value="true"/>
</c:import>
