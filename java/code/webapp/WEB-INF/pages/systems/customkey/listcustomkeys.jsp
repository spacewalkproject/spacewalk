<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:html >
<body>
<BR>




<div>

    <div class="toolbar-h1"><div class="toolbar">
    	<span class="toolbar">
		<a href="/rhn/systems/customdata/CreateCustomKey.do">
    			<i class="fa fa-plus-circle text-success" title="create new key"></i>
    			<bean:message key="system.jsp.customkey.createlink"/>
    		</a>
    	</span>
    </div><i class="fa fa-key" title="keyring"></i>
	<bean:message key="system.jsp.customkey.title"/>
</div>

    <bean:message key="system.jsp.customkey.message" arg0="<a href=\"/rhn/systems/Search.do\">" arg1="</a>"/>
    <br><br>
    <bean:message key="system.jsp.customkey.message2"/>


    <rl:listset name="keySet">
    <rhn:csrf />
    <rhn:submitted />


	<rl:list dataset="pageList"
	         name="keyList"
                emptykey="system.jsp.customkey.empty"
                alphabarcolumn="label"
                filter="com.redhat.rhn.frontend.taglibs.list.filters.CustomKeyOverviewFilter">


                 <rl:column sortable="true"
                                   bound="false"
                           headerkey="system.jsp.customkey.keylabel"
                           sortattr="label"
					defaultsort="asc">

                        <a href="/rhn/systems/customdata/UpdateCustomKey.do?cikid=${current.id}">
                        <c:out value="${current.label}" />
                        </a>
                </rl:column>


                 <rl:column sortable="false"
                                   bound="false"
                           headerkey="system.jsp.customkey.description"
                          >
                       <c:out value="${current.description}" />
                </rl:column>



            <rl:column sortable="false"
                           bound="false"
                          headerkey="system.jsp.customkey.systemcount"
                          >
                        <c:out value="${current.serverCount}" />
                </rl:column>


                 <rl:column sortable="true"
                                   bound="false"
                           sortattr="lastModified"
                           headerkey="system.jsp.customkey.modified"
                          >
                        ${current.lastModified}
                </rl:column>


        </rl:list>

	<rl:csv dataset="pageList"
		        name="keyList"
		        exportColumns="id, label, description, serverCount, lastModified" />

    </rl:listset>

</div>

</body>
</html:html>
