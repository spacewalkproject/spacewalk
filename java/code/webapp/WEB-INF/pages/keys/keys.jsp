<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-info.gif"
               creationUrl="CryptoKeyCreate.do"
               creationType="keys"
               imgAlt="info.alt.img">
  <bean:message key="keys.jsp.toolbar"/>
</rhn:toolbar>

<div>
    <bean:message key="keys.jsp.summary"/>
    <form method="post" name="rhn_list" action="/rhn/keys/CryptoKeysList.do">

 <rl:listset name="keySet">
  <rl:list dataset="pageList"
         width="100%"
         name="keysList"
         styleclass="list"
         emptykey="keys.jsp.nokeys"
         alphabarcolumn="description">

	<rl:decorator name="PageSizeDecorator"/>

	<!-- Description name column -->
	<rl:column bound="false"
	           sortable="true"
	           headerkey="kickstart.cryptokey.description"
	           styleclass="first-column"
	           sortattr="description">
		<c:out value="<a href=\"/rhn/keys/CryptoKeyEdit.do?key_id=${current.id}\">${current.description}</a>" escapeXml="false" />
	</rl:column>

	<!-- Type Column -->
		<rl:column bound="false"
	           sortable="true"
	           headerkey="kickstart.cryptokey.type"
			   styleclass="last-column"
	           attr="label"
	           sortattr="label">
		<c:out value="${current.label}" escapeXml="false" />
	</rl:column>

      </rl:list>
     </rl:listset>

</div>

</body>
</html>

