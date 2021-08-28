#include "SmartLight.h"
#include "AM.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration SmartLightAppC {}
implementation {
  components MainC, SmartLightC as App, LedsC;
  components new AMSenderC(AM_SMART_LIGHT_MSG);
  components new AMReceiverC(AM_SMART_LIGHT_MSG);
  components new TimerMilliC() as MilliTimer1;
  components new TimerMilliC() as MilliTimer2;
  components new TimerMilliC() as MilliTimer3;
  components new TimerMilliC() as MilliTimer4;
  components ActiveMessageC;
  components SerialPrintfC;

  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.AMPacket -> AMSenderC;
  App.Packet -> AMSenderC;
  //timers
  App.MilliTimer1 -> MilliTimer1;
  App.MilliTimer2 -> MilliTimer2;
  App.MilliTimer3 -> MilliTimer3;
  App.MilliTimer4 -> MilliTimer4;
}
