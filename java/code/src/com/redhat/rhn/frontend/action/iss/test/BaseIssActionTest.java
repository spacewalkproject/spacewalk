package com.redhat.rhn.frontend.action.iss.test;

import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssMaster;
import com.redhat.rhn.domain.iss.IssSlave;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

public abstract class BaseIssActionTest extends RhnMockStrutsTestCase {

    protected IssMaster masterDto;
    protected IssSlave slaveDto;

    @Override
    public void setUp() throws Exception {
        super.setUp();
        String masterName = "testMaster" + TestUtils.randomString();
        masterDto = new IssMaster();
        masterDto.setLabel(masterName);
        IssFactory.save(masterDto);
        masterDto = (IssMaster) IssFactory.reload(masterDto);

        String slaveName = "testSlave" + TestUtils.randomString();
        slaveDto = new IssSlave();
        slaveDto.setSlave(slaveName);
        slaveDto.setEnabled("Y");
        slaveDto.setAllowAllOrgs("Y");
        IssFactory.save(slaveDto);
        slaveDto = (IssSlave) IssFactory.reload(slaveDto);
    }

    public void testPermission() throws Exception {
        permissionCheck();
    }

    public void testList() throws Exception {
        if (getListName() == null) {
            return;
        }

        doPerform(true);
        verifyList(getListName(), getListClass());
        }

    protected void permissionCheck() {
        doPerform(false);
        assertPermissionException();

        doPerform(true);
        assertFalse(getActualForward().indexOf("errors/Permission.do") > 0);
    }

    protected void doPerform(boolean asSatAdmin) {
        setRequestPathInfo(getUrl());
        if (asSatAdmin) {
            user.addRole(RoleFactory.SAT_ADMIN);
        }
        actionPerform();
    }

    protected abstract String getUrl();

    protected abstract String getListName();
    protected abstract Class getListClass();
}
