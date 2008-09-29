<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:import url="/WEB-INF/pages/systems/details/packages/packagelist.jspf">
   <c:param name="alt" value="Verify Packages"/>
   <c:param name="header" value="verifypkgs.jsp.verifiablepackages"/>
   <c:param name="summary" value="verifypkgs.jsp.verifypagesummary"/>
   <c:param name="showArch" value="true"/>
   <c:param name="dispatch" value="verifypkgs.jsp.verifypackages"/>
</c:import>


