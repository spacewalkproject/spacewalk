
from up2date_client import up2dateAuth
from up2date_client import rpcServer
from up2date_client import hardware

def updateHardware():
    s = rpcServer.getServer()


    hardwareList = hardware.Hardware()
    s.registration.refresh_hw_profile(up2dateAuth.getSystemId(),
                                          hardwareList)
