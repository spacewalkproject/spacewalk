<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html >
<body>
    <rhn:toolbar base="h1" icon="fa-key"
        helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-system-cust-info">
        <bean:message key="system.jsp.customkey.deletetitle"/>
    </rhn:toolbar>

      <form action="/rhn/systems/customdata/DeleteCustomKey.do?cikid=${cikid}" name="edit_token" method="post">
          <rhn:csrf />
        <div class="form-group">
            <label for="customkey-label"><bean:message key="system.jsp.customkey.keylabel"/>:</label>
            <input class="form-control" disabled="true" type="text" id="customkey-label" name="label" length="64" value="<c:out value='${label}' />"/>
        </div>
        <div class="form-group">
          <label for="customkey-desc"><bean:message key="system.jsp.customkey.description"/>:</label>
          <textarea class="form-control" id="customkey-desc" disabled="true" wrap="virtual" rows="6" name="description"><c:out value="${description}" /></textarea>
        </div>

        <div class="text-right">
            <button class="btn btn-primary" type="submit" name="DeleteKey" value="Delete Key">Delete Key</button>
            <rhn:submitted/>
        </div>
      </form>
  </body>
</html:html>
