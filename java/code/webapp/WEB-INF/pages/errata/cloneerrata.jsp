<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:html >
    <body>
<rhn:toolbar base="h1" icon="header-errata"
                 helpUrl="/rhn/help/getting-started/en-US/sect-Getting_Started_Guide-Errata_Management-Cloning_Errata.jsp">
        <bean:message key="cloneerrata.jsp.erratamanagement"/>
    </rhn:toolbar>

    <h2><bean:message key="cloneerrata.jsp.cloneerrata"/></h2>

    <p><bean:message key="cloneerrata.jsp.pagesummary"/></p>

    <rl:listset name="groupList" legend="errata">

        <rhn:csrf />

        <div class="panel panel-default">
            <div class="panel-body">
                <div class="row-0">
                    <div class="col-md-3">
                        <bean:message key="cloneerrata.jsp.viewapplicableerrata"/>:
                    </div>
                    <div class="col-md-5">
                        <select name="channel" class="form-control">
                            <c:forEach items="${clonablechannels}" var="option">
                                <option value="<c:out value="${option.value}"/>"
                                    <c:if test="${option.value == param.channel}">selected="1"</c:if>>
                                    <c:out value="${option.label}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="row-0">
                    <div class="col-md-offset-3 col-md-5">
                        <div class="checkbox">
                            <label>
                                <c:if test="${param.showalreadycloned == 1}">
                                    <input type="checkbox" name="showalreadycloned" value="1" checked>
                                </c:if>
                                <c:if test="${param.showalreadycloned != 1}">
                                    <input type="checkbox" name="showalreadycloned" value="1">
                                </c:if>
                                <bean:message key="cloneerrata.jsp.showclonederrata"/>
                            </label>
                        </div>
                    </div>
                </div>
                <div class="row-0">
                    <div class="col-md-offset-3 col-md-5">
                        <html:submit styleClass="btn btn-success">
                            <bean:message key="cloneerrata.jsp.view"/>
                        </html:submit>
                    </div>
                </div>

            </div>
        </div>

        <rl:list emptykey="cloneerrata.jsp.noerrata">

            <rl:decorator name="PageSizeDecorator"/>
            <rl:decorator name="SelectableDecorator"/>
            <rl:decorator name="ElaborationDecorator"/>

            <rl:selectablecolumn value="${current.selectionKey}"
                                 selected="${current.selected}"
                                 disabled="${not current.selectable}"/>

            <rl:column headerkey="cloneerrata.jsp.type">
                ${current.advisoryType}
            </rl:column>
            <rl:column headerkey="cloneerrata.jsp.advisory">
                <a href="/rhn/errata/details/Details.do?eid=${current.id}">${current.advisoryName}</a>
            </rl:column>
            <rl:column headerkey="cloneerrata.jsp.synopsis">
                ${current.synopsis}
            </rl:column>
            <rl:column headerkey="cloneerrata.jsp.updated">
                ${current.updateDate}
            </rl:column>
            <rl:column headerkey="cloneerrata.jsp.potentialchannels">
                <c:forEach items="${current.channelMap}" var="map">
                    <a href="/rhn/channels/manage/Edit.do?cid=${map.id}">${map.name}</a><br/>
                </c:forEach>
            </rl:column>
            <rl:column headerkey="cloneerrata.jsp.alreadycloned">
                <c:choose>
                    <c:when test="${current.alreadyCloned}">
                        <bean:message key="yes"/>
                    </c:when>
                    <c:otherwise>
                        <bean:message key="no"/>
                    </c:otherwise>
                </c:choose>
            </rl:column>

        </rl:list>

        <div class="text-right">
            <rhn:submitted/>
            <input type="submit"
                   name="dispatch"
                   class="btn btn-default"
                   value='<bean:message key="cloneerrata.jsp.cloneerrata"/>'/>
        </div>

    </rl:listset>

    </body>
</html:html>
