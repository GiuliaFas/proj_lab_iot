#include "SmartLight.h"

configuration SmartLightAppC {}
implementation {
  components MainC, SmartLightC as App, LedsC, AMPacket;
  components new AMSenderC(AM_SMART_LIGHT_MSG);
  components new AMReceiverC(AM_SMART_LIGHT_MSG);
  components new TimerMilliC();
  components ActiveMessageC;

  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;
  App.Packet -> AMSenderC;
}
