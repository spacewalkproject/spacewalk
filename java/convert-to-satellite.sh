#!/bin/sh
# Order is important here:

perl -p -i -e 's/Spacewalk/RHN Satellite/g' `find ./code/webapp/WEB-INF/nav -name "*.xml"`

#perl -p -i -e 's/Spacewalk/RHN Satellite/g' ./code/webapp/WEB-INF/decorators/layout_head.jsp
#perl -p -i -e 's/spacewalk-logo.png/rhn_satellite.gif/g' ./code/webapp/WEB-INF/includes/header.jsp
#perl -p -i -e 's/Spacewalk/RHN Satellite/g' ./code/webapp/WEB-INF/includes/header.jsp
#perl -p -i -e 's/Spacewalk/RHN Satellite/g' ./code/webapp/WEB-INF/includes/header.jsp

#perl -p -i -e 's/Spacewalk/Satellite/g' `find ./code/src/ -name "*.java"`
#perl -p -i -e 's/Spacewalk/Satellite/g' code/src/com/redhat/rhn/frontend/events/test/NewUserEventTest.java

#perl -p -i -e 's/spacewalk/satellite/g' `find ./scripts/ -name "*.pl"`
#perl -p -i -e 's/spacewalk/satellite/g' `find ./scripts/ -name "*.py"`

