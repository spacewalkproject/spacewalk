
import up2dateAuth
import rpcServer
import hardware

def updateHardware():
    s = rpcServer.getServer()

    
    hardwareList = hardware.Hardware()
    s.registration.refresh_hw_profile(up2dateAuth.getSystemId(),
                                          hardwareList)
