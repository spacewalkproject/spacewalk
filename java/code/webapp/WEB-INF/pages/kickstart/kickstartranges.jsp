<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" icon="icon-rocket" imgAlt="kickstarts.alt.img">
  <bean:message key="kickstartranges.jsp.toolbar"/>
</rhn:toolbar>

<div>
    <bean:message key="kickstartranges.jsp.summary"/>
    <p>
    ${urlrange}
    </p>

    <rl:listset name="ipSet">
        <rhn:csrf />
        <rhn:submitted />

    	<rl:list dataset="pageList"
    	         name="ipList"
                emptykey="iprange.emptylist"
                  filter="com.redhat.rhn.frontend.action.kickstart.KickstartIpRangeFilter">



                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="kickstartranges.jsp.range"
                           sortattr="iprange.range">
                        <a href="/rhn/kickstart/KickstartIpRangeEdit.do?ksid=${current.id}">${current.iprange.range}</a>
                </rl:column>


                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="kickstartranges.jsp.profile"
                           sortattr="name">
                        <a href="/rhn/kickstart/KickstartDetailsEdit.do?ksid=${current.id}">${current.label}</a>
                </rl:column>


        </rl:list>

    </rl:listset>
    	

    		

</div>

</body>
</html:html>

