<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>

<html>
<head>
    <script type="text/javascript" src="/rhn/dwr/interface/ActionChainEntriesRenderer.js"></script>
    <script type="text/javascript" src="/rhn/dwr/interface/ActionChainSaveAction.js"></script>
    <script type="text/javascript" src="/javascript/jquery-ui-1.10.4.custom.min.js"></script>
    <script type="text/javascript" src="/javascript/actionchain.js"></script>
</head>
<body>
    <rhn:toolbar base="h1" icon="header-chain"
        helpUrl="">
        <bean:message key="actionchain.jsp.title"/>
        <a id="label-link" href="#">
            <span id="label-link-text"><c:out value="${actionChain.label}"/></span>
            <i class="fa fa-pencil"></i>
        </a>
        <input id="label-input" type="text" value='<c:out value="${actionChain.label}"/>' autocomplete="off" hidden/>
    </rhn:toolbar>

    <div class="alert alert-success" id="success-message" hidden></div>
    <div class="alert alert-danger" id="error-message" hidden></div>

    <div class="spacewalk-toolbar-h1">
        <div class="spacewalk-toolbar">
            <a data-toggle="modal" href="#confirm-modal"><i class="fa fa-trash-o"></i>delete action chain</a>
        </div>
    </div>

    <p>
        <bean:message key="actionchain.jsp.summary"/>
    </p>
    <p>
        <bean:message key="actionchain.jsp.summarydetail"/>
    </p>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h4><bean:message key="actionchain.jsp.edit"/></h4>
        </div>
        <div class="panel-body">
            <div class="panel panel-default"><div class="table-responsive"><table class="table table-striped">
                <thead>
                    <tr>
                        <th><bean:message key="actionchain.jsp.action"/></th>
                        <th><bean:message key="actionchain.jsp.delete"/></th>
                    </tr>
                </thead>
                <tbody class="action-chain" data-action-chain-id="${param.id}">
                    <c:forEach items="${groups}" var="group">
                        <tr class="group" data-sort-order="${group.sortOrder}">
                            <td>
                                <a class="system-list-show-hide" href="#"><i class="fa fa-plus-square"></i></a>

                                <span class="counter">${group.sortOrder + 1}</span>.

                                <bean:message key="actionchain.jsp.${group.actionTypeLabel}" arg0="${group.relatedObjectDescription}"/>

                                <strong class="system-counter">
                                    ${group.systemCount}
                                </strong>

                                <span class="singular-label" <c:if test="${group.systemCount != 1}">hidden</c:if>>
                                    <bean:message key="actionchain.jsp.system"/>
                                </span>
                                <span class="plural-label" <c:if test="${group.systemCount == 1}">hidden</c:if>>
                                    <bean:message key="actionchain.jsp.systems"/>
                                </span>

                                <div class="system-list" id="system-list-${group.sortOrder}" hidden></div>
                            </td>
                            <td>
                                <a class="delete-group" href="#"><i class="fa fa-trash-o"></i>delete action</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table></div></div>

            <div id="action-chain-save-input" class="form-group" hidden>
                <div class="col-md-offset-3 col-md-6">
                    <button class="btn btn-primary" id="save"><bean:message key="actionchain.jsp.save"/></button>
                    <button class="btn btn-default" id="cancel"><bean:message key="actionchain.jsp.cancel"/></button>
                </div>
            </div>
        </div>
    </div>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h4><bean:message key="actionchain.jsp.schedule"/></h4>
        </div>
        <div class="panel-body">
            <form action="/rhn/schedule/ActionChain.do?id=${param.id}" method="post" class="schedule">
            <div class="form-horizontal">
                <div class="form-group">
                    <div class="col-sm-12">
                        <p>
                            <bean:message key="actionchain.jsp.schedulesummary"/>
                        </p>
                    </div>
                </div>
                <div class="form-group">
                    <rhn:hidden name="use_date" value="true"/>
                    <html:hidden property="dispatch" value="${rhn:localize('actionchain.jsp.saveandschedule')}"/>
                    <rhn:csrf/>
                    <rhn:submitted/>
                    <div class="col-md-offset-3 col-md-6">
                        <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                            <jsp:param name="widget" value="date"/>
                        </jsp:include>
                    </div>
                </div>
                <div class="form-group">
                    <div class="col-md-offset-3 col-md-6">
                        <button type="button" class="btn btn-success" id="save-and-schedule">
                            <bean:message key="actionchain.jsp.saveandschedule"/>
                        </button>
                    </div>
                </div>
            </div>
            </form>
        </div>
    </div>

    <%-- Modal delete confirm dialog --%>
    <div class="modal fade" id="confirm-modal" tabindex="-1" role="dialog" aria-labelledby="confirm-modal-title" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close"
                        data-dismiss="modal">&times;</button>
                    <h4 class="modal-title" id="confirm-modal-title">
                        <bean:message key="actionchain.jsp.modaltitle"/>
                    </h4>
                </div>
                <div class="modal-body">
                    <bean:message key="actionchain.jsp.modalbody"/>
                </div>
                <div class="modal-footer">
                    <form action="/rhn/schedule/ActionChain.do?id=${param.id}" method="post">
                        <rhn:csrf/>
                        <rhn:submitted/>
                        <input type="submit" name="dispatch" class="btn btn-danger" id="delete-action-chain"
                            value='<bean:message key="actionchain.jsp.delete"/>'
                        />
                    </form>
                </div>
            </div>
        </div>
    </div>

    <%-- Stay or leave page dialog text. Not shown by some browsers. --%>
    <span id="before-unload" hidden><bean:message key="actionchain.jsp.stayorleave"/></span>
</body>
</html>
