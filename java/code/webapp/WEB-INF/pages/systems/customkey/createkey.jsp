<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html xhtml="true">
<body>
<BR>




<div>



  <div class="toolbar-h1">
	<div class="toolbar"></div>
	<img src="/img/rhn-icon-keyring.gif" alt="" />
       <bean:message key="system.jsp.customkey.createtitle"/>

	<a href="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-system-cust-info"
		target="_new" class="help-title">
		<img src="/img/rhn-icon-help.gif" alt="Help Icon" />
	</a>
  </div>


      <div class="page-summary">
      <p>
        <bean:message key="system.jsp.customkey.createmsg"/>
      </p>
      </div>



	<hr />


      <form action="/rhn/systems/customdata/CreateCustomKey.do" name="edit_token" method="post">
        <table class="details">
            <tr>
              <th><bean:message key="system.jsp.customkey.keylabel"/>:</th>
              <td><input type="text" name="label" length="64" size="30" value="<c:out value="${old_label}" />"/>
			  </td>
            </tr>

            <tr>
              <th><bean:message key="system.jsp.customkey.description"/>:</th>
              <td>
                <textarea wrap="virtual" rows="6" cols="50" name="description"><c:out value="${old_description}" /></textarea>
              </td>
            </tr>


        </table>



		<div align="right">
		<hr />

        <input type="submit" name="CreateKey" value="Create Key" />

		<rhn:submitted/>
</div>
      </form>







</div>

</body>
</html:html>
